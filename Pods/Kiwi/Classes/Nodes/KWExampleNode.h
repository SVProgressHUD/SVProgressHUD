//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@class KWContextNode;
@protocol KWExampleNodeVisitor;

@protocol KWExampleNode<NSObject>

#pragma mark - Accepting Visitors

- (void)acceptExampleNodeVisitor:(id<KWExampleNodeVisitor>)aVisitor;

@optional

- (NSArray *)contextStack;

@end
