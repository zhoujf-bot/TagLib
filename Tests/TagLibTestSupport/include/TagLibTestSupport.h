#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kTLTestTitleKey;
extern NSString *const kTLTestArtistKey;
extern NSString *const kTLTestAlbumKey;
extern NSString *const kTLTestAlbumArtistKey;
extern NSString *const kTLTestComposerKey;
extern NSString *const kTLTestYearKey;
extern NSString *const kTLTestGenreKey;
extern NSString *const kTLTestTrackNumberKey;
extern NSString *const kTLTestTrackTotalKey;

#ifdef __cplusplus
extern "C" {
#endif

NSDictionary<NSString *, id> *TLTestReadTags(NSString *path, NSError **error);
BOOL TLTestWriteTags(NSString *path, NSDictionary<NSString *, id> *tags, NSError **error);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
