#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Placeholder Matroska bridge. Currently returns unsupported; intended to be replaced with FFmpeg/libmatroska integration.
@interface MatroskaBridge : NSObject

+ (NSDictionary<NSString *, id> *)readTagsAtPath:(NSString *)path error:(NSError **)error;
+ (BOOL)writeTagsAtPath:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
