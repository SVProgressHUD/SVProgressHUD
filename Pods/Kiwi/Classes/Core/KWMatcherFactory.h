//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatching.h"

@class KWFailure;
@class KWMatcher;
@class KWUserDefinedMatcherBuilder;

@interface KWMatcherFactory : NSObject

#pragma mark - Initializing

- (id)init;

#pragma mark - Properties

@property (nonatomic, readonly) NSArray *registeredMatcherClasses;

#pragma mark - Registering Matcher Classes

- (void)registerMatcherClass:(Class)aClass;
- (void)registerMatcherClassesWithNamespacePrefix:(NSString *)aNamespacePrefix;

#pragma mark - Getting Method Signatures

- (NSMethodSignature *)methodSignatureForMatcherSelector:(SEL)aSelector;

#pragma mark - Getting Matchers

- (KWMatcher *)matcherFromInvocation:(NSInvocation *)anInvocation subject:(id)subject;

@end
