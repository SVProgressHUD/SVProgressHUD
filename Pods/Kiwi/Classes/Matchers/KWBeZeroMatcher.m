//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWBeZeroMatcher.h"
#import "KWFormatter.h"
#import "KWValue.h"

@implementation KWBeZeroMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"beZero"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    if ([self.subject isKindOfClass:[NSNumber class]]) {
        return [self.subject isEqualToNumber:@0];
    }
    
    if ([self.subject respondsToSelector:@selector(numberValue)]) {
        return [[self.subject numberValue] isEqualToNumber:@0];
    }
    
    return NO;
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to be zero, got %@",
                                      [KWFormatter formatObject:self.subject]];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"expected subject not to be zero"];
}

- (NSString *)description {
    return @"be zero";
}

#pragma mark - Configuring Matchers

- (void)beZero {
}

@end
