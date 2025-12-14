#import "TagLibTestSupport.h"

#import <TagLib/taglib.h>
#import <TagLib/tag.h>
#import <TagLib/mpegfile.h>
#import <TagLib/id3v2tag.h>
#import <TagLib/id3v2frame.h>
#import <TagLib/textidentificationframe.h>
#import <TagLib/mp4file.h>
#import <TagLib/mp4tag.h>
#import <TagLib/mp4item.h>
#import <TagLib/tstringlist.h>

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

NSDictionary<NSString *, id> *TLTestReadTags(NSString *path, NSError **error) {
    NSString *ext = path.pathExtension.lowercaseString;
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
        auto map = tag->itemListMap();
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[kTLTestTitleKey] = nsStringFromTagString(map["\xA9""nam"].toStringList().toString());
        dict[kTLTestArtistKey] = nsStringFromTagString(map["\xA9""ART"].toStringList().toString());
        dict[kTLTestAlbumKey] = nsStringFromTagString(map["\xA9""alb"].toStringList().toString());
        dict[kTLTestAlbumArtistKey] = nsStringFromTagString(map["aART"].toStringList().toString());
        dict[kTLTestComposerKey] = nsStringFromTagString(map["\xA9""wrt"].toStringList().toString());
        dict[kTLTestGenreKey] = nsStringFromTagString(map["\xA9""gen"].toStringList().toString());
        dict[kTLTestYearKey] = nsStringFromTagString(map["\xA9""day"].toStringList().toString());
        auto trknIt = map.find("trkn");
        if (trknIt != map.end()) {
            auto pair = trknIt->second.toIntPair();
            dict[kTLTestTrackNumberKey] = @(pair.first);
            dict[kTLTestTrackTotalKey] = @(pair.second);
        }
        return dict;
    } else {
        if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:99 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported format"}];
        return @{};
    }
}

BOOL TLTestWriteTags(NSString *path, NSDictionary<NSString *, id> *tags, NSError **error) {
    NSString *ext = path.pathExtension.lowercaseString;
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
        TagLib::MP4::ItemListMap &map = tag->itemListMap();
        NSString *title = tags[kTLTestTitleKey];
        NSString *artist = tags[kTLTestArtistKey];
        NSString *album = tags[kTLTestAlbumKey];
        NSString *albumArtist = tags[kTLTestAlbumArtistKey];
        NSString *composer = tags[kTLTestComposerKey];
        NSString *genre = tags[kTLTestGenreKey];
        NSString *year = tags[kTLTestYearKey];
        NSNumber *trackNumber = tags[kTLTestTrackNumberKey];
        NSNumber *trackTotal = tags[kTLTestTrackTotalKey];

        if (title) map["\xA9""nam"] = mp4ItemFromNSString(title);
        if (artist) map["\xA9""ART"] = mp4ItemFromNSString(artist);
        if (album) map["\xA9""alb"] = mp4ItemFromNSString(album);
        if (albumArtist) map["aART"] = mp4ItemFromNSString(albumArtist);
        if (composer) map["\xA9""wrt"] = mp4ItemFromNSString(composer);
        if (genre) map["\xA9""gen"] = mp4ItemFromNSString(genre);
        if (year) map["\xA9""day"] = mp4ItemFromNSString(year);

        if (trackNumber || trackTotal) {
            uint num = trackNumber ? trackNumber.unsignedIntValue : 0;
            uint total = trackTotal ? trackTotal.unsignedIntValue : 0;
            map["trkn"] = TagLib::MP4::Item(num, total);
        } else {
            map.erase("trkn");
        }

        return file.save();
    } else {
        if (error) *error = [NSError errorWithDomain:@"TagLibTest" code:99 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported format"}];
        return NO;
    }
}
