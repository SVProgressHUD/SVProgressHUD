//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWReceiveMatcher.h"
#import "KWFormatter.h"
#import "KWInvocationCapturer.h"
#import "KWMessagePattern.h"
#import "KWMessageTracker.h"
#import "KWObjCUtilities.h"
#import "KWStringUtilities.h"
#import "KWWorkarounds.h"
#import "NSObject+KiwiStubAdditions.h"

static NSString * const MatchVerifierKey = @"MatchVerifierKey";
static NSString * const CountTypeKey = @"CountTypeKey";
static NSString * const CountKey = @"CountKey";
static NSString * const StubValueKey = @"StubValueKey";

@interface KWReceiveMatcher()

#pragma mark - Properties

@property (nonatomic, readwrite, strong) KWMessageTracker *messageTracker;

@end

@implementation KWReceiveMatcher

#pragma mark - Initializing

- (id)initWithSubject:(id)anObject {
    self = [super initWithSubject:anObject];
    if (self) {
        _willEvaluateMultipleTimes = NO;
    }
    
    return self;
}

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"receive:",
                                     @"receive:withCount:",
                                     @"receive:withCountAtLeast:",
                                     @"receive:withCountAtMost:",
                                     @"receive:andReturn:",
                                     @"receive:andReturn:withCount:",
                                     @"receive:andReturn:withCountAtLeast:",
                                     @"receive:andReturn:withCountAtMost:",
                                     @"receiveMessagePattern:countType:count:",
                                     @"receiveMessagePattern:andReturn:countType:count:",
                                     @"receiveUnspecifiedCountOfMessagePattern:",
                                     @"receiveUnspecifiedCountOfMessagePattern:andReturn:"];
}

#pragma mark - Matching

- (BOOL)shouldBeEvaluatedAtEndOfExample {
    return YES;
}

- (BOOL)evaluate {
    BOOL succeeded = [self.messageTracker succeeded];

    if (!self.willEvaluateMultipleTimes) {
      [self.messageTracker stopTracking];
    }
    return succeeded;
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to receive -%@ %@, but received it %@",
                                      [self.messageTracker.messagePattern stringValue],
                                      [self.messageTracker expectedCountPhrase],
                                      [self.messageTracker receivedCountPhrase]];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"expected subject not to receive -%@, but received it %@",
                                      [self.messageTracker.messagePattern stringValue],
                                      [self.messageTracker receivedCountPhrase]];
}

#pragma mark - Configuring Matchers

- (void)receive:(SEL)aSelector {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self receiveUnspecifiedCountOfMessagePattern:messagePattern];
}

- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    return [self receiveMessagePattern:messagePattern countType:KWCountTypeExact count:aCount];
}

- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    return [self receiveMessagePattern:messagePattern countType:KWCountTypeAtLeast count:aCount];
}

- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    return [self receiveMessagePattern:messagePattern countType:KWCountTypeAtMost count:aCount];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self receiveUnspecifiedCountOfMessagePattern:messagePattern andReturn:aValue];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue withCount:(NSUInteger)aCount {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeExact count:aCount];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeAtLeast count:aCount];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtMost:(NSUInteger)aCount {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeAtMost count:aCount];
}

- (void)receiveUnspecifiedCountOfMessagePattern:(KWMessagePattern *)messagePattern {
    if (self.willEvaluateAgainstNegativeExpectation) {
        [self receiveMessagePattern:messagePattern countType:KWCountTypeAtLeast count:1];
    } else {
        [self receiveMessagePattern:messagePattern countType:KWCountTypeExact count:1];
    }
}

- (void)receiveUnspecifiedCountOfMessagePattern:(KWMessagePattern *)messagePattern andReturn:(id)aValue {
    if (self.willEvaluateAgainstNegativeExpectation) {
        [self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeAtLeast count:1];
    } else {
        [self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeExact count:1];
    }
}

- (void)receiveMessagePattern:(KWMessagePattern *)aMessagePattern countType:(KWCountType)aCountType count:(NSUInteger)aCount {
#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    @try {
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG

    [self.subject stubMessagePattern:aMessagePattern andReturn:nil overrideExisting:NO];
    self.messageTracker = [KWMessageTracker messageTrackerWithSubject:self.subject messagePattern:aMessagePattern countType:aCountType count:aCount];

#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    } @catch(NSException *exception) {
        KWSetExceptionFromAcrossInvocationBoundary(exception);
    }
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
}

- (void)receiveMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue countType:(KWCountType)aCountType count:(NSUInteger)aCount {
#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    @try {
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG

    [self.subject stubMessagePattern:aMessagePattern andReturn:aValue];
    self.messageTracker = [KWMessageTracker messageTrackerWithSubject:self.subject messagePattern:aMessagePattern countType:aCountType count:aCount];

#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    } @catch(NSException *exception) {
        KWSetExceptionFromAcrossInvocationBoundary(exception);
    }
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
}

#pragma mark - Capturing Invocations

+ (NSMethodSignature *)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer methodSignatureForSelector:(SEL)aSelector {
    KWMatchVerifier *verifier = (anInvocationCapturer.userInfo)[MatchVerifierKey];

    if ([verifier.subject respondsToSelector:aSelector])
        return [verifier.subject methodSignatureForSelector:aSelector];

    NSString *encoding = KWEncodingForDefaultMethod();
    return [NSMethodSignature signatureWithObjCTypes:[encoding UTF8String]];
}

+ (void)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer didCaptureInvocation:(NSInvocation *)anInvocation {
    NSDictionary *userInfo = anInvocationCapturer.userInfo;
    id verifier = userInfo[MatchVerifierKey];
    KWCountType countType = [userInfo[CountTypeKey] unsignedIntegerValue];
    NSUInteger count = [userInfo[CountKey] unsignedIntegerValue];
    id stubValue = userInfo[StubValueKey];
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternFromInvocation:anInvocation];

    if (stubValue != nil)
        [verifier receiveMessagePattern:messagePattern andReturn:stubValue countType:countType count:count];
    else
        [verifier receiveMessagePattern:messagePattern countType:countType count:count];
}

@end

@implementation KWMatchVerifier(KWReceiveMatcherAdditions)

#pragma mark - Verifying

- (void)receive:(SEL)aSelector withArguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveUnspecifiedCountOfMessagePattern:messagePattern];
}

- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount arguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveMessagePattern:messagePattern countType:KWCountTypeExact count:aCount];
}

- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount arguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveMessagePattern:messagePattern countType:KWCountTypeAtLeast count:aCount];
}

- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount arguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveMessagePattern:messagePattern countType:KWCountTypeAtMost count:aCount];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue withArguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveUnspecifiedCountOfMessagePattern:messagePattern andReturn:aValue];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue withCount:(NSUInteger)aCount arguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeExact count:aCount];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount arguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeAtLeast count:aCount];
}

- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtMost:(NSUInteger)aCount arguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [(id)self receiveMessagePattern:messagePattern andReturn:aValue countType:KWCountTypeAtMost count:aCount];
}

#pragma mark Invocation Capturing Methods

- (NSDictionary *)userInfoForReceiveMatcherWithCountType:(KWCountType)aCountType count:(NSUInteger)aCount {
    return @{
        MatchVerifierKey: self,
        CountTypeKey:     @(aCountType),
        CountKey:         @(aCount)
    };
}

- (NSDictionary *)userInfoForReceiveMatcherWithCountType:(KWCountType)aCountType count:(NSUInteger)aCount value:(id)aValue {
    return @{
        MatchVerifierKey: self,
        CountTypeKey:     @(aCountType),
        CountKey:         @(aCount),
        StubValueKey:     aValue
    };
}

- (id)receive {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeExact count:1];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

- (id)receiveWithCount:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeExact count:aCount];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

- (id)receiveWithCountAtLeast:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeAtLeast count:aCount];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

- (id)receiveWithCountAtMost:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeAtMost count:aCount];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

- (id)receiveAndReturn:(id)aValue {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeExact count:1 value:aValue];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

- (id)receiveAndReturn:(id)aValue withCount:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeExact count:aCount value:aValue];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

- (id)receiveAndReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeAtLeast count:aCount value:aValue];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

- (id)receiveAndReturn:(id)aValue withCountAtMost:(NSUInteger)aCount {
    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeAtMost count:aCount value:aValue];
    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
}

@end
