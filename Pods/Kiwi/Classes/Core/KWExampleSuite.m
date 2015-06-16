//
//  KWExampleSuite.m
//  Kiwi
//
//  Created by Luke Redpath on 17/10/2011.
//  Copyright (c) 2011 Allen Ding. All rights reserved.
//

#import "KWExampleSuite.h"

#import "KWAfterAllNode.h"
#import "KWBeforeAllNode.h"
#import "KWContextNode.h"
#import "KWExample.h"
#import "KWStringUtilities.h"
#import "NSMethodSignature+KiwiAdditions.h"
#import <objc/runtime.h>

#define kKWINVOCATION_EXAMPLE_GROUP_KEY @"__KWExampleGroupKey"

@interface KWExampleSuite()

@property (nonatomic, strong) KWContextNode *rootNode;
@property (nonatomic, strong) NSMutableArray *examples;
@property (nonatomic, strong) NSMutableDictionary *selectorNameCache;

@end

@implementation KWExampleSuite

- (id)initWithRootNode:(KWContextNode *)contextNode {
    self = [super init];
    if (self) {
        _rootNode = contextNode;
        _examples = [[NSMutableArray alloc] init];
        _selectorNameCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)addExample:(KWExample *)example {
    [self.examples addObject:example];
    example.suite = self;
}

- (void)markLastExampleAsLastInContext:(KWContextNode *)context
{
    if ([self.examples count] > 0) {
        KWExample *lastExample = (KWExample *)[self.examples lastObject];
        [lastExample.lastInContexts addObject:context];
    }
}

#pragma mark - Example selector names

- (NSString *)nextUniqueSelectorName:(NSString *)name {
    NSUInteger count = [(self.selectorNameCache[name] ?: @1) integerValue];
    NSString *uniqueName = name;
    if (count > 1) {
        NSString *format = [name hasSuffix:@"_"] ? @"%lu" : @"_%lu";
        uniqueName = [name stringByAppendingFormat:format, (unsigned long)count];
    }
    self.selectorNameCache[name] = @(++count);
    return uniqueName;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [self.examples countByEnumeratingWithState:state objects:buffer count:len];
}

@end

#pragma mark -

// because XCTest will modify the invocation target, we'll have to store
// another reference to the example group so we can retrieve it later

@implementation NSInvocation (KWExampleGroup)

- (void)kw_setExample:(KWExample *)exampleGroup {
    objc_setAssociatedObject(self, kKWINVOCATION_EXAMPLE_GROUP_KEY, exampleGroup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KWExample *)kw_example {
    return objc_getAssociatedObject(self, kKWINVOCATION_EXAMPLE_GROUP_KEY);
}

@end

