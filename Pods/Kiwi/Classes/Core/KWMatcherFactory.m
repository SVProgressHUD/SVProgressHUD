//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWMatcherFactory.h"
#import <objc/runtime.h>
#import "KWMatching.h"
#import "KWStringUtilities.h"
#import "KWUserDefinedMatcher.h"
#import "KWMatchers.h"

@interface KWMatcherFactory()

@property (nonatomic, strong) NSMutableDictionary *matcherClassChains;

@end

@implementation KWMatcherFactory

#pragma mark - Initializing

- (id)init {
    self = [super init];
    if (self) {
        _matcherClassChains = [[NSMutableDictionary alloc] init];
        _registeredMatcherClasses = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - Registering Matcher Classes

- (void)registerMatcherClass:(Class)aClass {
    if ([self.registeredMatcherClasses containsObject:aClass])
        return;

    [(NSMutableArray *)self.registeredMatcherClasses addObject:aClass];

    for (NSString *verificationSelectorString in [aClass matcherStrings]) {
        NSMutableArray *matcherClassChain = self.matcherClassChains[verificationSelectorString];

        if (matcherClassChain == nil) {
            matcherClassChain = [[NSMutableArray alloc] init];
            self.matcherClassChains[verificationSelectorString] = matcherClassChain;
        }

        [matcherClassChain removeObject:aClass];
        [matcherClassChain insertObject:aClass atIndex:0];
    }
}

- (void)registerMatcherClassesWithNamespacePrefix:(NSString *)aNamespacePrefix {
    static NSMutableArray *matcherClasses = nil;

    // Cache all classes that conform to KWMatching.
    if (matcherClasses == nil) {
        matcherClasses = [[NSMutableArray alloc] init];
        int numberOfClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numberOfClasses);
        numberOfClasses = objc_getClassList(classes, numberOfClasses);

        if (numberOfClasses == 0) {
            free(classes);
            return;
        }

        for (int i = 0; i < numberOfClasses; ++i) {
            Class candidateClass = classes[i];

            if (!class_respondsToSelector(candidateClass, @selector(conformsToProtocol:)))
                continue;

            if (![candidateClass conformsToProtocol:@protocol(KWMatching)])
                continue;

            [matcherClasses addObject:candidateClass];
        }

        free(classes);
    }

    for (Class matcherClass in matcherClasses) {
        NSString *className = NSStringFromClass(matcherClass);

        if (KWStringHasStrictWordPrefix(className, aNamespacePrefix))
            [self registerMatcherClass:matcherClass];
    }
}

#pragma mark - Getting Method Signatures

- (NSMethodSignature *)methodSignatureForMatcherSelector:(SEL)aSelector {
    NSMutableArray *matcherClassChain = self.matcherClassChains[NSStringFromSelector(aSelector)];

    if ([matcherClassChain count] == 0)
        return nil;

    Class matcherClass = matcherClassChain[0];
    return [matcherClass instanceMethodSignatureForSelector:aSelector];
}

#pragma mark - Getting Matchers

- (KWMatcher *)matcherFromInvocation:(NSInvocation *)anInvocation subject:(id)subject {
    SEL selector = [anInvocation selector];

    // try and match a built-in or registered matcher class
    Class matcherClass = [self matcherClassForSelector:selector subject:subject];

    if (matcherClass == nil) {
        // see if we can match with a user-defined matcher instead
        return [[KWMatchers matchers] matcherForSelector:selector subject:subject];
    }
    return [[matcherClass alloc] initWithSubject:subject];
}

#pragma mark - Private methods

- (Class)matcherClassForSelector:(SEL)aSelector subject:(id)anObject {
    NSArray *matcherClassChain = self.matcherClassChains[NSStringFromSelector(aSelector)];

    for (Class matcherClass in matcherClassChain) {
        if ([matcherClass canMatchSubject:anObject])
            return matcherClass;
    }

    return nil;
}

@end
