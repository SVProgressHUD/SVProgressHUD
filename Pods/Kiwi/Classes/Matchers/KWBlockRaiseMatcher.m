//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWBlockRaiseMatcher.h"
#import "KWBlock.h"

@interface KWBlockRaiseMatcher()

@property (nonatomic, readwrite, strong) NSException *exception;
@property (nonatomic, readwrite, strong) NSException *actualException;

@end

@implementation KWBlockRaiseMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"raise",
             @"raiseWithName:",
             @"raiseWithReason:",
             @"raiseWithName:reason:"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    if (![self.subject isKindOfClass:[KWBlock class]])
        [NSException raise:@"KWMatcherException" format:@"subject must be a KWBlock"];

    @try {
        [self.subject call];
    } @catch (NSException *anException) {
        self.actualException = anException;

        if ([self.exception name] != nil && ![[self.exception name] isEqualToString:[anException name]])
            return NO;

        if ([self.exception reason] != nil && ![[self.exception reason] isEqualToString:[anException reason]])
            return NO;

        return YES;
    }

    return NO;
}

#pragma mark - Getting Failure Messages

+ (NSString *)exceptionPhraseWithException:(NSException *)anException {
    if (anException == nil)
        return @"nothing";

    NSString *namePhrase = nil;

    if ([anException name] == nil)
        namePhrase = @"exception";
    else
        namePhrase = [anException name];

    if ([anException reason] == nil)
        return namePhrase;

    return [NSString stringWithFormat:@"%@ \"%@\"", namePhrase, [anException reason]];
}

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected %@, but %@ raised",
                                      [[self class] exceptionPhraseWithException:self.exception],
                                      [[self class] exceptionPhraseWithException:self.actualException]];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"expected %@ not to be raised",
                                      [[self class] exceptionPhraseWithException:self.actualException]];
}

#pragma mark - Configuring Matchers

- (void)raise {
    [self raiseWithName:nil reason:nil];
}

- (void)raiseWithName:(NSString *)aName {
    [self raiseWithName:aName reason:nil];
}

- (void)raiseWithReason:(NSString *)aReason {
    [self raiseWithName:nil reason:aReason];
}

- (void)raiseWithName:(NSString *)aName reason:(NSString *)aReason {
    self.exception = [NSException exceptionWithName:aName reason:aReason userInfo:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"raise %@", [[self class] exceptionPhraseWithException:self.exception]];
}

@end
