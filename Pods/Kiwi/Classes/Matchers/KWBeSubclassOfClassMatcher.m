//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWBeSubclassOfClassMatcher.h"
#import "KWFormatter.h"

@interface KWBeSubclassOfClassMatcher()

#pragma mark - Properties

@property (nonatomic, assign) Class targetClass;

@end

@implementation KWBeSubclassOfClassMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"beSubclassOfClass:"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    return [self.subject isSubclassOfClass:self.targetClass];
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to be subclass of %@, got %@",
                                      NSStringFromClass(self.targetClass),
                                      NSStringFromClass([self.subject class])];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"be subclass of %@",
                                      NSStringFromClass(self.targetClass)];
}

#pragma mark - Configuring Matchers

- (void)beSubclassOfClass:(Class)aClass {
    self.targetClass = aClass;
}

@end
