#import "OwnUtil.h"
#import "FolderHierarchy.h"

@interface FolderHierarchy ()
@property (nonatomic, readwrite) NSURL *rootDirURL;
@property (nonatomic, readwrite) NSURL *baseDirURL;
@property (nonatomic, readwrite) NSURL *playMovieDirURL;
@property (nonatomic, readwrite) NSURL *backupMovieDirURL;
@end

@implementation FolderHierarchy

- (instancetype)initWithDirType:(NSSearchPathDirectory)dirType withBaseName:(NSString*)baseName
{
    if (!baseName) {
        ALog(@"ERR: baseName is nil");
        return nil;
    }
    self = [super init];
    if (!self) {
        ALog(@"FATAL: init: failed");
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:dirType inDomains:NSUserDomainMask];
    if (TRACE) {
        ALog(@"# = %@", OPUInteger([urls count]));
    }
    if ([urls count] == 0) {
        ALog(@"FATAL: none for |URLsForDirectory:%@ inDomains:NSUserDomainMask|", OPNSSearchPathDirectory_by_NSUInteger(dirType));
        return nil;
    }
    if ([urls count] > 1) {
        ALog(@"FATAL: two or more for |URLsForDirectory:%@ inDomains:NSUserDomainMask|", OPNSSearchPathDirectory_by_NSUInteger(dirType));
        return nil;
    }
    NSURL *rootDirURL = [urls objectAtIndex:0];
    if (TRACE) {
        ALog(@"|%@|", rootDirURL);
    }

    NSError *err = nil;
    BOOL b;
    NSURL *baseDirURL = [rootDirURL URLByAppendingPathComponent:baseName];
    if (!baseDirURL) {
        ALog(@"ERR: rootDirURL: |%@|, base: |%@|", rootDirURL, baseName);
        return nil;
    }
    NSURL *playMovieDirURL = [baseDirURL URLByAppendingPathComponent:@"PlayMovie"];
    if (!playMovieDirURL) {
        ALog(@"ERR: baseDirURL: |%@|, PlayMovie: failed", baseDirURL);
        return nil;
    }
    b = [fileManager createDirectoryAtURL:playMovieDirURL withIntermediateDirectories:YES attributes:nil error:&err];
//  ALog(@"b = %s", b ? "True" : "False");
    if (err) {
        ALog(@"Err: |%@|", err);
    }
    if (!b || err)
        return nil;
    NSURL *backupMovieDirURL = [baseDirURL URLByAppendingPathComponent:@"BackupMovie"];
    if (!backupMovieDirURL) {
        ALog(@"ERR: baseDirURL: |%@|, BackupMovie: failed", baseDirURL);
        return nil;
    }
    err = nil;
    b = [fileManager createDirectoryAtURL:backupMovieDirURL withIntermediateDirectories:YES attributes:nil error:&err];
//  ALog(@"b = %s", b ? "True" : "False");
    if (err) {
        ALog(@"Err: |%@|", err);
    }
    if (!b || err)
        return nil;
    if (TRACE) {
        [OwnUtil lsDir:[rootDirURL path]];
        [OwnUtil lsDir:[baseDirURL path]];
        [OwnUtil lsDir:[playMovieDirURL path]];
    }
    self.rootDirURL = rootDirURL;
    self.baseDirURL = baseDirURL;
    self.playMovieDirURL = playMovieDirURL;
    self.backupMovieDirURL = backupMovieDirURL;
    return self;
}


@end
