//
//  NSObject+KiwiAdditions.m
//  Kiwi
//
//  Created by Luke Redpath on 24/01/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import "KWGenericMatchingAdditions.h"
#import "KWGenericMatcher.h"
#import "KWGenericMatchEvaluator.h"

@implementation NSObject (KiwiGenericMatchingAdditions)

- (BOOL)isEqualOrMatches:(id)object {
    if ([KWGenericMatchEvaluator isGenericMatcher:self]) {
        return [KWGenericMatchEvaluator genericMatcher:self matches:object];
    }
    return [self isEqual:object];
}

@end

@implementation NSArray (KiwiGenericMatchingAdditions)

- (BOOL)containsObjectEqualToOrMatching:(id)object {
    if ([KWGenericMatchEvaluator isGenericMatcher:object]) {
        return [self containsObjectMatching:object];
    }
    return [self containsObject:object];
}

- (BOOL)containsObjectMatching:(id)matcher {
    NSIndexSet *indexSet = [self indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL matches = [KWGenericMatchEvaluator genericMatcher:matcher matches:obj];
        if (matches) {
            *stop = YES;
        }
        return matches;
    }];

    return (indexSet.count > 0);
}

@end

@implementation NSSet (KiwiGenericMatchingAdditions)

- (BOOL)containsObjectEqualToOrMatching:(id)object {
    if ([KWGenericMatchEvaluator isGenericMatcher:object]) {
        return [[self allObjects] containsObjectMatching:object];
    }
    return [self containsObject:object];
}

@end

@implementation NSOrderedSet (KiwiGenericMatchingAdditions)

- (BOOL)containsObjectEqualToOrMatching:(id)object {
    if ([KWGenericMatchEvaluator isGenericMatcher:object]) {
        return [[self array] containsObjectMatching:object];
    }
    return [self containsObject:object];
}

@end
