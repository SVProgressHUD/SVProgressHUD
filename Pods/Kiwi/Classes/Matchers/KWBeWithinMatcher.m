//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWBeWithinMatcher.h"
#import "KWFormatter.h"
#import "KWObjCUtilities.h"
#import "KWValue.h"

@interface KWBeWithinMatcher()

@property (nonatomic, readwrite, strong) id distance;
@property (nonatomic, readwrite, strong) id otherValue;

@end

@implementation KWBeWithinMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"beWithin:of:", @"equal:withDelta:"];
}

#pragma mark - Matching

// Evaluation is done by getting the underlying values as the widest data
// types available.

- (BOOL)evaluateForFloatingPoint {
    double firstValue = [self.subject doubleValue];
    double secondValue = [self.otherValue doubleValue];
    double theDistance = [self.distance doubleValue];
    double absoluteDifference = firstValue > secondValue ? firstValue - secondValue : secondValue - firstValue;
    return absoluteDifference <= theDistance;
}

- (BOOL)evaluateForUnsignedIntegral {
    unsigned long long firstValue = [self.subject unsignedLongLongValue];
    unsigned long long secondValue = [self.otherValue unsignedLongLongValue];
    unsigned long long theDistance = [self.distance unsignedLongLongValue];
    unsigned long long absoluteDifference = firstValue > secondValue ? firstValue - secondValue : secondValue - firstValue;
    return absoluteDifference <= theDistance;
}

- (BOOL)evaluateForSignedIntegral {
    long long firstValue = [self.subject longLongValue];
    long long secondValue = [self.otherValue longLongValue];
    long long theDistance = [self.distance longLongValue];
    long long absoluteDifference = firstValue > secondValue ? firstValue - secondValue : secondValue - firstValue;
    return absoluteDifference <= theDistance;
}

- (BOOL)evaluate {
    const char *objCType = [self.subject objCType];

    if (KWObjCTypeIsFloatingPoint(objCType))
        return [self evaluateForFloatingPoint];
    else if (KWObjCTypeIsUnsignedIntegral(objCType))
        return [self evaluateForUnsignedIntegral];
    else
        return [self evaluateForSignedIntegral];
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to be within %@ of %@, got %@",
                                      [KWFormatter formatObject:self.distance],
                                      [KWFormatter formatObject:self.otherValue],
                                      [KWFormatter formatObject:self.subject]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"be within %@ of %@", self.distance, self.otherValue];
}

#pragma mark - Configuring Matchers

- (void)beWithin:(id)aDistance of:(id)aValue {
    self.distance = aDistance;
    self.otherValue = aValue;
}

- (void)equal:(double)aValue withDelta:(double)aDelta {
    [self beWithin:[KWValue valueWithDouble:aDelta] of:[KWValue valueWithDouble:aValue]];
}

@end
