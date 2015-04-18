//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWCountType.h"
#import "KWMatcher.h"
#import "KWMatchVerifier.h"

@class KWMessagePattern;
@class KWMessageTracker;

@interface KWReceiveMatcher : KWMatcher

@property (nonatomic, assign) BOOL willEvaluateMultipleTimes;
@property (nonatomic, assign) BOOL willEvaluateAgainstNegativeExpectation;

#pragma mark - Configuring Matchers

- (void)receive:(SEL)aSelector;
- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount;
- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount;
- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount;
- (void)receive:(SEL)aSelector andReturn:(id)aValue;
- (void)receive:(SEL)aSelector andReturn:(id)aValue withCount:(NSUInteger)aCount;
- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount;
- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtMost:(NSUInteger)aCount;

// These methods will become private
- (void)receiveMessagePattern:(KWMessagePattern *)aMessagePattern countType:(KWCountType)aCountType count:(NSUInteger)aCount;
- (void)receiveMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue countType:(KWCountType)aCountType count:(NSUInteger)aCount;

@end

@interface KWMatchVerifier(KWReceiveMatcherAdditions)

#pragma mark - Verifying

- (void)receive:(SEL)aSelector withArguments:(id)firstArgument, ...;
- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount arguments:(id)firstArgument, ...;
- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount arguments:(id)firstArgument, ...;
- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount arguments:(id)firstArgument, ...;
- (void)receive:(SEL)aSelector andReturn:(id)aValue withArguments:(id)firstArgument, ...;
- (void)receive:(SEL)aSelector andReturn:(id)aValue withCount:(NSUInteger)aCount arguments:(id)firstArgument, ...;
- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount arguments:(id)firstArgument, ...;
- (void)receive:(SEL)aSelector andReturn:(id)aValue withCountAtMost:(NSUInteger)aCount arguments:(id)firstArgument, ...;

#pragma mark Invocation Capturing Methods

- (id)receive DEPRECATED_ATTRIBUTE;
- (id)receiveWithCount:(NSUInteger)aCount DEPRECATED_ATTRIBUTE;
- (id)receiveWithCountAtLeast:(NSUInteger)aCount DEPRECATED_ATTRIBUTE;
- (id)receiveWithCountAtMost:(NSUInteger)aCount DEPRECATED_ATTRIBUTE;
- (id)receiveAndReturn:(id)aValue DEPRECATED_ATTRIBUTE;
- (id)receiveAndReturn:(id)aValue withCount:(NSUInteger)aCount DEPRECATED_ATTRIBUTE;
- (id)receiveAndReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount DEPRECATED_ATTRIBUTE;
- (id)receiveAndReturn:(id)aValue withCountAtMost:(NSUInteger)aCount DEPRECATED_ATTRIBUTE;

@end
