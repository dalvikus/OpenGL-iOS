#import "OwnUtil.h"
#import "MovieInfo.h"

@interface MovieInfo ()
- (instancetype) initWithName:(NSString *)name withSize:(unsigned long long)size withSHA1:(NSString *)sha1 withWidth0:(unsigned int)width0 withHeight0:(unsigned int)height0 withDuration0:(float)duration0 withX:(unsigned int)x withY:(unsigned int)y withWidth:(unsigned int)width withDuration:(unsigned int)duration;
@end

@implementation MovieInfo
- (instancetype)initWithName:(NSString *)name withSize:(unsigned long long)size withSHA1:(NSString *)sha1 withWidth0:(unsigned int)width0 withHeight0:(unsigned int)height0 withDuration0:(float)duration0 withX:(unsigned int)x withY:(unsigned int)y withWidth:(unsigned int)width withDuration:(unsigned int)duration
{
    self = [super init];
    if (self) {
        self.name = name;
        self.size = size;
        self.sha1 = sha1;
        self.width0 = width0;
        self.height0 = height0;
        self.duration0 = duration0;
        self.x = x;
        self.y = y;
        self.width = width;
        self.duration = duration;
    }
    return self;
}

- (void)printWithIndent:(NSString *)indent0
{
    NSString *indent = indent0;
    if (!indent)
        indent = [NSString string];
    ALog(@"%@name: |%@|", indent, self.name);
    ALog(@"%@size: %llu", indent, self.size);
    ALog(@"%@SHA1: |%@|", indent, self.sha1);
    ALog(@"%@dimension: %ux%u", indent, self.width0, self.height0);
    ALog(@"%@duration0: %.2f", indent, self.duration0);
    ALog(@"%@origin: (%u, %u)", indent, self.x, self.y);
    ALog(@"%@width: %u", indent, self.width);
    ALog(@"%@duration: %u", indent, self.duration);
}

+ (NSArray *)parse:(NSString *)movieInfoStr
{
    if (!movieInfoStr)
        return nil;
    NSArray *a1 = [movieInfoStr componentsSeparatedByString:@";"];
    NSUInteger n1 = [a1 count];
    if (TRACE) {
        ALog(@"# of ... %@", OPUInteger(n1));
    }
    if (TRACE) {
        for (int i = 0; i < n1; ++i)
            ALog(@"a1[%d]: |%@|", i, [a1 objectAtIndex:i]);
    }
    NSMutableArray *ra = [NSMutableArray arrayWithCapacity:[a1 count]];
    for (int i = 0; i < n1; ++i) {
        NSArray *a2 = [a1[i] componentsSeparatedByString:@","];
        NSUInteger n2 = [a2 count];
        if (TRACE) {
            for (int j = 0; j < n2; ++j)
                ALog(@"    a2[%d]: |%@|", j, a2[j]);
        }
        if ([a2 count] != 10)
            return nil;
        NSString *name = a2[0];
        if ([name length] == 0)
            return nil;
        NSNumber *number;
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[1]];
        if (!number)
            return nil;
        unsigned long long size = [number unsignedLongLongValue];
        NSString *sha1 = a2[2];
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[3]];
        if (!number)
            return nil;
        unsigned int width0 = [number unsignedIntValue];
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[4]];
        if (!number)
            return nil;
        unsigned int height0 = [number unsignedIntValue];
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[5]];
        if (!number)
            return nil;
        float duration0 = [number floatValue];
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[6]];
        if (!number)
            return nil;
        unsigned int x = [number unsignedIntValue];
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[7]];
        if (!number)
            return nil;
        unsigned int y = [number unsignedIntValue];
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[8]];
        if (!number)
            return nil;
        unsigned int width = [number unsignedIntValue];
        number = [[[NSNumberFormatter alloc] init] numberFromString:a2[9]];
        if (!number)
            return nil;
        unsigned int duration = [number unsignedIntValue];
        MovieInfo *mi = [[MovieInfo alloc]
            initWithName:name
            withSize:size
            withSHA1:sha1
            withWidth0:width0
            withHeight0:height0
            withDuration0:duration0
            withX:x
            withY:y
            withWidth:width
            withDuration:duration
        ];
        if (!mi)
            return nil;
        [ra addObject:mi];
    }
    return ra;
}

@end
