//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWConformToProtocolMatcher.h"
#import "KWFormatter.h"

@interface KWConformToProtocolMatcher()

@property (nonatomic, assign) Protocol *protocol;

@end

@implementation KWConformToProtocolMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"conformToProtocol:"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    return [self.subject conformsToProtocol:self.protocol];
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to conform to %@ protocol",
                                      NSStringFromProtocol(self.protocol)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"conform to %@ protocol", NSStringFromProtocol(self.protocol)];
}

#pragma mark - Configuring Matchers

- (void)conformToProtocol:(Protocol *)aProtocol {
    self.protocol = aProtocol;
}

@end
