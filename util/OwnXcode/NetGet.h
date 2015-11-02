// statusCode > 0
//  http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html
// -1:
//  statusCode = 205 (Reset Content) but no "Content-Length" or mismatch between "Content-Length" and the number of received bytes
// -2:
//  statusCode = 205 (Reset Content) and given sha1sum given does not match with one calculated from stream
typedef void (^NetGetEndBlock)(NSInteger statusCode);

@interface NetGet : NSObject
- (BOOL)get:(NSURL *)pathnameURL from:(NSURL *)url movie:(NSString *)name sha1sum:(NSString*)sha1sum0 onEnd:(NetGetEndBlock)endBlock;
@end
