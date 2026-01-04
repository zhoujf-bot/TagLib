#import "TagLibBridge.h"

#if __has_include(<TagLib/taglib.h>)
#ifdef TAGLIB_EXPORT_H
#undef TAGLIB_EXPORT_H
#endif
#ifndef TAGLIB_MSVC_SUPPRESS_WARNING_NEEDS_TO_HAVE_DLL_INTERFACE
#define TAGLIB_MSVC_SUPPRESS_WARNING_NEEDS_TO_HAVE_DLL_INTERFACE
#endif
#ifndef TAGLIB_OFFSET_T_FALLBACK
typedef long long offset_t;
#define TAGLIB_OFFSET_T_FALLBACK 1
#endif
#import <taglib/taglib_export.h>
#import <taglib/taglib_config.h>
#import <taglib/taglib.h>
#ifdef TAGLIB_AUDIOPROPERTIES_H
#undef TAGLIB_AUDIOPROPERTIES_H
#endif
#include <taglib/audioproperties.h>
#import <taglib/tag.h>
#import <taglib/tiostream.h>
#import <taglib/tpropertymap.h>
#import <taglib/tvariant.h>
#import <taglib/mpegfile.h>
#import <taglib/id3v2tag.h>
#import <taglib/id3v2frame.h>
#import <taglib/attachedpictureframe.h>
#import <taglib/textidentificationframe.h>
#if __has_include(<TagLib/fileref.h>)
#define TAGLIB_HAVE_FILEREF 1
#import <taglib/fileref.h>
#endif
#if __has_include(<TagLib/flacfile.h>)
#define TAGLIB_HAVE_FLAC 1
#import <taglib/flacfile.h>
#import <taglib/flacpicture.h>
#endif
#if __has_include(<TagLib/oggfile.h>)
#define TAGLIB_HAVE_OGG 1
#import <taglib/oggfile.h>
#endif
#if __has_include(<TagLib/oggflacfile.h>)
#define TAGLIB_HAVE_OGGFLAC 1
#import <taglib/oggflacfile.h>
#endif
#if __has_include(<TagLib/vorbisfile.h>)
#define TAGLIB_HAVE_VORBIS 1
#import <taglib/vorbisfile.h>
#endif
#if __has_include(<TagLib/opusfile.h>)
#define TAGLIB_HAVE_OPUS 1
#import <taglib/opusfile.h>
#endif
#if __has_include(<TagLib/wavfile.h>)
#define TAGLIB_HAVE_WAV 1
#import <taglib/wavfile.h>
#endif
#if __has_include(<TagLib/aifffile.h>)
#define TAGLIB_HAVE_AIFF 1
#import <taglib/aifffile.h>
#endif
#if __has_include(<TagLib/mpcfile.h>)
#define TAGLIB_HAVE_MPC 1
#import <taglib/mpcfile.h>
#endif
#if __has_include(<TagLib/wavpackfile.h>)
#define TAGLIB_HAVE_WAVPACK 1
#import <taglib/wavpackfile.h>
#endif
#if __has_include(<TagLib/dsffile.h>)
#define TAGLIB_HAVE_DSF 1
#import <taglib/dsffile.h>
#endif
#if __has_include(<TagLib/xiphcomment.h>)
#define TAGLIB_HAVE_XIPH 1
#import <taglib/xiphcomment.h>
#endif
#import <taglib/mp4file.h>
#import <taglib/mp4tag.h>
#import <taglib/mp4item.h>
#import <taglib/tbytevectorlist.h>
#import <taglib/tstringlist.h>
#endif

#ifndef TAGLIB_HAVE_FLAC
#define TAGLIB_HAVE_FLAC 0
#endif
#ifndef TAGLIB_HAVE_OGG
#define TAGLIB_HAVE_OGG 0
#endif
#ifndef TAGLIB_HAVE_OPUS
#define TAGLIB_HAVE_OPUS 0
#endif
#ifndef TAGLIB_HAVE_WAVPACK
#define TAGLIB_HAVE_WAVPACK 0
#endif
#ifndef TAGLIB_HAVE_MPC
#define TAGLIB_HAVE_MPC 0
#endif
#ifndef TAGLIB_HAVE_DSF
#define TAGLIB_HAVE_DSF 0
#endif
#ifndef TAGLIB_HAVE_WAV
#define TAGLIB_HAVE_WAV 0
#endif
#ifndef TAGLIB_HAVE_AIFF
#define TAGLIB_HAVE_AIFF 0
#endif
#ifndef TAGLIB_HAVE_XIPH
#define TAGLIB_HAVE_XIPH 0
#endif

static NSString *nsStringFromTagString(const TagLib::String &str) {
    return [NSString stringWithUTF8String:str.toCString(true) ?: ""];
}

static TagLib::MP4::Item mp4ItemFromNSString(NSString *value) {
    TagLib::StringList list;
    list.append(TagLib::String(value.UTF8String, TagLib::String::UTF8));
    return TagLib::MP4::Item(list);
}

@implementation TagLibBridge

+ (NSDictionary<NSString *, id> *)readTagsAtPath:(NSString *)path error:(NSError **)error {
#if __has_include(<TagLib/taglib.h>)
    NSString *ext = path.pathExtension.lowercaseString;
    if ([ext isEqualToString:@"mp3"]) {
        return [self readID3Tags:path error:error];
    } else if ([ext isEqualToString:@"m4a"] || [ext isEqualToString:@"aac"] || [ext isEqualToString:@"mp4"]) {
        return [self readMP4Tags:path error:error];
    } else if ([ext isEqualToString:@"flac"]) {
        return [self readFLACTags:path error:error];
    } else if ([ext isEqualToString:@"ogg"]) {
        return [self readOGGTags:path error:error];
    } else if ([ext isEqualToString:@"opus"]) {
        return [self readOpusTags:path error:error];
    } else if ([ext isEqualToString:@"wv"]) {
        return [self readWavPackTags:path error:error];
    } else if ([ext isEqualToString:@"mpc"]) {
        return [self readMPCTags:path error:error];
    } else if ([ext isEqualToString:@"dsf"]) {
        return [self readDSFTags:path error:error];
    } else if ([ext isEqualToString:@"wav"] || [ext isEqualToString:@"aiff"] || [ext isEqualToString:@"aif"]) {
        return [self readGenericTags:path error:error];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:4 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported format"}];
        }
        return @{};
    }
#else
    if (error) {
        *error = [NSError errorWithDomain:@"TagLibBridge" code:99 userInfo:@{NSLocalizedDescriptionKey: @"TagLib headers not present"}];
    }
    return @{};
#endif
}

+ (BOOL)writeTagsAtPath:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
#if __has_include(<TagLib/taglib.h>)
    NSString *ext = path.pathExtension.lowercaseString;
    BOOL ok = NO;
    if ([ext isEqualToString:@"mp3"]) {
        ok = [self writeID3Tags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"m4a"] || [ext isEqualToString:@"aac"] || [ext isEqualToString:@"mp4"]) {
        ok = [self writeMP4Tags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"flac"]) {
        ok = [self writeFLACTags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"ogg"]) {
        ok = [self writeOGGTags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"opus"]) {
        ok = [self writeOpusTags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"wv"]) {
        ok = [self writeWavPackTags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"mpc"]) {
        ok = [self writeMPCTags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"dsf"]) {
        ok = [self writeDSFTags:path tags:tags error:error];
    } else if ([ext isEqualToString:@"wav"] || [ext isEqualToString:@"aiff"] || [ext isEqualToString:@"aif"]) {
        ok = [self writeGenericTags:path tags:tags error:error];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:4 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported format"}];
        }
        return NO;
    }
    return ok;
#else
    if (error) {
        *error = [NSError errorWithDomain:@"TagLibBridge" code:99 userInfo:@{NSLocalizedDescriptionKey: @"TagLib headers not present"}];
    }
    return NO;
#endif
}

#pragma mark - ID3 (MP3)

+ (NSDictionary<NSString *, id> *)readID3Tags:(NSString *)path error:(NSError **)error {
    TagLib::MPEG::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP3 tag"}];
        }
        return @{};
    }
    TagLib::Tag *t = file.tag();
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"title"] = nsStringFromTagString(t->title());
    dict[@"artist"] = nsStringFromTagString(t->artist());
    dict[@"album"] = nsStringFromTagString(t->album());
    dict[@"comment"] = nsStringFromTagString(t->comment());
    dict[@"genre"] = nsStringFromTagString(t->genre());
    dict[@"year"] = @(t->year());
    dict[@"trackNumber"] = @(t->track());
    dict[@"albumArtist"] = @"";
    dict[@"composer"] = @"";
    dict[@"discNumber"] = @(0);
    dict[@"discTotal"] = @(0);

    TagLib::ID3v2::Tag *id3 = file.ID3v2Tag(false);
    if (id3) {
        TagLib::ID3v2::FrameList albumArtistFrames = id3->frameList("TPE2");
        if (!albumArtistFrames.isEmpty()) {
            TagLib::ID3v2::TextIdentificationFrame *frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(albumArtistFrames.front());
            if (frame) {
                dict[@"albumArtist"] = nsStringFromTagString(frame->toString());
            }
        }
        TagLib::ID3v2::FrameList trackFrames = id3->frameList("TRCK");
        if (!trackFrames.isEmpty()) {
            TagLib::String trackString = trackFrames.front()->toString();
            std::string utf8 = trackString.toCString(true);
            std::string s = utf8;
            size_t slash = s.find('/');
            if (slash != std::string::npos) {
                std::string num = s.substr(0, slash);
                std::string total = s.substr(slash + 1);
                if (!num.empty()) dict[@"trackNumber"] = @(atoi(num.c_str()));
                if (!total.empty()) dict[@"trackTotal"] = @(atoi(total.c_str()));
            } else {
                if (!s.empty()) dict[@"trackNumber"] = @(atoi(s.c_str()));
            }
        }
        TagLib::ID3v2::FrameList tposFrames = id3->frameList("TPOS");
        if (!tposFrames.isEmpty()) {
            TagLib::String discString = tposFrames.front()->toString();
            std::string utf8 = discString.toCString(true);
            std::string s = utf8;
            size_t slash = s.find('/');
            if (slash != std::string::npos) {
                std::string num = s.substr(0, slash);
                std::string total = s.substr(slash + 1);
                if (!num.empty()) dict[@"discNumber"] = @(atoi(num.c_str()));
                if (!total.empty()) dict[@"discTotal"] = @(atoi(total.c_str()));
            } else {
                if (!s.empty()) dict[@"discNumber"] = @(atoi(s.c_str()));
            }
        }

        TagLib::ID3v2::FrameList composerFrames = id3->frameList("TCOM");
        if (!composerFrames.isEmpty()) {
            TagLib::ID3v2::TextIdentificationFrame *frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(composerFrames.front());
            if (frame) {
                dict[@"composer"] = nsStringFromTagString(frame->toString());
            }
        }
        const TagLib::ID3v2::FrameList &pictures = id3->frameList("APIC");
        for (auto it = pictures.begin(); it != pictures.end(); ++it) {
            TagLib::ID3v2::AttachedPictureFrame *frame = dynamic_cast<TagLib::ID3v2::AttachedPictureFrame *>(*it);
            if (frame && frame->picture().size() > 0) {
                NSData *data = [NSData dataWithBytes:frame->picture().data() length:frame->picture().size()];
                if (data) {
                    dict[@"coverImageData"] = data;
                    break;
                }
            }
        }
    }
    return dict;
}

+ (BOOL)writeID3Tags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::MPEG::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP3 tag"}];
        }
        return NO;
    }
    TagLib::Tag *t = file.tag();

    NSString *title = tags[@"title"];
    NSString *artist = tags[@"artist"];
    NSString *album = tags[@"album"];
    NSString *albumArtist = tags[@"albumArtist"];
    NSString *composer = tags[@"composer"];
    NSString *comment = tags[@"comment"];
    NSString *genre = tags[@"genre"];
    NSNumber *year = ([tags[@"year"] isKindOfClass:[NSNumber class]]) ? tags[@"year"] : nil;
    NSNumber *trackNumber = ([tags[@"trackNumber"] isKindOfClass:[NSNumber class]]) ? tags[@"trackNumber"] : nil;
    NSNumber *trackTotal = ([tags[@"trackTotal"] isKindOfClass:[NSNumber class]]) ? tags[@"trackTotal"] : nil;
    NSNumber *discNumber = ([tags[@"discNumber"] isKindOfClass:[NSNumber class]]) ? tags[@"discNumber"] : nil;
    NSNumber *discTotal = ([tags[@"discTotal"] isKindOfClass:[NSNumber class]]) ? tags[@"discTotal"] : nil;
    id coverObj = tags[@"coverImageData"];
    NSData *coverData = ([coverObj isKindOfClass:[NSData class]]) ? (NSData *)coverObj : nil;

    if (title) t->setTitle(TagLib::String(title.UTF8String, TagLib::String::UTF8));
    if (artist) t->setArtist(TagLib::String(artist.UTF8String, TagLib::String::UTF8));
    if (album) t->setAlbum(TagLib::String(album.UTF8String, TagLib::String::UTF8));
    if (comment) t->setComment(TagLib::String(comment.UTF8String, TagLib::String::UTF8));
    if (genre) t->setGenre(TagLib::String(genre.UTF8String, TagLib::String::UTF8));
    if (year) t->setYear(year.unsignedShortValue);
    if (trackNumber) t->setTrack(trackNumber.unsignedShortValue);

    TagLib::ID3v2::Tag *id3 = file.ID3v2Tag(true);
    if (id3) {
        if (albumArtist) {
            TagLib::ID3v2::FrameList list = id3->frameListMap()["TPE2"];
            TagLib::ID3v2::TextIdentificationFrame *frame = nullptr;
            if (!list.isEmpty()) {
                frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(list.front());
            }
            if (!frame) {
                frame = new TagLib::ID3v2::TextIdentificationFrame("TPE2", TagLib::String::UTF8);
                id3->addFrame(frame);
            }
            frame->setText(TagLib::String(albumArtist.UTF8String, TagLib::String::UTF8));
        }

        if (coverData && coverData.length > 0) {
            TagLib::ID3v2::FrameList pictures = id3->frameList("APIC");
            for (auto it = pictures.begin(); it != pictures.end(); ++it) {
                id3->removeFrame(*it, true);
            }
            TagLib::ID3v2::AttachedPictureFrame *apic = new TagLib::ID3v2::AttachedPictureFrame;
            apic->setType(TagLib::ID3v2::AttachedPictureFrame::FrontCover);
            apic->setMimeType("image/jpeg");
            apic->setPicture(TagLib::ByteVector((const char *)coverData.bytes, coverData.length));
            id3->addFrame(apic);
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

        if (discNumber || discTotal) {
            TagLib::ID3v2::FrameList tposFrames = id3->frameList("TPOS");
            for (auto it = tposFrames.begin(); it != tposFrames.end(); ++it) {
                id3->removeFrame(*it, true);
            }
            TagLib::ID3v2::TextIdentificationFrame *tpos = new TagLib::ID3v2::TextIdentificationFrame("TPOS", TagLib::String::UTF8);
            int num = discNumber ? discNumber.intValue : 0;
            int total = discTotal ? discTotal.intValue : 0;
            if (total > 0) {
                std::string text = std::to_string(num) + "/" + std::to_string(total);
                tpos->setText(TagLib::String(text, TagLib::String::UTF8));
            } else {
                tpos->setText(TagLib::String::number(num));
            }
            id3->addFrame(tpos);
        }

        if (composer) {
            TagLib::ID3v2::FrameList list = id3->frameListMap()["TCOM"];
            TagLib::ID3v2::TextIdentificationFrame *frame = nullptr;
            if (!list.isEmpty()) {
                frame = dynamic_cast<TagLib::ID3v2::TextIdentificationFrame *>(list.front());
            }
            if (!frame) {
                frame = new TagLib::ID3v2::TextIdentificationFrame("TCOM", TagLib::String::UTF8);
                id3->addFrame(frame);
            }
            frame->setText(TagLib::String(composer.UTF8String, TagLib::String::UTF8));
        }
    }
    if (!file.save()) {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Failed to save MP3 tags"}];
        }
        return NO;
    }
    return YES;
}

#pragma mark - MP4 (M4A/AAC)

+ (NSDictionary<NSString *, id> *)readMP4Tags:(NSString *)path error:(NSError **)error {
    TagLib::MP4::File file(path.UTF8String, false);
    TagLib::MP4::Tag *tag = file.tag();
    if (!tag) {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP4 tag"}];
        }
        return @{};
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    TagLib::String titleKey("\xA9""nam", TagLib::String::Latin1);
    TagLib::String artistKey("\xA9""ART", TagLib::String::Latin1);
    TagLib::String albumKey("\xA9""alb", TagLib::String::Latin1);
    TagLib::String albumArtistKey("aART", TagLib::String::Latin1);
    TagLib::String composerKey("\xA9""wrt", TagLib::String::Latin1);
    TagLib::String genreKey("\xA9""gen", TagLib::String::Latin1);
    TagLib::String commentKey("\xA9""cmt", TagLib::String::Latin1);
    TagLib::String yearKey("\xA9""day", TagLib::String::Latin1);
    TagLib::String trknKey("trkn", TagLib::String::Latin1);
    TagLib::String diskKey("disk", TagLib::String::Latin1);
    TagLib::String covrKey("covr", TagLib::String::Latin1);

    if (tag->contains(titleKey)) dict[@"title"] = nsStringFromTagString(tag->item(titleKey).toStringList().toString());
    if (tag->contains(artistKey)) dict[@"artist"] = nsStringFromTagString(tag->item(artistKey).toStringList().toString());
    if (tag->contains(albumKey)) dict[@"album"] = nsStringFromTagString(tag->item(albumKey).toStringList().toString());
    if (tag->contains(albumArtistKey)) dict[@"albumArtist"] = nsStringFromTagString(tag->item(albumArtistKey).toStringList().toString());
    if (tag->contains(composerKey)) dict[@"composer"] = nsStringFromTagString(tag->item(composerKey).toStringList().toString());
    if (tag->contains(genreKey)) dict[@"genre"] = nsStringFromTagString(tag->item(genreKey).toStringList().toString());
    if (tag->contains(commentKey)) dict[@"comment"] = nsStringFromTagString(tag->item(commentKey).toStringList().toString());
    if (tag->contains(yearKey)) dict[@"year"] = nsStringFromTagString(tag->item(yearKey).toStringList().toString());

    if (tag->contains(trknKey)) {
        auto pair = tag->item(trknKey).toIntPair();
        dict[@"trackNumber"] = @(pair.first);
        dict[@"trackTotal"] = @(pair.second);
    }

    if (tag->contains(diskKey)) {
        auto pair = tag->item(diskKey).toIntPair();
        dict[@"discNumber"] = @(pair.first);
        dict[@"discTotal"] = @(pair.second);
    }

    if (tag->contains(covrKey)) {
        TagLib::ByteVectorList list = tag->item(covrKey).toByteVectorList();
        if (!list.isEmpty()) {
            const TagLib::ByteVector &bv = list.front();
            NSData *data = [NSData dataWithBytes:bv.data() length:bv.size()];
            if (data) {
                dict[@"coverImageData"] = data;
            }
        }
    }

    return dict;
}

+ (BOOL)writeMP4Tags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::MP4::File file(path.UTF8String, false);
    TagLib::MP4::Tag *tag = file.tag();
    if (!tag) {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MP4 tag"}];
        }
        return NO;
    }

    NSString *title = ([tags[@"title"] isKindOfClass:[NSString class]]) ? tags[@"title"] : nil;
    NSString *artist = ([tags[@"artist"] isKindOfClass:[NSString class]]) ? tags[@"artist"] : nil;
    NSString *album = ([tags[@"album"] isKindOfClass:[NSString class]]) ? tags[@"album"] : nil;
    NSString *albumArtist = ([tags[@"albumArtist"] isKindOfClass:[NSString class]]) ? tags[@"albumArtist"] : nil;
    NSString *composer = ([tags[@"composer"] isKindOfClass:[NSString class]]) ? tags[@"composer"] : nil;
    NSString *comment = ([tags[@"comment"] isKindOfClass:[NSString class]]) ? tags[@"comment"] : nil;
    NSString *genre = ([tags[@"genre"] isKindOfClass:[NSString class]]) ? tags[@"genre"] : nil;
    NSString *year = ([tags[@"year"] isKindOfClass:[NSString class]]) ? tags[@"year"] : nil;
    NSNumber *trackNumber = ([tags[@"trackNumber"] isKindOfClass:[NSNumber class]]) ? tags[@"trackNumber"] : nil;
    NSNumber *trackTotal = ([tags[@"trackTotal"] isKindOfClass:[NSNumber class]]) ? tags[@"trackTotal"] : nil;
    NSNumber *discNumber = ([tags[@"discNumber"] isKindOfClass:[NSNumber class]]) ? tags[@"discNumber"] : nil;
    NSNumber *discTotal = ([tags[@"discTotal"] isKindOfClass:[NSNumber class]]) ? tags[@"discTotal"] : nil;
    id coverObj = tags[@"coverImageData"];
    NSData *coverData = ([coverObj isKindOfClass:[NSData class]]) ? (NSData *)coverObj : nil;

    if (title) tag->setItem("\xA9""nam", mp4ItemFromNSString(title));
    if (artist) tag->setItem("\xA9""ART", mp4ItemFromNSString(artist));
    if (album) tag->setItem("\xA9""alb", mp4ItemFromNSString(album));
    if (albumArtist) tag->setItem("aART", mp4ItemFromNSString(albumArtist));
    if (composer) tag->setItem("\xA9""wrt", mp4ItemFromNSString(composer));
    if (genre) tag->setItem("\xA9""gen", mp4ItemFromNSString(genre));
    if (comment) tag->setItem("\xA9""cmt", mp4ItemFromNSString(comment));
    if (year) tag->setItem("\xA9""day", mp4ItemFromNSString(year));
    if (trackNumber || trackTotal) {
        int num = trackNumber ? trackNumber.intValue : 0;
        int total = trackTotal ? trackTotal.intValue : 0;
        tag->setItem("trkn", TagLib::MP4::Item(num, total));
    } else {
        tag->removeItem("trkn");
    }

    if (discNumber || discTotal) {
        int num = discNumber ? discNumber.intValue : 0;
        int total = discTotal ? discTotal.intValue : 0;
        tag->setItem("disk", TagLib::MP4::Item(num, total));
    } else {
        tag->removeItem("disk");
    }

    if (coverData && coverData.length > 0) {
        TagLib::ByteVector bv((const char *)coverData.bytes, (unsigned int)coverData.length);
        TagLib::ByteVectorList list;
        list.append(bv);
        tag->setItem("covr", TagLib::MP4::Item(list));
    } else {
        tag->removeItem("covr");
    }

    if (!file.save()) {
        if (error) {
            *error = [NSError errorWithDomain:@"TagLibBridge" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Failed to save MP4 tags"}];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Helpers for common/Xiph

static void fillCommon(TagLib::Tag *t, NSMutableDictionary *dict) {
    dict[@"title"] = nsStringFromTagString(t->title());
    dict[@"artist"] = nsStringFromTagString(t->artist());
    dict[@"album"] = nsStringFromTagString(t->album());
    dict[@"comment"] = nsStringFromTagString(t->comment());
    dict[@"genre"] = nsStringFromTagString(t->genre());
    dict[@"year"] = @(t->year());
    dict[@"trackNumber"] = @(t->track());
}

static void applyCommon(TagLib::Tag *t, NSDictionary *tags) {
    NSString *title = tags[@"title"];
    NSString *artist = tags[@"artist"];
    NSString *album = tags[@"album"];
    NSString *comment = tags[@"comment"];
    NSString *genre = tags[@"genre"];
    NSNumber *year = ([tags[@"year"] isKindOfClass:[NSNumber class]]) ? tags[@"year"] : nil;
    NSNumber *trackNumber = ([tags[@"trackNumber"] isKindOfClass:[NSNumber class]]) ? tags[@"trackNumber"] : nil;
    if (title) t->setTitle(TagLib::String(title.UTF8String, TagLib::String::UTF8));
    if (artist) t->setArtist(TagLib::String(artist.UTF8String, TagLib::String::UTF8));
    if (album) t->setAlbum(TagLib::String(album.UTF8String, TagLib::String::UTF8));
    if (comment) t->setComment(TagLib::String(comment.UTF8String, TagLib::String::UTF8));
    if (genre) t->setGenre(TagLib::String(genre.UTF8String, TagLib::String::UTF8));
    if (year) t->setYear(year.unsignedShortValue);
    if (trackNumber) t->setTrack(trackNumber.unsignedShortValue);
}

static void applyXiphFields(TagLib::Ogg::XiphComment *xiph, NSDictionary *tags) {
    if (!xiph) return;
    NSString *albumArtist = tags[@"albumArtist"];
    NSString *composer = tags[@"composer"];
    NSNumber *trackTotal = tags[@"trackTotal"];
    NSNumber *discNumber = tags[@"discNumber"];
    NSNumber *discTotal = tags[@"discTotal"];
    if (albumArtist) xiph->addField("ALBUMARTIST", TagLib::String(albumArtist.UTF8String, TagLib::String::UTF8), true);
    if (composer) xiph->addField("COMPOSER", TagLib::String(composer.UTF8String, TagLib::String::UTF8), true);
    if (trackTotal) xiph->addField("TRACKTOTAL", TagLib::String(std::to_string(trackTotal.intValue)), true);
    if (discNumber) xiph->addField("DISCNUMBER", TagLib::String(std::to_string(discNumber.intValue)), true);
    if (discTotal) xiph->addField("DISCTOTAL", TagLib::String(std::to_string(discTotal.intValue)), true);
}

static void fillXiphFields(TagLib::Ogg::XiphComment *xiph, NSMutableDictionary *dict) {
    if (!xiph) return;
    TagLib::Ogg::FieldListMap map = xiph->fieldListMap();
    dict[@"albumArtist"] = nsStringFromTagString(map["ALBUMARTIST"].toString());
    dict[@"composer"] = nsStringFromTagString(map["COMPOSER"].toString());
    dict[@"trackTotal"] = @(map["TRACKTOTAL"].toString().toInt());
    dict[@"discNumber"] = @(map["DISCNUMBER"].toString().toInt());
    dict[@"discTotal"] = @(map["DISCTOTAL"].toString().toInt());
}

static void fillXiphCover(TagLib::Ogg::XiphComment *xiph, NSMutableDictionary *dict) {
    if (!xiph) return;
    TagLib::List<TagLib::FLAC::Picture *> pics = xiph->pictureList();
    if (!pics.isEmpty()) {
        TagLib::FLAC::Picture *pic = pics.front();
        dict[@"coverImageData"] = [NSData dataWithBytes:pic->data().data() length:pic->data().size()];
        return;
    }
    TagLib::Ogg::FieldListMap map = xiph->fieldListMap();
    auto it = map.find("METADATA_BLOCK_PICTURE");
    if (it != map.end() && !it->second.isEmpty()) {
        TagLib::String b64 = it->second.front();
        TagLib::ByteVector data = TagLib::ByteVector::fromBase64(b64.toCString(true));
        TagLib::FLAC::Picture pic;
        if (pic.parse(data)) {
            dict[@"coverImageData"] = [NSData dataWithBytes:pic.data().data() length:pic.data().size()];
        }
    }
}

static void applyXiphCover(TagLib::Ogg::XiphComment *xiph, NSData *coverData) {
    if (!xiph) return;
    xiph->removeFields("METADATA_BLOCK_PICTURE");
    if (!coverData || coverData.length == 0) return;
    TagLib::FLAC::Picture pic;
    pic.setType(TagLib::FLAC::Picture::FrontCover);
    pic.setMimeType("image/jpeg");
    pic.setData(TagLib::ByteVector((const char *)coverData.bytes, (unsigned int)coverData.length));
    TagLib::ByteVector rendered = pic.render();
    TagLib::ByteVector b64 = rendered.toBase64();
    xiph->addField("METADATA_BLOCK_PICTURE", TagLib::String(b64.data(), TagLib::String::UTF8), true);
}

#pragma mark - FLAC

+ (NSDictionary<NSString *, id> *)readFLACTags:(NSString *)path error:(NSError **)error {
    TagLib::FLAC::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:5 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open FLAC"}];
        return @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    fillCommon(file.tag(), dict);
    fillXiphFields(file.xiphComment(), dict);
    fillXiphCover(file.xiphComment(), dict);
    TagLib::List<TagLib::FLAC::Picture *> pics = file.pictureList();
    if (!pics.isEmpty()) {
        TagLib::FLAC::Picture *pic = pics.front();
        dict[@"coverImageData"] = [NSData dataWithBytes:pic->data().data() length:pic->data().size()];
    }
    return dict;
}

+ (BOOL)writeFLACTags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::FLAC::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:6 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open FLAC"}];
        return NO;
    }
    applyCommon(file.tag(), tags);
    TagLib::Ogg::XiphComment *xiph = file.xiphComment(true);
    applyXiphFields(xiph, tags);
    applyXiphCover(xiph, ([tags[@"coverImageData"] isKindOfClass:[NSData class]]) ? tags[@"coverImageData"] : nil);

    id coverObj = tags[@"coverImageData"];
    NSData *coverData = ([coverObj isKindOfClass:[NSData class]]) ? (NSData *)coverObj : nil;
    if (coverData && coverData.length > 0) {
        TagLib::List<TagLib::FLAC::Picture *> pics = file.pictureList();
        for (auto it = pics.begin(); it != pics.end(); ++it) {
            file.removePicture(*it);
        }
        TagLib::FLAC::Picture *pic = new TagLib::FLAC::Picture;
        pic->setType(TagLib::FLAC::Picture::FrontCover);
        pic->setMimeType("image/jpeg");
        pic->setData(TagLib::ByteVector((const char *)coverData.bytes, (unsigned int)coverData.length));
        file.addPicture(pic);
    }
    return file.save();
}

#pragma mark - OGG Vorbis

+ (NSDictionary<NSString *, id> *)readOGGTags:(NSString *)path error:(NSError **)error {
    TagLib::Ogg::Vorbis::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:7 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open OGG"}];
        return @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    fillCommon(file.tag(), dict);
    fillXiphFields(file.tag(), dict);
    fillXiphCover(file.tag(), dict);
    return dict;
}

+ (BOOL)writeOGGTags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::Ogg::Vorbis::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:8 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open OGG"}];
        return NO;
    }
    applyCommon(file.tag(), tags);
    applyXiphFields(file.tag(), tags);
    applyXiphCover(file.tag(), ([tags[@"coverImageData"] isKindOfClass:[NSData class]]) ? tags[@"coverImageData"] : nil);
    return file.save();
}

#pragma mark - Opus

+ (NSDictionary<NSString *, id> *)readOpusTags:(NSString *)path error:(NSError **)error {
    TagLib::Ogg::Opus::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:9 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open Opus"}];
        return @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    fillCommon(file.tag(), dict);
    fillXiphFields(file.tag(), dict);
    fillXiphCover(file.tag(), dict);
    return dict;
}

+ (BOOL)writeOpusTags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::Ogg::Opus::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:10 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open Opus"}];
        return NO;
    }
    applyCommon(file.tag(), tags);
    applyXiphFields(file.tag(), tags);
    applyXiphCover(file.tag(), ([tags[@"coverImageData"] isKindOfClass:[NSData class]]) ? tags[@"coverImageData"] : nil);
    return file.save();
}

#pragma mark - WavPack

+ (NSDictionary<NSString *, id> *)readWavPackTags:(NSString *)path error:(NSError **)error {
    TagLib::WavPack::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:11 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open WavPack"}];
        return @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    fillCommon(file.tag(), dict);
    return dict;
}

+ (BOOL)writeWavPackTags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::WavPack::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:12 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open WavPack"}];
        return NO;
    }
    applyCommon(file.tag(), tags);
    return file.save();
}

#pragma mark - MPC

+ (NSDictionary<NSString *, id> *)readMPCTags:(NSString *)path error:(NSError **)error {
    TagLib::MPC::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:13 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MPC"}];
        return @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    fillCommon(file.tag(), dict);
    return dict;
}

+ (BOOL)writeMPCTags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::MPC::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:14 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open MPC"}];
        return NO;
    }
    applyCommon(file.tag(), tags);
    return file.save();
}

#pragma mark - DSF

+ (NSDictionary<NSString *, id> *)readDSFTags:(NSString *)path error:(NSError **)error {
    TagLib::DSF::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:15 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open DSF"}];
        return @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    fillCommon(file.tag(), dict);
    return dict;
}

+ (BOOL)writeDSFTags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::DSF::File file(path.UTF8String, false);
    if (!file.isOpen() || !file.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:16 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open DSF"}];
        return NO;
    }
    applyCommon(file.tag(), tags);
    return file.save();
}

#pragma mark - Generic for WAV/AIFF

+ (NSDictionary<NSString *, id> *)readGenericTags:(NSString *)path error:(NSError **)error {
    TagLib::FileRef ref(path.UTF8String);
    if (ref.isNull() || !ref.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:17 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open tag"}];
        return @{};
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    fillCommon(ref.tag(), dict);
    dict[@"albumArtist"] = @"";
    dict[@"composer"] = @"";
    dict[@"trackTotal"] = @(0);
    dict[@"discNumber"] = @(0);
    dict[@"discTotal"] = @(0);
    return dict;
}

+ (BOOL)writeGenericTags:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
    TagLib::FileRef ref(path.UTF8String);
    if (ref.isNull() || !ref.tag()) {
        if (error) *error = [NSError errorWithDomain:@"TagLibBridge" code:18 userInfo:@{NSLocalizedDescriptionKey: @"Cannot open tag"}];
        return NO;
    }
    applyCommon(ref.tag(), tags);
    return ref.save();
}

@end
