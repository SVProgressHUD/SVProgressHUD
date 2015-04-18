//
//  StringPrefixMatcher.m
//  Kiwi
//
//  Created by Luke Redpath on 17/01/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import "KWStringPrefixMatcher.h"

@interface KWStringPrefixMatcher(){}
@property (nonatomic, copy) NSString *prefix;
@end

@implementation KWStringPrefixMatcher

+ (id)matcherWithPrefix:(NSString *)aPrefix {
    return [[self alloc] initWithPrefix:aPrefix];
}

- (id)initWithPrefix:(NSString *)aPrefix {
    self = [super init];
    if (self) {
        _prefix = [aPrefix copy];
    }
    return self;
}


- (BOOL)matches:(id)item {
    if (![item respondsToSelector:@selector(hasPrefix:)])
        return NO;
    
    return [item hasPrefix:self.prefix];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"a string with prefix '%@'", self.prefix];
}

@end
