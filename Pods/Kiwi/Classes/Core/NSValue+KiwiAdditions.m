//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "NSValue+KiwiAdditions.h"
#import "KWObjCUtilities.h"

@implementation NSValue(KiwiAdditions)

#pragma mark - Accessing Data

- (NSData *)dataValue {
    NSUInteger length = KWObjCTypeLength([self objCType]);
    void *buffer = malloc(length);
    [self getValue:buffer];
    NSData *data = [NSData dataWithBytes:buffer length:length];
    free(buffer);
    return data;
}

@end
