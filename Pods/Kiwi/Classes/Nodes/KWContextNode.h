//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWExampleNode.h"

@class KWAfterAllNode;
@class KWAfterEachNode;
@class KWBeforeAllNode;
@class KWBeforeEachNode;
@class KWCallSite;
@class KWLetNode;
@class KWItNode;
@class KWPendingNode;
@class KWRegisterMatchersNode;
@class KWExample;

@interface KWContextNode : NSObject<KWExampleNode>

#pragma mark - Initializing

- (id)initWithCallSite:(KWCallSite *)aCallSite parentContext:(KWContextNode *)node description:(NSString *)aDescription;

+ (id)contextNodeWithCallSite:(KWCallSite *)aCallSite parentContext:(KWContextNode *)contextNode description:(NSString *)aDescription;

#pragma mark -  Getting Call Sites

@property (nonatomic, weak, readonly) KWCallSite *callSite;

#pragma mark - Getting Descriptions

@property (readonly, copy) NSString *description;

#pragma mark - Managing Nodes

@property (nonatomic, strong) KWBeforeAllNode *beforeAllNode;
@property (nonatomic, strong) KWAfterAllNode *afterAllNode;
@property (nonatomic, strong) KWBeforeEachNode *beforeEachNode;
@property (nonatomic, strong) KWAfterEachNode *afterEachNode;
@property (nonatomic, readonly) NSArray *nodes;
@property (nonatomic, readonly) NSArray *registerMatchersNodes;
@property (nonatomic, readonly) NSArray *letNodes;

@property (nonatomic, readonly) KWContextNode *parentContext;

@property (nonatomic, assign) BOOL isFocused;

- (void)addContextNode:(KWContextNode *)aNode;
- (void)addLetNode:(KWLetNode *)aNode;
- (void)addRegisterMatchersNode:(KWRegisterMatchersNode *)aNode;
- (void)addItNode:(KWItNode *)aNode;
- (void)addPendingNode:(KWPendingNode *)aNode;

- (KWLetNode *)letNodeTree;

- (void)performExample:(KWExample *)example withBlock:(void (^)(void))exampleBlock;

#pragma mark - Accepting Visitors

- (void)acceptExampleNodeVisitor:(id<KWExampleNodeVisitor>)aVisitor;

@end
