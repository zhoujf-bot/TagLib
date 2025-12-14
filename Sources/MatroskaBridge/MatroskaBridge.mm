#import "MatroskaBridge.h"

#if __has_include(<matroska/KaxFile.h>)
#define MATROSKA_ENABLED 1
#import <matroska/KaxFile.h>
#import <ebml/EbmlHead.h>
#import <ebml/EbmlStream.h>
#import <ebml/EbmlVersion.h>
#endif

@implementation MatroskaBridge

+ (NSDictionary<NSString *, id> *)readTagsAtPath:(NSString *)path error:(NSError **)error {
#if MATROSKA_ENABLED
    // TODO: Implement using libmatroska/libebml when linked.
    // Expected flow:
    // 1) Open file with EbmlStream/KaxFile.
    // 2) Locate Tags element; parse SimpleTags (VorbisComment style).
    // 3) Extract common keys (TITLE/ARTIST/ALBUM/ALBUMARTIST/COMPOSER/YEAR/GENRE/TRACKNUMBER/TRACKTOTAL/DISCNUMBER/DISCTOTAL) and COVER (ATTACHMENT or METADATA_BLOCK_PICTURE).
    if (error) {
        *error = [NSError errorWithDomain:@"MatroskaBridge" code:102 userInfo:@{NSLocalizedDescriptionKey: @"Matroska support compiled in but not implemented yet."}];
    }
    return @{};
#else
    if (error) {
        *error = [NSError errorWithDomain:@"MatroskaBridge" code:100 userInfo:@{NSLocalizedDescriptionKey: @"Matroska (MKV/MKA/WebM) not supported in this build."}];
    }
    return @{};
#endif
}

+ (BOOL)writeTagsAtPath:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error {
#if MATROSKA_ENABLED
    if (error) {
        *error = [NSError errorWithDomain:@"MatroskaBridge" code:103 userInfo:@{NSLocalizedDescriptionKey: @"Matroska write not implemented yet."}];
    }
    return NO;
#else
    if (error) {
        *error = [NSError errorWithDomain:@"MatroskaBridge" code:101 userInfo:@{NSLocalizedDescriptionKey: @"Matroska (MKV/MKA/WebM) not supported in this build."}];
    }
    return NO;
#endif
}

@end
