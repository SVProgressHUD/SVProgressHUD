//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@interface KWBlock : NSObject

#pragma mark - Initializing
- (id)initWithBlock:(void (^)(void))block;

+ (id)blockWithBlock:(void (^)(void))block;

#pragma mark - Calling Blocks

- (void)call;

@end

#pragma mark - Creating Blocks

KWBlock *theBlock(void (^block)(void));
KWBlock *lambda(void (^block)(void));
