//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "NSMethodSignature+KiwiAdditions.h"

@implementation NSMethodSignature(KiwiAdditions)

#pragma mark - Getting Information on Message Arguments

- (NSUInteger)numberOfMessageArguments {
    return [self numberOfArguments] - 2;
}

- (const char *)messageArgumentTypeAtIndex:(NSUInteger)anIndex {
    return [self getArgumentTypeAtIndex:anIndex + 2];
}

@end
