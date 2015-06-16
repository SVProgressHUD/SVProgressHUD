//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWExampleNode.h"

@class KWContextNode;
@class KWCallSite;

@interface KWPendingNode : NSObject<KWExampleNode>

@property (nonatomic, readonly, strong) KWContextNode *context;

#pragma mark - Initializing

- (id)initWithCallSite:(KWCallSite *)aCallSite context:(KWContextNode *)context description:(NSString *)aDescription;

+ (id)pendingNodeWithCallSite:(KWCallSite *)aCallSite context:(KWContextNode *)context description:(NSString *)aDescription;

#pragma mark - Getting Call Sites

@property (nonatomic, readonly) KWCallSite *callSite;

#pragma mark - Getting Descriptions

@property (readonly, copy) NSString *description;

@end
