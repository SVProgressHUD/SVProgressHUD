//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@interface NSMethodSignature(KiwiAdditions)

#pragma mark - Getting Information on Message Arguments

- (NSUInteger)numberOfMessageArguments;
- (const char *)messageArgumentTypeAtIndex:(NSUInteger)anIndex;

@end
