// Taken from
//  https://developer.apple.com/library/prerelease/ios/samplecode/SimpleURLConnections/Introduction/Intro.html

typedef void (^NetPutProgressUpdateBlock)(int progress);  // [0, 100]
typedef void (^NetPutEndBlock)(NSInteger statusCode, NSString *remoteFilePath);   //
/*
    statusCode:
        http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html
    remoteFilePath: 200
        nil means some errors (See connection:didReceiveResponse in NetPut.m)
 */
/*
@protocol NetPutDelegate

- (void) done:(NSString *)statusString pathnameURL:pathnameURL;

@end
 */


@interface NetPut : NSObject

//@property (nonatomic, strong) id<NetPutDelegate> delegate;

- (BOOL)send:(NSURL *)pathnameURL to:(NSURL *)url headers:(NSDictionary *)headers onProgressUpdate:(NetPutProgressUpdateBlock)progressUpdateBlock onEnd:(NetPutEndBlock)endBlock;

@end
