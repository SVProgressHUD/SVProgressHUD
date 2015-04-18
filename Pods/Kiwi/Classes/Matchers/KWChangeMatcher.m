//
//  KWChangeMatcher.m
//  Kiwi
//
//  Copyright (c) 2013 Eloy Durán <eloy.de.enige@gmail.com>.
//  All rights reserved.
//

#import "KWChangeMatcher.h"
#import "KWBlock.h"

@interface KWChangeMatcher ()
@property (nonatomic, copy) KWChangeMatcherCountBlock countBlock;
@property (nonatomic, assign) BOOL anyChange;
@property (nonatomic, assign) NSInteger expectedDifference, expectedTotal, actualTotal;
@end

@implementation KWChangeMatcher

+ (NSArray *)matcherStrings {
    return @[@"change:by:", @"change:"];
}

- (NSString *)failureMessageForShould {
    if (self.anyChange) {
        return @"expected subject to change the count";
    } else {
        return [NSString stringWithFormat:@"expected subject to change the count to %d, got %d", (int)self.expectedTotal, (int)self.actualTotal];
    }
}

- (NSString *)failureMessageForShouldNot {
    if (self.anyChange) {
        return @"expected subject to not change the count";
    } else {
        return [NSString stringWithFormat:@"expected subject not to change the count to %d", (int)self.actualTotal];
    }
}

- (NSString *)description {
    if (self.anyChange) {
        return @"change count";
    } else {
        return [NSString stringWithFormat:@"change count by %d", (int)self.expectedDifference];
    }
}

- (BOOL)evaluate {
    NSInteger before = self.countBlock();
    // Perform actual work, which is expected to change the result of countBlock.
    [self.subject call];
    self.actualTotal = self.countBlock();

    if (self.anyChange) {
        return before != self.actualTotal;
    } else {
        self.expectedTotal = before + self.expectedDifference;
        return self.expectedTotal == self.actualTotal;
    }
}

- (void)change:(KWChangeMatcherCountBlock)countBlock by:(NSInteger)expectedDifference {
    self.anyChange = NO;
    self.expectedDifference = expectedDifference;
    self.countBlock = countBlock;
}

- (void)change:(KWChangeMatcherCountBlock)countBlock {
    self.anyChange = YES;
    self.countBlock = countBlock;
}

@end
