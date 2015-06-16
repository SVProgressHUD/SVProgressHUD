//
//  KWContainStringMatcher.m
//  Kiwi
//
//  Created by Kristopher Johnson on 4/28/13.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import "KWContainStringMatcher.h"
#import "KWFormatter.h"

@interface KWContainStringMatcher ()

@property (nonatomic, copy) NSString *substring;
@property (nonatomic) NSStringCompareOptions options;

@end


@implementation KWContainStringMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"containString:",
             @"containString:options:",
             @"startWithString:",
             @"endWithString:"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    NSString *subjectString = (NSString *)self.subject;
    if (![subjectString isKindOfClass:[NSString class]]) {
        [NSException raise:@"KWMatcherException" format:@"subject is not a string"];
        return NO;
    }
    
    NSRange range = [subjectString rangeOfString:self.substring options:self.options];
    return (range.location != NSNotFound);
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"%@ did not contain string \"%@\"",
            [KWFormatter formatObject:self.subject],
            self.substring];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"expected subject not to contain string \"%@\"",
            self.substring];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"contain substring \"%@\"", self.substring];
}

#pragma mark - Configuring matchers

- (void)containString:(NSString *)substring {
    self.substring = substring;
    self.options = 0;
}

- (void)containString:(NSString *)substring options:(NSStringCompareOptions)options {
    self.substring = substring;
    self.options = options;
}

- (void)startWithString:(NSString *)prefix {
    self.substring = prefix;
    self.options = NSAnchoredSearch;
}

- (void)endWithString:(NSString *)suffix {
    self.substring = suffix;
    self.options = NSAnchoredSearch | NSBackwardsSearch;
}

@end


