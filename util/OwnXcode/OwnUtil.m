#include <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "OwnUtil.h"

@implementation OwnUtil

// http://stackoverflow.com/questions/22534251/static-nsdictionary-const-lettervalues-in-a-method-does-not-compil
// http://stackoverflow.com/questions/13326435/nsobject-load-and-initialize-what-do-they-do
// https://mikeash.com/pyblog/friday-qa-2009-05-22-objective-c-class-loading-and-initialization.html
+ (void)initialize
{
    if (self == [OwnUtil class]) {
/*
enum {
   NSApplicationDirectory = 1,
   NSDemoApplicationDirectory,
   NSDeveloperApplicationDirectory,
   NSAdminApplicationDirectory,
   NSLibraryDirectory,
   NSDeveloperDirectory,
   NSUserDirectory,
   NSDocumentationDirectory,
   NSDocumentDirectory,
   NSCoreServiceDirectory,
   NSAutosavedInformationDirectory = 11,
   NSDesktopDirectory = 12,
   NSCachesDirectory = 13,
   NSApplicationSupportDirectory = 14,
   NSDownloadsDirectory = 15,
   NSInputMethodsDirectory = 16,
   NSMoviesDirectory = 17,
   NSMusicDirectory = 18,
   NSPicturesDirectory = 19,
   NSPrinterDescriptionDirectory = 20,
   NSSharedPublicDirectory = 21,
   NSPreferencePanesDirectory = 22,
   NSItemReplacementDirectory = 99,
   NSAllApplicationsDirectory = 100,
   NSAllLibrariesDirectory = 101,
};
typedef NSUInteger NSSearchPathDirectory;
 */
        NSSearchPathDirectory_by_NSString = @{
            @"NSApplicationDirectory": [NSNumber numberWithUnsignedInteger:NSApplicationDirectory],
            @"NSDemoApplicationDirectory": [NSNumber numberWithUnsignedInteger:NSDemoApplicationDirectory],
            @"NSDeveloperApplicationDirectory": [NSNumber numberWithUnsignedInteger:NSDeveloperApplicationDirectory],
            @"NSAdminApplicationDirectory": [NSNumber numberWithUnsignedInteger:NSAdminApplicationDirectory],
            @"NSLibraryDirectory": [NSNumber numberWithUnsignedInteger:NSLibraryDirectory],
            @"NSDeveloperDirectory": [NSNumber numberWithUnsignedInteger:NSDeveloperDirectory],
            @"NSUserDirectory": [NSNumber numberWithUnsignedInteger:NSUserDirectory],
            @"NSDocumentationDirectory": [NSNumber numberWithUnsignedInteger:NSDocumentationDirectory],
            @"NSDocumentDirectory": [NSNumber numberWithUnsignedInteger:NSDocumentDirectory],
            @"NSCoreServiceDirectory": [NSNumber numberWithUnsignedInteger:NSCoreServiceDirectory],
            @"NSAutosavedInformationDirectory": [NSNumber numberWithUnsignedInteger:NSAutosavedInformationDirectory],
            @"NSDesktopDirectory": [NSNumber numberWithUnsignedInteger:NSDesktopDirectory],
            @"NSCachesDirectory": [NSNumber numberWithUnsignedInteger:NSCachesDirectory],
            @"NSApplicationSupportDirectory": [NSNumber numberWithUnsignedInteger:NSApplicationSupportDirectory],
            @"NSDownloadsDirectory": [NSNumber numberWithUnsignedInteger:NSDownloadsDirectory],
            @"NSInputMethodsDirectory": [NSNumber numberWithUnsignedInteger:NSInputMethodsDirectory],
            @"NSMoviesDirectory": [NSNumber numberWithUnsignedInteger:NSMoviesDirectory],
            @"NSMusicDirectory": [NSNumber numberWithUnsignedInteger:NSMusicDirectory],
            @"NSPicturesDirectory": [NSNumber numberWithUnsignedInteger:NSPicturesDirectory],
            @"NSPrinterDescriptionDirectory": [NSNumber numberWithUnsignedInteger:NSPrinterDescriptionDirectory],
            @"NSSharedPublicDirectory": [NSNumber numberWithUnsignedInteger:NSSharedPublicDirectory],
            @"NSPreferencePanesDirectory": [NSNumber numberWithUnsignedInteger:NSPreferencePanesDirectory],
            @"NSItemReplacementDirectory": [NSNumber numberWithUnsignedInteger:NSItemReplacementDirectory],
            @"NSAllApplicationsDirectory": [NSNumber numberWithUnsignedInteger:NSAllApplicationsDirectory],
            @"NSAllLibrariesDirectory": [NSNumber numberWithUnsignedInteger:NSAllLibrariesDirectory],
        };
        NSSearchPathDirectory_by_NSUInteger = @{
            [NSNumber numberWithUnsignedInteger:NSApplicationSupportDirectory]: @"One",
            [NSNumber numberWithUnsignedInteger:NSApplicationDirectory]: @"NSApplicationDirectory",
            [NSNumber numberWithUnsignedInteger:NSDemoApplicationDirectory]: @"NSDemoApplicationDirectory",
            [NSNumber numberWithUnsignedInteger:NSDeveloperApplicationDirectory]: @"NSDeveloperApplicationDirectory",
            [NSNumber numberWithUnsignedInteger:NSAdminApplicationDirectory]: @"NSAdminApplicationDirectory",
            [NSNumber numberWithUnsignedInteger:NSLibraryDirectory]: @"NSLibraryDirectory",
            [NSNumber numberWithUnsignedInteger:NSDeveloperDirectory]: @"NSDeveloperDirectory",
            [NSNumber numberWithUnsignedInteger:NSUserDirectory]: @"NSUserDirectory",
            [NSNumber numberWithUnsignedInteger:NSDocumentationDirectory]: @"NSDocumentationDirectory",
            [NSNumber numberWithUnsignedInteger:NSDocumentDirectory]: @"NSDocumentDirectory",
            [NSNumber numberWithUnsignedInteger:NSCoreServiceDirectory]: @"NSCoreServiceDirectory",
            [NSNumber numberWithUnsignedInteger:NSAutosavedInformationDirectory]: @"NSAutosavedInformationDirectory",
            [NSNumber numberWithUnsignedInteger:NSDesktopDirectory]: @"NSDesktopDirectory",
            [NSNumber numberWithUnsignedInteger:NSCachesDirectory]: @"NSCachesDirectory",
            [NSNumber numberWithUnsignedInteger:NSApplicationSupportDirectory]: @"NSApplicationSupportDirectory",
            [NSNumber numberWithUnsignedInteger:NSDownloadsDirectory]: @"NSDownloadsDirectory",
            [NSNumber numberWithUnsignedInteger:NSInputMethodsDirectory]: @"NSInputMethodsDirectory",
            [NSNumber numberWithUnsignedInteger:NSMoviesDirectory]: @"NSMoviesDirectory",
            [NSNumber numberWithUnsignedInteger:NSMusicDirectory]: @"NSMusicDirectory",
            [NSNumber numberWithUnsignedInteger:NSPicturesDirectory]: @"NSPicturesDirectory",
            [NSNumber numberWithUnsignedInteger:NSPrinterDescriptionDirectory]: @"NSPrinterDescriptionDirectory",
            [NSNumber numberWithUnsignedInteger:NSSharedPublicDirectory]: @"NSSharedPublicDirectory",
            [NSNumber numberWithUnsignedInteger:NSPreferencePanesDirectory]: @"NSPreferencePanesDirectory",
            [NSNumber numberWithUnsignedInteger:NSItemReplacementDirectory]: @"NSItemReplacementDirectory",
            [NSNumber numberWithUnsignedInteger:NSAllApplicationsDirectory]: @"NSAllApplicationsDirectory",
            [NSNumber numberWithUnsignedInteger:NSAllLibrariesDirectory]: @"NSAllLibrariesDirectory",
        };
/*
enum {
   NSUserDomainMask = 1,
   NSLocalDomainMask = 2,
   NSNetworkDomainMask = 4,
   NSSystemDomainMask = 8,
   NSAllDomainsMask = 0x0ffff,
};
typedef NSUInteger NSSearchPathDomainMask;
 */
        NSSearchPathDomainMask_by_NString = @{
            @"NSUserDomainMask": [NSNumber numberWithUnsignedInteger:NSUserDomainMask],
            @"NSLocalDomainMask": [NSNumber numberWithUnsignedInteger:NSLocalDomainMask],
            @"NSNetworkDomainMask": [NSNumber numberWithUnsignedInteger:NSNetworkDomainMask],
            @"NSSystemDomainMask": [NSNumber numberWithUnsignedInteger:NSSystemDomainMask],
            @"NSAllDomainsMask": [NSNumber numberWithUnsignedInteger:NSAllDomainsMask],
        };
/*
NSString *const ALAssetPropertyType;
NSString *const ALAssetPropertyLocation;
NSString *const ALAssetPropertyDuration;
NSString *const ALAssetPropertyOrientation;
NSString *const ALAssetPropertyDate;
NSString *const ALAssetPropertyRepresentations;
NSString *const ALAssetPropertyURLs;
NSString *const ALAssetPropertyAssetURL;
 */
            ALAssetPropertyKeys = @[
                ALAssetPropertyType,
                ALAssetPropertyLocation,
                ALAssetPropertyDuration,
                ALAssetPropertyOrientation,
                ALAssetPropertyDate,
                ALAssetPropertyRepresentations,
                ALAssetPropertyURLs,
                ALAssetPropertyAssetURL,
            ];
    }
}
/*
+ (void)load
{
}
 */

+ (NSURL *)NET_PUT_URL
{
    return [NSURL URLWithString:@"https://ownphones.com/unity/net_put.php"];
}
+ (NSURL *)NET_GET_URL
{
    return [NSURL URLWithString:@"https://ownphones.com/unity/net_get.php"];
}
+ (NSURL *)MOVIE_INFO_URL
{
    return [NSURL URLWithString:@"https://ownphones.com/unity/get_movie_info.php"];
}
+ (NSString *)BUNDLE_IDENTIFIER
{
    return [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleIdentifier"];
}
+ (NSString *)BUNDLE_NAME
{
    return [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleName"];
}
// CFBundleShortVersionString in Info.plist
+ (NSString *)BUNDLE_VERSION
{
//ALog(@"CFBundleShortVersionString: |%@|", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
    return [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleShortVersionString"];
}
// CFBundleVersion in Info.plist
+ (NSString *)BUNDLE_BUILD
{
    return [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleVersion"];
}

+ (void)lsDir:(NSString *)dirPath
{
    if (!dirPath) {
        ALog(@"dirPath is null");
        return;
    }
    ALog(@"dirPath: |%@|", dirPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err = nil;
    NSArray *strFileArray = [fileManager contentsOfDirectoryAtPath:dirPath error:&err];
    if (err) {
        ALog(@"ERR: |%@|: |%@|", dirPath, err);
        return;
    }
    if (![strFileArray count]) {
        ALog(@"INFO: no files");
        return;
    }
    for (NSString *filename in strFileArray) {
        ALog(@" filename: %@", filename);
        NSString *pathname = [dirPath stringByAppendingPathComponent:filename];
        err = nil;
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:pathname error:&err];
        if (err) {
            ALog(@" fileSize: ERR: %@", err);
        } else {
            unsigned long long fileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
            ALog(@" fileSize: %llu", fileSize);
        }
    }
}

+ (void)lsAssetsLibrary
{
    ALAssetsLibrary *assets_library = [[ALAssetsLibrary alloc] init];
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        ALog(@"ALAssetsGroup enumerateAssetsUsingBlock: asset: |%@|", asset);
        ALog(@"ALAssetsGroup enumerateAssetsUsingBlock: asset: index = %@", OPUInteger(index));
        ALog(@"ALAssetsGroup enumerateAssetsUsingBlock: asset: stop? %s", *stop ? "Yes" : "No");
    };
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        ALog(@"ALAssetsLibrary enumerateGroupsWithTypes:usingBlock:failureBlock: group: |%@|", group);
        ALog(@"ALAssetsLibrary enumerateGroupsWithTypes:usingBlock:failureBlock: stop? %s", *stop ? "Yes" : "No");
        if (group) {
            //*stop = YES;
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    if (assets_library) {
        [assets_library
            enumerateGroupsWithTypes:ALAssetsGroupAll

            usingBlock:assetGroupEnumerator

            failureBlock:^(NSError *err) {
                NSLog(@"ALAssetsLibrary enumerateGroupsWithTypes:usingBlock:failureBlock: %@", err);
            }
        ];
    }
}
+ (void)catAsset:(NSURL *)assetURL
{
    ALog(@"%@", assetURL);
    __block NSString *filename = nil;
    void (^resultBlock)(ALAsset *asset) = ^(ALAsset *asset) {
            ALog(@"%@", asset);

            for (NSString *PropertyKey in ALAssetPropertyKeys) {
                ALog(@"    Key: |%@|", PropertyKey);
                ALog(@"    Value: |%@|", [asset valueForProperty:PropertyKey]);
            }

            ALAssetRepresentation *repr = [asset defaultRepresentation];
            ALog(@"repr: |%@|", repr);
            if (repr) {
                ALog(@"    filename: |%@|", repr.filename);
                filename = repr.filename;
                CGSize size = repr.dimensions;
                ALog(@"    dimension: %fx%f", size.width, size.height);
                ALog(@"    size: %lld", repr.size);
                NSDictionary *meta_d = repr.metadata;
                ALog(@"    meta: |%@|: ...", meta_d);
                for (NSString *key in meta_d) {
                    ALog(@"        |%@|", key);
                }
            }
        };
    [[[ALAssetsLibrary alloc] init]
        assetForURL:assetURL 
        resultBlock:resultBlock
        failureBlock:^(NSError *err) {
            ALog(@"%@", err);
        }
    ];
    ALog(@"|%@|: |%@|", assetURL, filename);
}

/*!
 *  NSSearchPathForDirectoriesInDomains
 *
 *  equivalent to
 *
 *  NSFileManager's method URLsForDirectory:inDomains:
 */
+ (void)lsAll
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *dir_key in NSSearchPathDirectory_by_NSString) {
        for (NSString *domain_mask_key in NSSearchPathDomainMask_by_NString) {
            ALog(@"NSSearchPathDirectory: |%@|", dir_key);
            ALog(@" NSSearchPathDomainMask: |%@|", domain_mask_key);
            NSUInteger dir = [NSSearchPathDirectory_by_NSString[dir_key] unsignedIntegerValue];
            NSUInteger domain_mask = [NSSearchPathDomainMask_by_NString[domain_mask_key] unsignedIntegerValue];
            NSArray *urls = [fileManager URLsForDirectory:dir inDomains:domain_mask];
            for (NSURL *url in urls) {
                ALog(@"    url: %@", url);
                ALog(@"    url.path: %@", url.path);
            }
        }
    }
}

+ (void)lsAllBundle
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    ALog(@"bundlePath: %@", mainBundle.bundlePath);
    ALog(@"builtInPlugInsPath: %@", mainBundle.builtInPlugInsPath);
    ALog(@"resourcePath: %@", mainBundle.resourcePath);
    ALog(@"sharedFrameworksPath: %@", mainBundle.sharedFrameworksPath);
    ALog(@"sharedSupportPath: %@", mainBundle.sharedSupportPath);

    ALog(@"resourcePath: ...");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *resourcePath = mainBundle.resourcePath;
    NSError *err = nil;
    NSDictionary *attrs;
    for (NSString *filename in [fileManager contentsOfDirectoryAtPath:resourcePath error:&err]) {
        ALog(@" filename: %@", filename);
        NSString *pathname = [resourcePath stringByAppendingPathComponent:filename];
        err = nil;
        attrs = [fileManager attributesOfItemAtPath:pathname error:&err];
        if (err) {
            ALog(@" fileSize: ERR: %@", err);
        } else {
            unsigned long long fileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
            ALog(@" fileSize: %llu", fileSize);
        }
    }
}

+ (void)lsBundle:(NSString *)bundleBasename
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleBasename ofType:@"bundle"];
    [OwnUtil lsDir:bundlePath];
}

+ (NSURL *)copyFile:(NSString *)filename0 inBundle:(NSString *)bundleBasename to:(NSSearchPathDirectory)dirType under:(NSString *)subDirPath
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *fileBundlePath = [mainBundle pathForResource:bundleBasename ofType:@"bundle"];
    if (TRACE) {
        ALog(@"INFO: fileBundlePath: |%@|", fileBundlePath);
    }
    if (!fileBundlePath) {
        ALog(@"ERR: |%@.bundle|: no such bundle", bundleBasename);
        return nil;
    }
    NSBundle *fileBundle = [NSBundle bundleWithPath:fileBundlePath]; 
    if (TRACE) {
        ALog(@"INFO: fileBundle: |%@|", fileBundle);
    }
    NSString *pathname0 = [fileBundle pathForResource:filename0 ofType:nil];
    if (TRACE) {
        ALog(@"INFO: pathname0: |%@|", pathname0);
    }
    if (!pathname0) {
        ALog(@"ERR: |%@|: no such file in |%@.bundle|", filename0, bundleBasename);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:pathname0 error:NULL];
    unsigned long long fileSize0 = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    if (TRACE) {
        ALog(@"INFO: file size0: %llu", fileSize0);
    }

    NSArray *urls = [fileManager URLsForDirectory:dirType inDomains:NSUserDomainMask];
    if (TRACE) {
        ALog(@"INFO: # = %@", [NSNumber numberWithUnsignedInteger:[urls count]]);
        for (NSURL *url in urls) {
            ALog(@"INFO: url: %@", url);
        }
    }
    if ([urls count] == 0) {
        //ALog(@"FATAL: none for |URLsForDirectory:%u inDomains:NSUserDomainMask|", dirType);
        ALog(@"FATAL: none for |URLsForDirectory:%@ inDomains:NSUserDomainMask|", OPNSSearchPathDirectory_by_NSUInteger(dirType));
        return nil;
    }
    if ([urls count] > 1) {
        //ALog(@"FATAL: two or more for |URLsForDirectory:%u inDomains:NSUserDomainMask|", dirType);
        ALog(@"FATAL: two or more for |URLsForDirectory:%@ inDomains:NSUserDomainMask|", OPNSSearchPathDirectory_by_NSUInteger(dirType));
        return nil;
    }
    NSURL *dirURL = [urls objectAtIndex:0];
    if (TRACE) {
        ALog(@"INFO: dirURL: |%@|", dirURL);
    }
    NSURL *underDirURL = subDirPath ? [dirURL URLByAppendingPathComponent:subDirPath] : dirURL;
    if (TRACE) {
        ALog(@"INFO: underDirURL: |%@|", underDirURL);
    }
    NSError *err = nil;
    BOOL b = [fileManager createDirectoryAtURL:underDirURL withIntermediateDirectories:YES attributes:nil error:&err];
//  ALog(@"b = %s", b ? "True" : "False");
    if (err) {
        ALog(@"Err: |%@|", err);
    }
    if (!b || err)
        return nil;
    NSString* underDirPath = [underDirURL path];
    NSString *pathname = [underDirPath stringByAppendingPathComponent:filename0];
    ALog(@"%@", pathname);
    BOOL isCopied = [fileManager fileExistsAtPath:pathname];
    if (TRACE) {
        ALog(@"INFO: Is already copied? %s", isCopied ? "Yes" : "No");
    }
    if (TRACE) {
        ALog(@"INFO: Contents in |%@|", underDirPath);
        [OwnUtil lsDir:underDirPath];
    }
    if (!isCopied) {
        NSError *err = nil;
        [fileManager copyItemAtPath:pathname0 toPath:pathname error:&err];
        if (err) {
            ALog(@"ERR: Copy failed: |%@|", [err localizedDescription]);
        } else {
            ALog(@"INFO: Copied successfully");
        }
        if (TRACE) {
            ALog(@"INFO: Contents in |%@| after copy", underDirPath);
            [OwnUtil lsDir:underDirPath];
        }
    }
    return [NSURL fileURLWithPath:pathname];
}

+ (NSString *)sha1:(NSString *)filePath
{
    if (!filePath) {
        ALog(@"ERR: filePath is nil");
        return nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    //NSInputStream *is = [[NSInputStream alloc] initWithFileAtPath:filePath];
    NSInputStream *is = [NSInputStream inputStreamWithFileAtPath:filePath];
    if (TRACE) {
        ALog(@"|%@|", is);
    }
    [is open];
    NSUInteger MAXLEN = 8192;
    uint8_t buffer[MAXLEN];
    NSInteger bytesReadInTotal = 0;
    NSInteger bytesRead;
    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    while (true) {
        if ([is hasBytesAvailable]) {   // block
            bytesRead = [is read:buffer maxLength:MAXLEN];
            if (bytesRead < 0) {
                ALog(@"ERR: |%@|: read:maxLengh: failed", filePath);
                [is close];
                return nil;
            }
            if (bytesRead == 0)
                break;
            //ALog(@"# of bytes read = %@", OPInteger(bytesRead));
            CC_SHA1_Update(&ctx, buffer, (CC_LONG) bytesRead);
            bytesReadInTotal += bytesRead;
        }
    }
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &ctx);
    NSMutableString* sha1sum = [NSMutableString stringWithCapacity:2 * CC_SHA1_DIGEST_LENGTH];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [sha1sum appendFormat:@"%02x", digest[i]];
    if (TRACE) {
        ALog(@"INFO: # of bytes = %@", OPInteger(bytesReadInTotal));
    }
    if (is) {
        [is close];
    }
    return sha1sum;
}


@end
