//
//  KWHaveValueMatcher.m
//  Kiwi
//
//  Created by Luke Redpath on 24/01/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import "KWHaveValueMatcher.h"
#import "KWGenericMatchingAdditions.h"
#import "KWGenericMatcher.h"
#import "KWFormatter.h"

@interface KWHaveValueMatcher()

@property (nonatomic, strong) NSString *expectedKey;
@property (nonatomic, strong) NSString *expectedKeyPath;
@property (nonatomic, strong) id expectedValue;

@end

@implementation KWHaveValueMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"haveValue:forKey:",
             @"haveValueForKey:",
             @"haveValue:forKeyPath:",
             @"haveValueForKeyPath:"];
}

#pragma mark - Matching

- (BOOL)evaluate {
    BOOL matched = NO;
    
    @try {
        id value = [self subjectValue];
        
        if (value) {
            matched = YES;
            
            if (self.expectedValue) {
                matched = [self.expectedValue isEqualOrMatches:value];
            }
        }
    }
    @catch (NSException * e) {} // catch KVO non-existent key errors
    
    return matched;
}

- (NSString *)failureMessageForShould {
    if (self.expectedValue == nil) {
        return [NSString stringWithFormat:@"expected subject to have a value for key %@",
                                          [KWFormatter formatObject:self.expectedKey]];
    }
    id subjectValue = [self subjectValue];
    if (subjectValue) {
        return [NSString stringWithFormat:@"expected subject to have value %@ for key %@, but it had value %@ instead",
                                          [KWFormatter formatObject:self.expectedValue],
                                          [KWFormatter formatObject:self.expectedKey],
                                          [KWFormatter formatObject:subjectValue]];
    } else {
        return [NSString stringWithFormat:@"expected subject to have value %@ for key %@, but the key was not present",
                                          [KWFormatter formatObject:self.expectedValue],
                                          [KWFormatter formatObject:self.expectedKey]];
    }
}

- (id)subjectValue {
    id value = nil;
    
    if (self.expectedKey) {
        value = [self.subject valueForKey:self.expectedKey];
    } else
        if (self.expectedKeyPath) {
            value = [self.subject valueForKeyPath:self.expectedKeyPath];
        }
    return value;
}

- (NSString *)description {
    NSString *keyDescription = nil;
    
    if (self.expectedKey) {
        keyDescription = [NSString stringWithFormat:@"key %@", [KWFormatter formatObject:self.expectedKey]];
    }
    else {
        keyDescription = [NSString stringWithFormat:@"keypath %@", [KWFormatter formatObject:self.expectedKeyPath]];
    }
    
    NSString *valueDescription = nil;
    
    if (self.expectedValue) {
        valueDescription = [NSString stringWithFormat:@"value %@", [KWFormatter formatObject:self.expectedValue]];
    }
    else {
        valueDescription = @"value";
    }
    
    return [NSString stringWithFormat:@"have %@ for %@", valueDescription, keyDescription];
}

#pragma mark - Configuring Matchers

- (void)haveValue:(id)value forKey:(NSString *)key {
    self.expectedKey = key;
    self.expectedValue = value;
}

- (void)haveValue:(id)value forKeyPath:(NSString *)key {
    self.expectedKeyPath = key;
    self.expectedValue = value;
}

- (void)haveValueForKey:(NSString *)key {
    self.expectedKey = key;
    self.expectedValue = nil;
}

- (void)haveValueForKeyPath:(NSString *)keyPath {
    self.expectedKeyPath = keyPath;
    self.expectedValue = nil;
}

@end
