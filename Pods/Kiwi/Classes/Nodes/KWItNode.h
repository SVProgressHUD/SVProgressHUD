//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWBlockNode.h"
#import "KWExampleNode.h"

@class KWPendingNode;
@class KWExample;
@class KWContextNode;

@interface KWItNode : KWBlockNode<KWExampleNode>

@property (nonatomic, strong) KWExample *example;
@property (nonatomic, weak, readonly) KWContextNode *context;

#pragma mark - Initializing

+ (id)itNodeWithCallSite:(KWCallSite *)aCallSite 
             description:(NSString *)aDescription 
                 context:(KWContextNode *)context 
                   block:(void (^)(void))block;

@end
