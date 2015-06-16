//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWNull.h"

@implementation KWNull

#pragma mark - Initializing


+ (id)null {
    static KWNull *sharedNull = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNull = [self new];

    });

    return sharedNull;
}

@end
