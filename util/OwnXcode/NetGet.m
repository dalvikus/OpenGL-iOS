#include <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "OwnUtil.h"
#import "NetGet.h"


@interface NetGet ()

@property (copy) NSURL *pathnameURL;
@property (copy) NSString *sha1sum0;
@property (copy) NetGetEndBlock endBlock;
@property NSURLConnection *connection;
@property (copy) NSFileHandle *fileHandle;
// in case statusCode is 205 (Reset Content)
@property unsigned long long contentLength;
@property unsigned long long length;    // # of bytes received; should be equal to contentLength
@property CC_SHA1_CTX ctx;  // only if _sha1sum0 is not nil

@property NSInteger statusCode;
@end


@implementation NetGet
//@synthesize fileHandle = _fileHandle;

- (BOOL)get:(NSURL *)pathnameURL from:(NSURL *)url movie:(NSString *)name sha1sum:(NSString *)sha1sum0 onEnd:(NetGetEndBlock)endBlock
{
    if (TRACE) {
        ALog(@"is main thread? %s", [NSThread isMainThread] ? "Yes" : "No");
    }
    if (!pathnameURL) {
        ALog(@"ERR: pathnameURL is nil");
        return FALSE;
    }
//  ALog(@"pathnameURL: |%@|", pathnameURL);

    // 1. file to be sent
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long fileSize = 0;
    NSString* sha1sumStr;
    NSNumber *contentLength = [NSNumber numberWithInt:0];
    if ([fileManager fileExistsAtPath:pathnameURL.path]) {
        sha1sumStr = [OwnUtil sha1:[pathnameURL path]];
        NSError *err = nil;
        contentLength = (NSNumber *) [[fileManager attributesOfItemAtPath:pathnameURL.path error:&err] objectForKey:NSFileSize];
        if (err) {
            ALog(@"ERR: |%@|", err);
            return FALSE;
        }
        fileSize = [contentLength unsignedLongLongValue];
    } else {
        sha1sumStr = [NSString string];
        BOOL b = [fileManager createFileAtPath:pathnameURL.path contents:[NSData new] attributes:nil];
        if (!b) {
            ALog(@"ERR: create a empty file: |%@|: failed", pathnameURL);
            return FALSE;
        }
    }
    NSError *err = nil;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:pathnameURL error:&err];
    if (err) {
        ALog(@"ERR: |%@|", err);
        return FALSE;
    }
//  contentLength = [NSNumber numberWithInt:0];
//  ALog(@"# of bytes to be sent = %llu", fileSize);
//  ALog(@"URL: |%@|", url);

//  NSURL *url = [NSURL URLWithString:@"http://128.54.57.126/x.php"];
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

    [request setValue:name forHTTPHeaderField:@"Movie-Name"];
    [request setValue:[contentLength description] forHTTPHeaderField:@"Content-Length"];
    [request setValue:sha1sumStr forHTTPHeaderField:@"Content-SHA1"];
    self.pathnameURL = pathnameURL;
//  _sha1sum0 = [sha1sum0 lowercaseString];
    [self setSha1sum0:[sha1sum0 lowercaseString]];
//  _endBlock = endBlock;
    [self setEndBlock:endBlock];
//  _fileHandle = fileHandle;
    [self setFileHandle:fileHandle];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    return TRUE;
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    assert([NSThread isMainThread]);
    [_fileHandle closeFile];
    if (_connection != nil) {
        [_connection cancel];
        _connection = nil;
    }
    if (TRACE) {
        ALog(@"INFO: status string: |%@|", statusString);
    }
    if ([self statusCode] == 205) {
        if (TRACE) {
            ALog(@"INFO: Content-Length = %llu", _contentLength);
            ALog(@"INFO: length = %llu", _length);
        }
        if (_contentLength != _length) {
            ALog(@"ERR: Content-Length: \"%llu\", # of bytes received = %llu: does not match", _contentLength, _length);
        {
            if (TRACE) {
                ALog(@"INFO: |%@|: deleting...", _pathnameURL);
            }
            NSError *err = nil;
            BOOL b = [[NSFileManager defaultManager] removeItemAtURL:_pathnameURL error:&err];
            if (!b || err) {
                if (TRACE) {
                    ALog(@"INFO: ...failed");
                }
                ALog(@"ERR: |%@|", err);
            } else {
                if (TRACE) {
                    ALog(@"INFO: ...done");
                }
            }
        }

            [self setStatusCode:-1];
        }
        if (_sha1sum0) {
            unsigned char digest[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1_Final(digest, &_ctx);
            NSMutableString* sha1sum = [NSMutableString stringWithCapacity:2 * CC_SHA1_DIGEST_LENGTH];
            for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
                [sha1sum appendFormat:@"%02x", digest[i]];

            if (![sha1sum isEqualToString:_sha1sum0]) {
                ALog(@"ERR: sha1sum: |%@|: does not match with one(|%@|) calculated from stream", _sha1sum0, sha1sum);

            {
                if (TRACE) {
                    ALog(@"INFO: |%@|: deleting...", _pathnameURL);
                }
                NSError *err = nil;
                BOOL b = [[NSFileManager defaultManager] removeItemAtURL:self.pathnameURL error:&err];
                if (!b || err) {
                    if (TRACE) {
                        ALog(@"INFO: ...failed");
                    }
                    ALog(@"ERR: |%@|", err);
                } else {
                    if (TRACE) {
                        ALog(@"INFO: ...done");
                    }
                }
            }

                [self setStatusCode:-2];
            }
        }
    }
    self.endBlock([self statusCode]);
//  [self.delegate done:statusString pathnameURL:self.pathnameURL];
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

    assert(theConnection == _connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    NSDictionary *allHeaderFields = httpResponse.allHeaderFields;
    if (TRACE) {
        for (NSString *key in allHeaderFields) {
            ALog(@"    |%@|: |%@|", key, allHeaderFields[key]);
        }
    }

    // See net_get.php
    //  header("HTTP/1.0 400 Bad Request");
    //  header("HTTP/1.0 304 Not Modified");
    //  header("HTTP/1.0 404 Not Found");
    //  header("HTTP/1.0 500 Internal Server Error");
    //  header("HTTP/1.0 205 Reset Content");

    [self setStatusCode:httpResponse.statusCode];
    if (TRACE) {
        ALog(@"INFO: statusCode = %@", OPInteger([self statusCode]));
    }
    switch ([self statusCode]) {
    case 400:
        [self stopSendWithStatus:@"400: Bad Request"];
        break;
    case 304:
        [self stopSendWithStatus:@"304: Not Modified"];
        break;
    case 404:
        [self stopSendWithStatus:@"404: Not Found"];
        break;
    case 500:
        [self stopSendWithStatus:@"500: Internal Server Error"];
        break;
    case 205:
        if (TRACE) {
            ALog(@"INFO: 205: Reset Content");
        }
        {
            NSString *contentLengthStr = allHeaderFields[@"Content-Length"];
            if (!contentLengthStr) {
                [self stopSendWithStatus:@"205: Reset Content: no \"Content-Length\" in a header"];
            } else {
                NSNumber *number = [[[NSNumberFormatter alloc] init] numberFromString:contentLengthStr];
                if (!number) {
                    [self stopSendWithStatus:[NSString stringWithFormat:@"205: Reset Content: invalid \"Content-Length\": |%@|", contentLengthStr]];
                } else {
                    _contentLength = [number unsignedLongLongValue];
                    _length = 0;
                    if (_sha1sum0)
                        CC_SHA1_Init(&_ctx);
                }
            }
        }
        break;
    default:
        [self stopSendWithStatus:[NSString stringWithFormat:@"Unknown status code = %@", OPInteger([self statusCode])]];
        break;
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
    // A delegate method called by the NSURLConnection as data arrives.  The 
    // response data for a PUT is only for useful for debugging purposes, 
    // so we just drop it on the floor.
{
    assert([NSThread isMainThread]);
    //ALog(@"connection:didReceiveData:");
    //ALog(@"# of bytes received = %du", data.length);
    if ([self statusCode] == 205) {
        if (_sha1sum0)
            CC_SHA1_Update(&_ctx, data.bytes, (CC_LONG) data.length);
        [[self fileHandle] writeData:data];
        _length += data.length;
    }

    #pragma unused(theConnection)
    #pragma unused(data)

    assert(theConnection == _connection);

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
    assert(theConnection == _connection);
    
    [self stopSendWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
    // A delegate method called by the NSURLConnection when the connection has been 
    // done successfully.  We shut down the connection with a nil status, which 
    // causes the image to be displayed.
{
    //ALog(@"connectionDidFinishLoading");
    #pragma unused(theConnection)
    assert(theConnection == _connection);
    
    [self stopSendWithStatus:nil];
}
- (void) connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //ALog(@"connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:");
    //ALog(@"%ld %ld %ld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

@end
