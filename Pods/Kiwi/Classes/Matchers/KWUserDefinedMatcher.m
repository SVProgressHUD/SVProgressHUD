//
//  KWUserDefinedMatcher.m
//  Kiwi
//
//  Created by Luke Redpath on 16/06/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import "KWUserDefinedMatcher.h"

@interface KWUserDefinedMatcher(){}
@property (nonatomic, copy) NSInvocation *invocation;
@end

@implementation KWUserDefinedMatcher

@synthesize selector;
@synthesize failureMessageForShould;
@synthesize failureMessageForShouldNot;
@synthesize matcherBlock;
@synthesize description;

+ (id)matcherWithSubject:(id)aSubject block:(KWUserDefinedMatcherBlock)aBlock {
    return [[self alloc] initWithSubject:aSubject block:aBlock];
}

- (id)initWithSubject:(id)aSubject block:(KWUserDefinedMatcherBlock)aBlock {
    self = [super initWithSubject:aSubject];
    if (self) {
        matcherBlock = [aBlock copy];
        self.description = @"match user defined matcher";
    }
    return self;
}


- (BOOL)evaluate {
    BOOL result;

    if (self.invocation.methodSignature.numberOfArguments == 3) {
        id argument;
        [self.invocation getArgument:&argument atIndex:2];
        result = matcherBlock(self.subject, argument);
    } else {
        result = matcherBlock(self.subject);
    }
    return result;
}

#pragma mark - Message forwarding

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == self.selector) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    _invocation = anInvocation;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == self.selector) {
        NSString *selectorString = NSStringFromSelector(self.selector);

        /**
         *   TODO: find a way of doing this that:
         *   - doesn't require dummy methods (create the method signatures manually)
         *   - supports an unlimited number of arguments
         */
        if ([selectorString hasSuffix:@":"]) {
            return [self methodSignatureForSelector:@selector(matcherMethodWithArgument:)];
        } else {
            return [self methodSignatureForSelector:@selector(matcherMethodWithoutArguments)];
        }
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)matcherMethodWithoutArguments {}
- (void)matcherMethodWithArgument:(id)argument {}

@end

#pragma mark -

@implementation KWUserDefinedMatcherBuilder

+ (id)builder {
    return [self builderForSelector:nil];
}

+ (id)builderForSelector:(SEL)aSelector {
    return [[self alloc] initWithSelector:aSelector];
}

- (id)initWithSelector:(SEL)aSelector {
    self = [super init];
    if (self) {
        matcher = [[KWUserDefinedMatcher alloc] init];
        matcher.selector = aSelector;
    }
    return self;
}


- (NSString *)key {
    return NSStringFromSelector(matcher.selector);
}

#pragma mark - Configuring The Matcher

- (void)match:(KWUserDefinedMatcherBlock)block {
    matcher.matcherBlock = block;
}

- (void)failureMessageForShould:(KWUserDefinedMatcherMessageBlock)block {
    failureMessageForShouldBlock = [block copy];
}

- (void)failureMessageForShouldNot:(KWUserDefinedMatcherMessageBlock)block {
    failureMessageForShouldNotBlock = [block copy];
}

- (void)description:(NSString *)aDescription {
    description = [aDescription copy];
}

#pragma mark - Buiding The Matcher

- (KWUserDefinedMatcher *)buildMatcherWithSubject:(id)subject {
    [matcher setSubject:subject];

    if (failureMessageForShouldBlock) {
        [matcher setFailureMessageForShould:failureMessageForShouldBlock(subject)];
    }

    if (failureMessageForShouldNotBlock) {
        [matcher setFailureMessageForShouldNot:failureMessageForShouldNotBlock(subject)];
    }

    if (description) {
        [matcher setDescription:description];
    }

    return matcher;
}

@end
