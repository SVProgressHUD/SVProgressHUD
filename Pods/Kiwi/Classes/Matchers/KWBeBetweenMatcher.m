//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWBeBetweenMatcher.h"
#import "KWFormatter.h"

@interface KWBeBetweenMatcher()

#pragma mark - Properties

@property (nonatomic, strong) id lowerEndpoint;
@property (nonatomic, strong) id upperEndpoint;

@end

@implementation KWBeBetweenMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"beBetween:and:", @"beInTheIntervalFrom:to:"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    if (![self.subject respondsToSelector:@selector(compare:)])
        [NSException raise:@"KWMatcherException" format:@"subject does not respond to -compare:"];

    NSComparisonResult lowerResult = [self.subject compare:self.lowerEndpoint];
    NSComparisonResult upperResult = [self.subject compare:self.upperEndpoint];
    return (lowerResult == NSOrderedDescending || lowerResult == NSOrderedSame) &&
           (upperResult == NSOrderedAscending || upperResult == NSOrderedSame);
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to be in the interval [%@, %@], got %@",
                                      [KWFormatter formatObject:self.lowerEndpoint],
                                      [KWFormatter formatObject:self.upperEndpoint],
                                      [KWFormatter formatObject:self.subject]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"be between %@ and %@", self.lowerEndpoint, self.upperEndpoint];
}

#pragma mark - Configuring Matchers

- (void)beBetween:(id)aLowerEndpoint and:(id)anUpperEndpoint {
    [self beInTheIntervalFrom:aLowerEndpoint to:anUpperEndpoint];
}

- (void)beInTheIntervalFrom:(id)aLowerEndpoint to:(id)anUpperEndpoint {
    self.lowerEndpoint = aLowerEndpoint;
    self.upperEndpoint = anUpperEndpoint;
}

@end
