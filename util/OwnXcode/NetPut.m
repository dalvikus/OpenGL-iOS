#import <UIKit/UIKit.h>
#import "OwnUtil.h"
#import "NetPut.h"


@interface NetPut ()

@property (copy) NetPutProgressUpdateBlock progressUpdateBlock;
@property (copy) NetPutEndBlock endBlock;
@property NSURL *pathnameURL;

@property NSURLConnection *connection;
@property NSInteger statusCode;
@property NSInputStream *fileStream;

@property NSString *remoteFilePath;
@end


@implementation NetPut

- (BOOL)send:(NSURL *)pathnameURL to:(NSURL *)url headers:(NSDictionary *)headers onProgressUpdate:(NetPutProgressUpdateBlock)progressUpdateBlock onEnd:(NetPutEndBlock)endBlock
{
    if (TRACE) {
        ALog(@"is main thread? %s", [NSThread isMainThread] ? "Yes" : "No");
    }
    if (!pathnameURL) {
        ALog(@"ERR: pathnameURL is nil");
        return FALSE;
    }

    // 1. file to be sent
    NSFileManager *fileManager = [NSFileManager defaultManager];
#if 0
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    ALog(@"urls: %@", urls);
    NSURL *url = (NSURL *) [urls objectAtIndex:0];
    NSString* documentsDirectory = [url path];
    NSString *dbPathname = [documentsDirectory stringByAppendingPathComponent:@"sampledb.sql"];
    ALog(@"dbPathname: |%@|: exist? %s", dbPathname, [fileManager fileExistsAtPath:dbPathname] ? "Yes" : "No");
#endif
    NSError *err = nil;
    NSNumber *contentLength = (NSNumber *) [[fileManager attributesOfItemAtPath:pathnameURL.path error:&err] objectForKey:NSFileSize];
    if (err) {
        ALog(@"ERR: |%@|", err);
        return FALSE;
    }
//  unsigned long long fileSize = [contentLength unsignedLongLongValue];
//  ALog(@"# of bytes to be sent = %llu", fileSize);
//  ALog(@"pathnameURL: |%@|", pathnameURL);
//  ALog(@"URL: |%@|", url);

//  NSURL *url = [NSURL URLWithString:@"http://128.54.57.126/x.php"];
    self.fileStream = [NSInputStream inputStreamWithFileAtPath:pathnameURL.path];
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    if (headers) {
        for (NSString *key in headers) {
            [request setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    [request setHTTPBodyStream:self.fileStream];

// common to all transactions with PHP scripts
    [request setValue:@"iOS" forHTTPHeaderField:@"Device"];
    [request setValue:[UIDevice currentDevice].model forHTTPHeaderField:@"Build-Model"];
    [request setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forHTTPHeaderField:@"Language"];
    [request setValue:[OwnUtil BUNDLE_IDENTIFIER] forHTTPHeaderField:@"Bundle-Identifier"];
    [request setValue:[OwnUtil BUNDLE_NAME] forHTTPHeaderField:@"Bundle-Name"];
    [request setValue:[OwnUtil BUNDLE_VERSION] forHTTPHeaderField:@"Bundle-Version"];
    [request setValue:[OwnUtil BUNDLE_BUILD] forHTTPHeaderField:@"Bundle-Build"];
// common to all transactions with PHP scripts

    [request setValue:[contentLength description] forHTTPHeaderField:@"Content-Length"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.progressUpdateBlock = progressUpdateBlock;
    self.endBlock = endBlock;
    self.pathnameURL = pathnameURL;
    return TRUE;
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    //ALog(@"status string: |%@|", statusString);
    self.endBlock(_statusCode, _statusCode == 200 ? _remoteFilePath : nil);
//  [self.delegate done:statusString pathnameURL:self.pathnameURL];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
    // A delegate method called by the NSURLConnection when the request/response 
    // exchange is complete.  We look at the response to check that the HTTP 
    // status code is 2xx.  If it isn't, we fail right now.
{
    //ALog(@"connection:didReceiveResponse:");
    #pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;

    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    // See net_put.h
    //  header("HTTP/1.0 400 Bad Request");
    //  header("HTTP/1.0 500 Internal Server Error");
    //  header("HTTP/1.0 200 OK");
    _statusCode = httpResponse.statusCode;
    if ((_statusCode / 100) != 2) {
        [self stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
        ALog(@"ERR: Status Code = %@", OPInteger(_statusCode));
    } else {
        if (TRACE) {
            ALog(@"INFO: status: Response OK.");
        }
    }    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
    // A delegate method called by the NSURLConnection as data arrives.  The 
    // response data for a PUT is only for useful for debugging purposes, 
    // so we just drop it on the floor.
{
    //ALog(@"connection:didReceiveData:");
    //ALog(@"# of bytes received = %u", data.length);
    //ALog(@"Description: |%@|", [data description]);
    NSString *output = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    if ([output length] > 0)
        self.remoteFilePath = output;

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
    //ALog(@"connectionDidFinishLoading");
    #pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self stopSendWithStatus:nil];
}
- (void) connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//ALog(@"connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:");
//ALog(@"%ld %ld %ld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if (self.progressUpdateBlock) {
        int progress = (int) (100. * totalBytesWritten / totalBytesExpectedToWrite);
        self.progressUpdateBlock(progress);
    }
}

@end
