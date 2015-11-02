#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif
#ifndef ALog
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#import <Foundation/Foundation.h>

#define OPInt(i) [NSNumber numberWithInt:i]
#define OPInteger(i) [NSNumber numberWithInteger:i]
#define OPUInteger(i) [NSNumber numberWithUnsignedInteger:i]
#define OPNSSearchPathDirectory_by_NSUInteger(i) NSSearchPathDirectory_by_NSUInteger[[NSNumber numberWithUnsignedInteger:i]]

// initialized once and only once in OwnUtil.initialize
static BOOL TRACE = 0;
static NSDictionary *NSSearchPathDirectory_by_NSUInteger;
static NSDictionary *NSSearchPathDirectory_by_NSString;
static NSDictionary *NSSearchPathDomainMask_by_NString;
static NSArray *ALAssetPropertyKeys;

@interface OwnUtil : NSObject

+ (NSURL *)NET_PUT_URL;
+ (NSURL *)NET_GET_URL;
+ (NSURL *)MOVIE_INFO_URL;
+ (NSString *)BUNDLE_IDENTIFIER;
+ (NSString *)BUNDLE_NAME;
+ (NSString *)BUNDLE_VERSION;
+ (NSString *)BUNDLE_BUILD;

+ (void)lsDir:(NSString *)dirPath;
+ (void)lsAssetsLibrary;
+ (void)catAsset:(NSURL *)assetURL;
+ (void)lsAll;
+ (void)lsAllBundle;
+ (void)lsBundle:(NSString *)bundleBasename;
    // file0: "banklist.sqlite3"
    // bundleBasename: "db" from "db.bundle"
    // dirType: NSDocumentDirectory
+ (NSURL *)copyFile:(NSString *)filename0 inBundle:(NSString *)bundleBasename to:(NSSearchPathDirectory)dirType under:(NSString *)subDirPath;

+ (NSString *)sha1:(NSString *)filePath;

@end
