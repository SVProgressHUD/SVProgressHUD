//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWContainMatcher.h"
#import "KWFormatter.h"
#import "KWGenericMatchingAdditions.h"

@interface KWContainMatcher()

@property (nonatomic, readwrite, strong) id objects;

@end

@implementation KWContainMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"contain:", @"containObjectsInArray:"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    if (![self.subject respondsToSelector:@selector(containsObjectEqualToOrMatching:)])
        [NSException raise:@"KWMatcherException" format:@"subject does not respond to -containsObjectEqualToOrMatching:"];

    for (id object in self.objects) {
        if (![self.subject containsObjectEqualToOrMatching:object])
          return NO;
    }

    return YES;
}

#pragma mark - Getting Failure Messages

- (NSString *)objectsPhrase {
    if ([self.objects count] == 1)
        return [KWFormatter formatObject:(self.objects)[0]];

    return [NSString stringWithFormat:@"all of %@", [KWFormatter formatObject:self.objects]];
}

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to contain %@", [self objectsPhrase]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"contain %@", [self objectsPhrase]];
}

#pragma mark - Configuring Matchers

- (void)contain:(id)anObject {
    self.objects = @[anObject];
}

- (void)containObjectsInArray:(NSArray *)anArray {
    self.objects = anArray;
}

@end

@implementation KWMatchVerifier(KWContainMatcherAdditions)

#pragma mark - Verifying

- (void)containObjects:(id)firstObject, ... {
    NSMutableArray *objects = [NSMutableArray array];

    va_list argumentList;
    va_start(argumentList, firstObject);
    id object = firstObject;

    while (object != nil) {
        [objects addObject:object];
        object = va_arg(argumentList, id);
    }

    va_end(argumentList);
    [(id)self containObjectsInArray:objects];
}

@end
