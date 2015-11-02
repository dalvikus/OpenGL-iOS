typedef void (^DownloadMovieProgressUpdateBlock)(int progress);  // [0, 100]
typedef void (^DownloadMovieEndBlock)(NSArray *movies, NSDictionary *statusCode_d);
/*
    statusCode: NSNumber
    > 0:
        http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html
    0:
        SHA1 matched; not necessary to call NetGet
    -1: (See NetGet.h)
        statusCode = 205 (Reset Content) but no "Content-Length" or mismatch between "Content-Length" and the number of received bytes
    -2: (See NetGet.h)
        statusCode = 205 (Reset Content) and given sha1sum given does not match with one calculated from stream
    -3: See connection:didReceiveResponse: in DownloadMovie.m
        failed to call NetGet:get:from:movie:onEnd:
 */

@interface DownloadMovie : NSObject
- (BOOL)updateMovies:(NSURL *)pathnameURL from:(NSURL *)url onProgressUpdate:(DownloadMovieProgressUpdateBlock)progressUpdateBlock onEnd:(DownloadMovieEndBlock)endBlock;
@end
