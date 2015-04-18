//
//  KWExampleSuite.h
//  Kiwi
//
//  Created by Luke Redpath on 17/10/2011.
//  Copyright (c) 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWExampleNodeVisitor.h"

@class KWContextNode;
@class KWExample;

@interface KWExampleSuite : NSObject <KWExampleNodeVisitor, NSFastEnumeration>

- (id)initWithRootNode:(KWContextNode *)contextNode;
- (void)addExample:(KWExample *)example;
- (void)markLastExampleAsLastInContext:(KWContextNode *)context;

@property (nonatomic, readonly) NSMutableArray *examples;

#pragma mark - Example selector names

- (NSString *)nextUniqueSelectorName:(NSString *)name;

@end

@interface NSInvocation (KWExampleGroup)
@property (nonatomic, setter = kw_setExample:) KWExample *kw_example;
@end
