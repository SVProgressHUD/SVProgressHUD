//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@protocol KWMatching<NSObject>

#pragma mark - Initializing

- (id)initWithSubject:(id)anObject;

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings;

#pragma mark - Getting Matcher Compatability

+ (BOOL)canMatchSubject:(id)anObject;

#pragma mark - Matching

@optional

- (BOOL)isNilMatcher;
- (BOOL)shouldBeEvaluatedAtEndOfExample;
- (BOOL)willEvaluateMultipleTimes;
- (void)setWillEvaluateMultipleTimes:(BOOL)shouldEvaluateMultipleTimes;
- (void)setWillEvaluateAgainstNegativeExpectation:(BOOL)willEvaluateAgainstNegativeExpectation;

@required

- (BOOL)evaluate;

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould;
- (NSString *)failureMessageForShouldNot;

@end
