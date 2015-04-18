//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWBeTrueMatcher.h"

@interface KWBeTrueMatcher()

@property (nonatomic, readwrite) BOOL expectedValue;

@end

@implementation KWBeTrueMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"beTrue", @"beFalse", @"beYes", @"beNo"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    if (![self.subject respondsToSelector:@selector(boolValue)])
        [NSException raise:@"KWMatcherException" format:@"subject does not respond to -boolValue"];

    return [self.subject boolValue] == self.expectedValue;
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to be %@",
                                       self.expectedValue ? @"true" : @"false"];
}

- (NSString *)description {
    if (self.expectedValue == YES) {
        return @"be true";
    }
    return @"be false";
}

#pragma mark - Configuring Matchers

- (void)beTrue {
    self.expectedValue = YES;
}

- (void)beFalse {
    self.expectedValue = NO;
}

- (void)beYes {
    self.expectedValue = YES;
}

- (void)beNo {
    self.expectedValue = NO;
}

@end
