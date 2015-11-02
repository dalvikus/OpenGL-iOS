#import <UIKit/UIKit.h>
#import "OwnUtil.h"
#import "MovieInfo.h"
#import "DownloadMovie.h"
#import "NetGet.h"
#import "NetPut.h"


@interface DownloadMovie ()

@property (copy, nonatomic) NSURL *movieDirURL;
@property (copy) DownloadMovieProgressUpdateBlock progressUpdateBlock;
@property (copy) DownloadMovieEndBlock endBlock;
@property (nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) NSArray *movies;
//@property (copy, readwrite) NSMutableArray *statusCodes;

@end


@implementation DownloadMovie

- (BOOL)updateMovies:(NSURL *)movieDirURL from:(NSURL *)url onProgressUpdate:(DownloadMovieProgressUpdateBlock)progressUpdateBlock onEnd:(DownloadMovieEndBlock)endBlock
{
    ALog(@"is main thread? %s", [NSThread isMainThread] ? "Yes" : "No");
    if (!movieDirURL)
        return FALSE;
    BOOL isDir = TRUE;
    ALog(@"movieDirURL: |%@|", movieDirURL);
#if 1
    if (![[NSFileManager defaultManager] fileExistsAtPath:[movieDirURL path] isDirectory:&isDir]) {
        ALog(@"|%@|: not exist", movieDirURL);
        return FALSE;
    }
    if (!isDir) {
        ALog(@"|%@|: not directory", movieDirURL);
        return FALSE;
    }
#else
    if (![[NSFileManager defaultManager] fileExistsAtPath:[movieDirURL path] isDirectory:&isDir] || !isDir)
        return FALSE;
#endif
    self.movieDirURL = movieDirURL;
    self.progressUpdateBlock = progressUpdateBlock;
    self.endBlock = endBlock;
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];

// common to all transactions with PHP scripts
    [request setValue:@"iOS" forHTTPHeaderField:@"Device"];
    [request setValue:[UIDevice currentDevice].model forHTTPHeaderField:@"Build-Model"];
    [request setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forHTTPHeaderField:@"Language"];
    [request setValue:[OwnUtil BUNDLE_IDENTIFIER] forHTTPHeaderField:@"Bundle-Identifier"];
    [request setValue:[OwnUtil BUNDLE_NAME] forHTTPHeaderField:@"Bundle-Name"];
    [request setValue:[OwnUtil BUNDLE_VERSION] forHTTPHeaderField:@"Bundle-Version"];
    [request setValue:[OwnUtil BUNDLE_BUILD] forHTTPHeaderField:@"Bundle-Build"];
// common to all transactions with PHP scripts

    [request setValue:@"Movie Info" forHTTPHeaderField:@"Request-Type"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    return TRUE;
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (statusString != nil) {
        self.endBlock(nil, nil);
    }
    if (TRACE) {
        ALog(@"INFO: status string: |%@|", statusString);
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
    // A delegate method called by the NSURLConnection when the request/response 
    // exchange is complete.  We look at the response to check that the HTTP 
    // status code is 2xx.  If it isn't, we fail right now.
{
    assert([NSThread isMainThread]);
    //ALog(@"connection:didReceiveResponse:");
    #pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;

    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if (TRACE) {
        ALog(@"INFO: statusCode = %@", OPInteger(httpResponse.statusCode));
    }
    // See get_movie_info.php
    if (httpResponse.statusCode != 200) {
        ALog(@"ERR: statusCode = %@", OPInteger(httpResponse.statusCode));
        [self stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
        return;
    } else {
        if (TRACE) {
            ALog(@"INFO: status: Response OK.");
        }
    }    
    NSDictionary *allHeaderFields = httpResponse.allHeaderFields;
    if (TRACE) {
        for (NSString *key in allHeaderFields)
            ALog(@"    |%@|: |%@|", key, allHeaderFields[key]);
    }
    NSString *movieInfoStr = allHeaderFields[@"Movie-Info"];
////_movies = [MovieInfo parse:movieInfoStr];
    [self setMovies:[MovieInfo parse:movieInfoStr]];
    __block int k = 0;
    NSInteger n = [self.movies count];
    NSMutableDictionary *statusCode_d = [NSMutableDictionary dictionaryWithCapacity:n];
    for (int i = 0; i < n; ++i) {
        if (TRACE) {
            ALog(@"INFO: movie[%d]:", i);
        }
        MovieInfo *mi = self.movies[i];
        if (TRACE) {
            [mi printWithIndent:@"INFO:\t\t"];
        }
        NSString *name = [mi name];
        NSURL *videoFileURL = [[self.movieDirURL URLByAppendingPathComponent:name] URLByAppendingPathExtension:@"m4v"]; 
        NSString *sha1sum0 = [[mi sha1] lowercaseString];
        NSString *sha1sum = [OwnUtil sha1:[videoFileURL path]];
        if (TRACE) {
            ALog(@"INFO: |%@|", videoFileURL);
            ALog(@"INFO: SHA1-: |%@|", sha1sum0);
            ALog(@"INFO: SHA1: |%@|", sha1sum);
        }
        if (sha1sum0 && [sha1sum0 isEqualToString:sha1sum]) {
            assert([NSThread isMainThread]);
            ++k;
            [statusCode_d setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d", i]];
            if (TRACE) {
                ALog(@"INFO: SHA1 matched: not necessary to call NetGet");
                ALog(@"INFO: k = %d", k);
            }
            self.progressUpdateBlock((int) (100. * k / n));
            if (k == n) {
                self.endBlock(self.movies, statusCode_d);
                break;
            }
            continue;
        }
        NSURL *net_get_url = [OwnUtil NET_GET_URL];
        __block int ii = i;
        BOOL b = [[[NetGet alloc] init]
            get:videoFileURL
            from:net_get_url
            movie:name
            sha1sum:sha1sum0
            onEnd:^(NSInteger statusCode) {
                assert([NSThread isMainThread]);
                ++k;
                [statusCode_d setObject:[NSNumber numberWithInteger:statusCode] forKey:[NSString stringWithFormat:@"%d", ii]];
                if (TRACE) {
                    ALog(@"INFO: k = %d", k);
                    ALog(@"INFO: statusCode = %@", OPInteger(statusCode));
                }
                self.progressUpdateBlock((int) (100. * k / n));
                if (k == n) {
                    self.endBlock(self.movies, statusCode_d);
                    return;
                }
#if 0   // to check if everything is okay; send back and compare it
                NSURL *net_put_url = [OwnUtil NET_PUT_URL];
                NSDictionary *headers = @{
                    @"User-Id":     @"0",
                    @"Movie-Id":    [NSString stringWithFormat:@"%d", i]
                };
                NetPut *netPut = [[NetPut alloc] init];
                BOOL b = [netPut
                    send:videoFileURL
                    to:net_put_url
                    headers:headers
                    onEnd:^(int statusCode, NSString *remoteFilePath) {
                        if (TRACE) {
                            ALog(@"INFO: statusCode = %d", statusCode);
                        }
                        if (statusCode == 200) {
                            if (TRACE) {
                                ALog(@"INFO: remoteFilePath: |%@|", remoteFilePath);
                            }
                        }
                    }
                ];
                if (!b) {
                    ALog(@"ERR: call to NetPut:send(|%@|):to(|%@|):...: failed", videoFileURL, net_put_url);
                }
#endif
            }
        ];
        if (!b) {
            assert([NSThread isMainThread]);
            ++k;
            [statusCode_d setObject:[NSNumber numberWithInt:-3] forKey:[NSString stringWithFormat:@"%d", i]];
            ALog(@"ERR: NetGet:get(|%@|):from(|%@|):name(|%@|)", videoFileURL, net_get_url, name);
            if (TRACE) {
                ALog(@"INFO: k = %d", k);
            }
            self.progressUpdateBlock((int) (100. * k / n));
            if (k == n) {
                self.endBlock(self.movies, statusCode_d);
                break;
            }
        }
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
    // A delegate method called by the NSURLConnection as data arrives.  The 
    // response data for a PUT is only for useful for debugging purposes, 
    // so we just drop it on the floor.
{
    //ALog(@"connection:didReceiveData:");
    //ALog(@"# of bytes received = %du", data.length);

    #pragma unused(theConnection)
    #pragma unused(data)

    assert(theConnection == self.connection);

    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)err
    // A delegate method called by the NSURLConnection if the connection fails. 
    // We shut down the connection and display the failure.  Production quality code 
    // would either display or log the actual error.
{
    //ALog(@"connection:didFailWithError: |%@|", err);
    #pragma unused(theConnection)
    #pragma unused(err)
    assert(theConnection == self.connection);
    
    [self stopSendWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
    // A delegate method called by the NSURLConnection when the connection has been 
    // done successfully.  We shut down the connection with a nil status, which 
    // causes the image to be displayed.
{
    if (TRACE) {
        ALog(@"connectionDidFinishLoading");
    }
    #pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self stopSendWithStatus:nil];
}
- (void) connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //ALog(@"connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:");
    //ALog(@"%ld %ld %ld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

@end
