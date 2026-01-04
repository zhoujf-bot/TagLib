#import "TagLibTestSupport.h"

#import <taglib/taglib.h>
#import <taglib/tag.h>
#import <taglib/mpegfile.h>
#import <taglib/id3v2tag.h>
#import <taglib/id3v2frame.h>
#import <taglib/textidentificationframe.h>
#import <taglib/mp4file.h>
#import <taglib/mp4tag.h>
#import <taglib/mp4item.h>
#import <taglib/tstringlist.h>

NSString *const kTLTestTitleKey = @"title";
NSString *const kTLTestArtistKey = @"artist";
NSString *const kTLTestAlbumKey = @"album";
NSString *const kTLTestAlbumArtistKey = @"albumArtist";
NSString *const kTLTestComposerKey = @"composer";
NSString *const kTLTestYearKey = @"year";
NSString *const kTLTestGenreKey = @"genre";
NSString *const kTLTestTrackNumberKey = @"trackNumber";
NSString *const kTLTestTrackTotalKey = @"trackTotal";

static NSString *nsStringFromTagString(const TagLib::String &str) {
    return [NSString stringWithUTF8String:str.toCString(true) ?: ""];
}

static TagLib::MP4::Item mp4ItemFromNSString(NSString *value) {
    TagLib::StringList list;
    list.append(TagLib::String(value.UTF8String, TagLib::String::UTF8));
    return TagLib::MP4::Item(list);
}

static bool isAllDigits(NSString *value) {
    if (!value || value.length == 0) return false;
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [value rangeOfCharacterFromSet:nonDigits].location == NSNotFound;
}

static NSString *resolvedExtension(NSString *path) {
    NSString *ext = path.pathExtension.lowercaseString;
    if (ext.length > 0) return ext;
    NSString *name = path.lastPathComponent.lowercaseString;
    NSArray<NSString *> *parts = [name componentsSeparatedByString:@"_"];
    NSString *suffix = parts.count > 1 ? parts.lastObject : @"";
    if (suffix.length > 0) {
        NSArray<NSString *> *dashParts = [suffix componentsSeparatedByString:@"-"];
        if (dashParts.count > 0) {
            suffix = dashParts.firstObject;
        }
    }
    NSSet<NSString *> *supported = [NSSet setWithArray:@[
        @"mp3", @"m4a", @"mp4", @"aac", @"flac", @"ogg", @"opus", @"wav", @"aif", @"aiff", @"wv", @"mpc", @"dsf", @"m4b", @"m4v"
    ]];
    if ([supported containsObject:suffix]) {
        return suffix;
    }
    return ext;
}

extern "C" NSDictionary<NSString *, id> *TLTestReadTags(NSString *path, NSError **error) {
    NSString *ext = resolvedExtension(path);
    if ([ext isEqualToString:@"mp3"]) {
        TagLib::MPEG::File file(path.UTF8String, false);
        if (!file.isOpen() || !file.tag()) {
            if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP3"}];
            return @{};
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        TagLib::Tag *t = file.tag();
        dict[kTLTestTitleKey] = nsStringFromTagString(t->title());
        dict[kTLTestArtistKey] = nsStringFromTagString(t->artist());
        dict[kTLTestAlbumKey] = nsStringFromTagString(t->album());
        dict[kTLTestGenreKey] = nsStringFromTagString(t->genre());
        dict[kTLTestYearKey] = @(t->year());
        dict[kTLTestTrackNumberKey] = @(t->track());

        TagLib::ID3v2::Tag *id3 = file.ID3v2Tag(false);
        if (id3) {
            TagLib::ID3v2::FrameList frames = id3->frameList("TPE2");
            if (!frames.isEmpty()) {
                if (auto frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(frames.front())) {
                    dict[kTLTestAlbumArtistKey] = nsStringFromTagString(frame->toString());
                }
            }
            TagLib::ID3v2::FrameList trackFrames = id3->frameList("TRCK");
            if (!trackFrames.isEmpty()) {
                TagLib::String trackString = trackFrames.front()->toString();
                std::string s = trackString.toCString(true);
                size_t slash = s.find('/');
                if (slash != std::string::npos) {
                    std::string num = s.substr(0, slash);
                    std::string total = s.substr(slash + 1);
                    if (!num.empty()) dict[kTLTestTrackNumberKey] = @(atoi(num.c_str()));
                    if (!total.empty()) dict[kTLTestTrackTotalKey] = @(atoi(total.c_str()));
                }
            }
            TagLib::ID3v2::FrameList composerFrames = id3->frameList("TCOM");
            if (!composerFrames.isEmpty()) {
                if (auto frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(composerFrames.front())) {
                    dict[kTLTestComposerKey] = nsStringFromTagString(frame->toString());
                }
            }
        }
        return dict;
    } else if ([ext isEqualToString:@"m4a"] || [ext isEqualToString:@"aac"] || [ext isEqualToString:@"mp4"] || [ext isEqualToString:@"m4b"] || [ext isEqualToString:@"m4v"]) {
        TagLib::MP4::File file(path.UTF8String, false);
        TagLib::MP4::Tag *tag = file.tag();
        if (!tag) {
            if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP4"}];
            return @{};
        }
        const auto &map = tag->itemMap();
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        auto titleKey = TagLib::String("\xA9""nam", TagLib::String::Latin1);
        auto artistKey = TagLib::String("\xA9""ART", TagLib::String::Latin1);
        auto albumKey = TagLib::String("\xA9""alb", TagLib::String::Latin1);
        auto albumArtistKey = TagLib::String("aART", TagLib::String::Latin1);
        auto composerKey = TagLib::String("\xA9""wrt", TagLib::String::Latin1);
        auto genreKey = TagLib::String("\xA9""gen", TagLib::String::Latin1);
        auto yearKey = TagLib::String("\xA9""day", TagLib::String::Latin1);
        if (tag->contains(titleKey)) dict[kTLTestTitleKey] = nsStringFromTagString(tag->item(titleKey).toStringList().toString());
        if (tag->contains(artistKey)) dict[kTLTestArtistKey] = nsStringFromTagString(tag->item(artistKey).toStringList().toString());
        if (tag->contains(albumKey)) dict[kTLTestAlbumKey] = nsStringFromTagString(tag->item(albumKey).toStringList().toString());
        if (tag->contains(albumArtistKey)) dict[kTLTestAlbumArtistKey] = nsStringFromTagString(tag->item(albumArtistKey).toStringList().toString());
        if (tag->contains(composerKey)) dict[kTLTestComposerKey] = nsStringFromTagString(tag->item(composerKey).toStringList().toString());
        if (tag->contains(genreKey)) dict[kTLTestGenreKey] = nsStringFromTagString(tag->item(genreKey).toStringList().toString());
        if (tag->contains(yearKey)) {
            NSString *yearString = nsStringFromTagString(tag->item(yearKey).toStringList().toString());
            if (isAllDigits(yearString)) {
                dict[kTLTestYearKey] = @([yearString intValue]);
            } else {
                dict[kTLTestYearKey] = yearString;
            }
        }
        auto trknKey = TagLib::String("trkn", TagLib::String::Latin1);
        if (tag->contains(trknKey)) {
            auto pair = tag->item(trknKey).toIntPair();
            dict[kTLTestTrackNumberKey] = @(pair.first);
            dict[kTLTestTrackTotalKey] = @(pair.second);
        }
        return dict;
    } else {
        if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:99 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported format"}];
        return @{};
    }
}

extern "C" BOOL TLTestWriteTags(NSString *path, NSDictionary<NSString *, id> *tags, NSError **error) {
    NSString *ext = resolvedExtension(path);
    if ([ext isEqualToString:@"mp3"]) {
        TagLib::MPEG::File file(path.UTF8String, false);
        if (!file.isOpen() || !file.tag()) {
            if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP3"}];
            return NO;
        }
        TagLib::Tag *t = file.tag();
        NSString *title = tags[kTLTestTitleKey];
        NSString *artist = tags[kTLTestArtistKey];
        NSString *album = tags[kTLTestAlbumKey];
        NSString *albumArtist = tags[kTLTestAlbumArtistKey];
        NSString *composer = tags[kTLTestComposerKey];
        NSString *genre = tags[kTLTestGenreKey];
        NSNumber *year = tags[kTLTestYearKey];
        NSNumber *trackNumber = tags[kTLTestTrackNumberKey];
        NSNumber *trackTotal = tags[kTLTestTrackTotalKey];

        if (title) t->setTitle(TagLib::String(title.UTF8String, TagLib::String::UTF8));
        if (artist) t->setArtist(TagLib::String(artist.UTF8String, TagLib::String::UTF8));
        if (album) t->setAlbum(TagLib::String(album.UTF8String, TagLib::String::UTF8));
        if (genre) t->setGenre(TagLib::String(genre.UTF8String, TagLib::String::UTF8));
        if (year) t->setYear(year.intValue);
        if (trackNumber) t->setTrack(trackNumber.intValue);

        TagLib::ID3v2::Tag *id3 = file.ID3v2Tag(true);
        if (id3) {
            if (albumArtist) {
                TagLib::ID3v2::FrameList list = id3->frameListMap()["TPE2"];
                TagLib::ID3v2::TextIdentificationFrame *frame = nullptr;
                if (!list.isEmpty()) frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(list.front());
                if (!frame) {
                    frame = new TagLib::ID3v2::TextIdentificationFrame("TPE2", TagLib::String::UTF8);
                    id3->addFrame(frame);
                }
                frame->setText(TagLib::String(albumArtist.UTF8String, TagLib::String::UTF8));
            }
            if (composer) {
                TagLib::ID3v2::FrameList list = id3->frameListMap()["TCOM"];
                TagLib::ID3v2::TextIdentificationFrame *frame = nullptr;
                if (!list.isEmpty()) frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(list.front());
                if (!frame) {
                    frame = new TagLib::ID3v2::TextIdentificationFrame("TCOM", TagLib::String::UTF8);
                    id3->addFrame(frame);
                }
                frame->setText(TagLib::String(composer.UTF8String, TagLib::String::UTF8));
            }
            if (trackNumber || trackTotal) {
                TagLib::ID3v2::FrameList trckFrames = id3->frameList("TRCK");
                for (auto it = trckFrames.begin(); it != trckFrames.end(); ++it) {
                    id3->removeFrame(*it, true);
                }
                TagLib::ID3v2::TextIdentificationFrame *trck = new TagLib::ID3v2::TextIdentificationFrame("TRCK", TagLib::String::UTF8);
                int num = trackNumber ? trackNumber.intValue : 0;
                int total = trackTotal ? trackTotal.intValue : 0;
                if (total > 0) {
                    std::string text = std::to_string(num) + "/" + std::to_string(total);
                    trck->setText(TagLib::String(text, TagLib::String::UTF8));
                } else {
                    trck->setText(TagLib::String::number(num));
                }
                id3->addFrame(trck);
            }
        }
        return file.save();
    } else if ([ext isEqualToString:@"m4a"] || [ext isEqualToString:@"aac"] || [ext isEqualToString:@"mp4"] || [ext isEqualToString:@"m4b"] || [ext isEqualToString:@"m4v"]) {
        TagLib::MP4::File file(path.UTF8String, false);
        TagLib::MP4::Tag *tag = file.tag();
        if (!tag) {
            if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:4 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP4"}];
            return NO;
        }
        TagLib::String titleKey("\xA9""nam", TagLib::String::Latin1);
        TagLib::String artistKey("\xA9""ART", TagLib::String::Latin1);
        TagLib::String albumKey("\xA9""alb", TagLib::String::Latin1);
        TagLib::String albumArtistKey("aART", TagLib::String::Latin1);
        TagLib::String composerKey("\xA9""wrt", TagLib::String::Latin1);
        TagLib::String genreKey("\xA9""gen", TagLib::String::Latin1);
        TagLib::String yearKey("\xA9""day", TagLib::String::Latin1);
        TagLib::String trknKey("trkn", TagLib::String::Latin1);
        NSString *title = tags[kTLTestTitleKey];
        NSString *artist = tags[kTLTestArtistKey];
        NSString *album = tags[kTLTestAlbumKey];
        NSString *albumArtist = tags[kTLTestAlbumArtistKey];
        NSString *composer = tags[kTLTestComposerKey];
        NSString *genre = tags[kTLTestGenreKey];
        id yearObj = tags[kTLTestYearKey];
        NSString *year = nil;
        if ([yearObj isKindOfClass:[NSString class]]) {
            year = (NSString *)yearObj;
        } else if ([yearObj isKindOfClass:[NSNumber class]]) {
            year = [(NSNumber *)yearObj stringValue];
        }
        NSNumber *trackNumber = tags[kTLTestTrackNumberKey];
        NSNumber *trackTotal = tags[kTLTestTrackTotalKey];

        if (title) tag->setItem(titleKey, mp4ItemFromNSString(title));
        if (artist) tag->setItem(artistKey, mp4ItemFromNSString(artist));
        if (album) tag->setItem(albumKey, mp4ItemFromNSString(album));
        if (albumArtist) tag->setItem(albumArtistKey, mp4ItemFromNSString(albumArtist));
        if (composer) tag->setItem(composerKey, mp4ItemFromNSString(composer));
        if (genre) tag->setItem(genreKey, mp4ItemFromNSString(genre));
        if (year) tag->setItem(yearKey, mp4ItemFromNSString(year));

        if (trackNumber || trackTotal) {
            uint num = trackNumber ? trackNumber.unsignedIntValue : 0;
            uint total = trackTotal ? trackTotal.unsignedIntValue : 0;
            tag->setItem(trknKey, TagLib::MP4::Item(num, total));
        } else {
            tag->removeItem(trknKey);
        }

        return file.save();
    } else {
        if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:99 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported format"}];
        return NO;
    }
}
