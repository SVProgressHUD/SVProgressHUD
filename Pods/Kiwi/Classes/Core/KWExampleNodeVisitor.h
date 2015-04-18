//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@class KWAfterAllNode;
@class KWAfterEachNode;
@class KWBeforeAllNode;
@class KWBeforeEachNode;
@class KWContextNode;
@class KWLetNode;
@class KWItNode;
@class KWPendingNode;
@class KWRegisterMatchersNode;

@protocol KWExampleNodeVisitor<NSObject>

#pragma mark - Visiting Nodes

@optional

- (void)visitContextNode:(KWContextNode *)aNode;
- (void)visitRegisterMatchersNode:(KWRegisterMatchersNode *)aNode;
- (void)visitBeforeAllNode:(KWBeforeAllNode *)aNode;
- (void)visitAfterAllNode:(KWAfterAllNode *)aNode;
- (void)visitBeforeEachNode:(KWBeforeEachNode *)aNode;
- (void)visitAfterEachNode:(KWAfterEachNode *)aNode;
- (void)visitLetNode:(KWLetNode *)aNode;
- (void)visitItNode:(KWItNode *)aNode;
- (void)visitPendingNode:(KWPendingNode *)aNode;

@end
