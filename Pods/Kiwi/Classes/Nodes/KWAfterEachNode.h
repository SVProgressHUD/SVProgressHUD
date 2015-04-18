//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWBlockNode.h"
#import "KWExampleNode.h"

@interface KWAfterEachNode : KWBlockNode<KWExampleNode>

#pragma mark - Initializing

+ (id)afterEachNodeWithCallSite:(KWCallSite *)aCallSite block:(void (^)(void))block;

@end
