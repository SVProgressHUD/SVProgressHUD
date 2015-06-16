//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWHaveMatcher.h"
#import "KWFormatter.h"
#import "KWInvocationCapturer.h"
#import "KWObjCUtilities.h"
#import "KWStringUtilities.h"

static NSString * const MatchVerifierKey = @"MatchVerifierKey";
static NSString * const CountTypeKey = @"CountTypeKey";
static NSString * const CountKey = @"CountKey";

@interface KWHaveMatcher()

#pragma mark - Properties

@property (nonatomic, assign) KWCountType countType;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSInvocation *invocation;
@property (nonatomic, assign) NSUInteger actualCount;

@end

@implementation KWHaveMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[
             @"haveCountOf:",
             @"haveCountOfAtLeast:",
             @"haveCountOfAtMost:",
             @"haveLengthOf:",
             @"haveLengthOfAtLeast:",
             @"haveLengthOfAtMost:",
             @"have:itemsForInvocation:",
             @"haveAtLeast:itemsForInvocation:",
             @"haveAtMost:itemsForInvocation:",
             ];
}

#pragma mark - Matching

- (id)targetObject {
    if (self.invocation == nil)
        return self.subject;

    SEL selector = [self.invocation selector];

    if ([self.subject respondsToSelector:selector]) {
        NSMethodSignature *signature = [self.subject methodSignatureForSelector:selector];

        if (!KWObjCTypeIsObject([signature methodReturnType]))
            [NSException raise:@"KWMatcherEception" format:@"a valid collection was not specified"];

        __unsafe_unretained id object = nil;
        [self.invocation invokeWithTarget:self.subject];
        [self.invocation getReturnValue:&object];
        return object;
    } else if (KWSelectorParameterCount(selector) == 0) {
        return self.subject;
    } else {
        return nil;
    }
}

- (BOOL)evaluate {
    id targetObject = [self targetObject];

    if ([targetObject respondsToSelector:@selector(count)])
        self.actualCount = [targetObject count];
    else if ([targetObject respondsToSelector:@selector(length)])
        self.actualCount = [targetObject length];
    else
        self.actualCount = 0;

    switch (self.countType) {
    case KWCountTypeExact:
        return self.actualCount == self.count;
    case KWCountTypeAtLeast:
        return self.actualCount >= self.count;
    case KWCountTypeAtMost:
        return self.actualCount <= self.count;
    }

    assert(0 && "should never reach here");
    return NO;
}

#pragma mark - Getting Failure Messages

- (NSString *)verbPhrase {
    switch (self.countType) {
        case KWCountTypeExact:
            return @"have";
        case KWCountTypeAtLeast:
            return @"have at least";
        case KWCountTypeAtMost:
            return @"have at most";
    }

    assert(0 && "should never reach here");
    return nil;
}

- (NSString *)itemPhrase {
    if (self.invocation == nil)
        return @"items";
    else
        return NSStringFromSelector([self.invocation selector]);
}

- (NSString *)actualCountPhrase {
    if (self.actualCount == 1)
        return @"1 item";
    else
        return [NSString stringWithFormat:@"%u items", (unsigned)self.actualCount];
}

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to %@ %u %@, got %@",
                                      [self verbPhrase],
                                      (unsigned)self.count,
                                      [self itemPhrase],
                                      [self actualCountPhrase]];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"expected subject not to %@ %u %@",
                                      [self verbPhrase],
                                      (unsigned)self.count,
                                      [self itemPhrase]];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %u %@", [self verbPhrase], (unsigned)self.count, [self itemPhrase]];
}

#pragma mark - Configuring Matchers

- (void)haveCountOf:(NSUInteger)aCount {
    self.count = aCount;
    self.countType = KWCountTypeExact;
}

- (void)haveLengthOf:(NSUInteger)aCount {
  [self haveCountOf:aCount];
}

- (void)haveCountOfAtLeast:(NSUInteger)aCount {
    self.count = aCount;
    self.countType = KWCountTypeAtLeast;
}

- (void)haveLengthOfAtLeast:(NSUInteger)aCount {
  [self haveCountOfAtLeast:aCount];
}

- (void)haveCountOfAtMost:(NSUInteger)aCount {
    self.count = aCount;
    self.countType = KWCountTypeAtMost;
}

- (void)haveLengthOfAtMost:(NSUInteger)aCount {
  [self haveCountOfAtMost:aCount];
}

- (void)have:(NSUInteger)aCount itemsForInvocation:(NSInvocation *)anInvocation {
    self.count = aCount;
    self.countType = KWCountTypeExact;
    self.invocation = anInvocation;
}

- (void)haveAtLeast:(NSUInteger)aCount itemsForInvocation:(NSInvocation *)anInvocation {
    self.count = aCount;
    self.countType = KWCountTypeAtLeast;
    self.invocation = anInvocation;
}

- (void)haveAtMost:(NSUInteger)aCount itemsForInvocation:(NSInvocation *)anInvocation {
    self.count = aCount;
    self.countType = KWCountTypeAtMost;
    self.invocation = anInvocation;
}

#pragma mark - Capturing Invocations

+ (NSMethodSignature *)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer methodSignatureForSelector:(SEL)aSelector {
    KWMatchVerifier *verifier = (anInvocationCapturer.userInfo)[MatchVerifierKey];

    if ([verifier.subject respondsToSelector:aSelector])
        return [verifier.subject methodSignatureForSelector:aSelector];

    // Arbitrary selectors are allowed as expectation expression terminals when
    // the subject itself is a collection, so return a dummy method signature.
    NSString *encoding = KWEncodingForDefaultMethod();
    return [NSMethodSignature signatureWithObjCTypes:[encoding UTF8String]];
}

+ (void)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer didCaptureInvocation:(NSInvocation *)anInvocation {
    NSDictionary *userInfo = anInvocationCapturer.userInfo;
    id verifier = userInfo[MatchVerifierKey];
    KWCountType countType = [userInfo[CountTypeKey] unsignedIntegerValue];
    NSUInteger count = [userInfo[CountKey] unsignedIntegerValue];

    switch (countType) {
        case KWCountTypeExact:
            [verifier have:count itemsForInvocation:anInvocation];
            break;
        case KWCountTypeAtLeast:
            [verifier haveAtLeast:count itemsForInvocation:anInvocation];
            break;
        case KWCountTypeAtMost:
            [verifier haveAtMost:count itemsForInvocation:anInvocation];
            break;
    }
}

@end

#pragma mark - Verifying

@implementation KWMatchVerifier(KWHaveMatcherAdditions)

#pragma mark - Invocation Capturing Methods

- (NSDictionary *)userInfoForHaveMatcherWithCountType:(KWCountType)aCountType count:(NSUInteger)aCount {
    return @{MatchVerifierKey: self,
                                                      CountTypeKey: @(aCountType),
                                                      CountKey: @(aCount)};
}

- (id)have:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForHaveMatcherWithCountType:KWCountTypeExact count:aCount];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWHaveMatcher class] userInfo:userInfo];
}

- (id)haveAtLeast:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForHaveMatcherWithCountType:KWCountTypeAtLeast count:aCount];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWHaveMatcher class] userInfo:userInfo];
}

- (id)haveAtMost:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForHaveMatcherWithCountType:KWCountTypeAtMost count:aCount];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWHaveMatcher class] userInfo:userInfo];
}

@end
