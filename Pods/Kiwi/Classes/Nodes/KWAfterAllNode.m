//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWAfterAllNode.h"
#import "KWExampleNodeVisitor.h"

@implementation KWAfterAllNode

#pragma mark - Initializing

+ (id)afterAllNodeWithCallSite:(KWCallSite *)aCallSite block:(void (^)(void))block {
    return [[self alloc] initWithCallSite:aCallSite description:nil block:block];
}

#pragma mark - Accepting Visitors

- (void)acceptExampleNodeVisitor:(id<KWExampleNodeVisitor>)aVisitor {
    [aVisitor visitAfterAllNode:self];
}

@end
