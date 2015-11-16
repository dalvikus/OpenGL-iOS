#import <GLKit/GLKit.h>

typedef void (^GLBlock)();

@interface Model: NSObject

- (instancetype)initWith:(NSString *)objPathname use:(GLuint)theProgram modelViewProjectionMatrixIndex:(GLint)theModelViewProjectionMatrixIndex normalMatrixIndex:(GLint)theNormalMatrixIndex colorIndex:(GLint)theColorIndex;
- (void)setMVPMatrix:(GLKMatrix4)modelViewProjectionMatrix normalMatrix:(GLKMatrix3)normalMatrix;
- (void)renderWith:(GLBlock)glBlock;
- (void)free;

@end
