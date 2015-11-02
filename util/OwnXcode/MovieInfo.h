/*
// From NSPathUtilities.h
//  typedef NS_ENUM(NSUInteger, NSSearchPathDirectory) {
//  ......
//  };
// From NSObjCRuntime.h
//  #define NS_ENUM(_type, _name) CF_ENUM(_type, _name)
// From CFAvailability.h
//  #define CF_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef NS_ENUM(char, MIDownloaded) {
    MINotModified = 0,
    MIDownloadedDone = 1,
    MIDownloadedFailed = 2
};
 */
@interface MovieInfo : NSObject
@property (copy) NSString *name;
@property unsigned long long size;
@property (copy) NSString *sha1;
@property unsigned int width0, height0;
@property float duration0;
@property unsigned int x, y;
@property unsigned int width;
@property unsigned int duration;

- (void)printWithIndent:(NSString *)indent0;
+ (NSArray *)parse:(NSString *)movieInfoStr;
@end
