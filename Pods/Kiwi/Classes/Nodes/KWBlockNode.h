//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWBlock.h"

@class KWCallSite;

@interface KWBlockNode : NSObject

#pragma mark - Initializing

- (id)initWithCallSite:(KWCallSite *)aCallSite description:(NSString *)aDescription block:(void (^)(void))block;

#pragma mark - Getting Call Sites

@property (nonatomic, strong, readonly) KWCallSite *callSite;

#pragma mark - Getting Descriptions

@property (nonatomic, copy) NSString *description;

#pragma mark - Getting Blocks

@property (nonatomic, copy, readonly) void (^block)(void);

#pragma mark - Performing blocks

- (void)performBlock;

@end
