#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Thin Objective-C++ bridge surface for TagLib. Implementation will be filled as we integrate the library.
@interface TagLibBridge : NSObject

/// Reads tags into a dictionary with Swift-friendly value types. Returns empty dictionary on failure and sets error.
+ (NSDictionary<NSString *, id> *)readTagsAtPath:(NSString *)path error:(NSError **)error;

/// Writes the given tags. The expected keys/values will be enforced in the Swift layer before calling.
+ (BOOL)writeTagsAtPath:(NSString *)path tags:(NSDictionary<NSString *, id> *)tags error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
