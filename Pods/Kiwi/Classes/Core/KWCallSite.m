//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWCallSite.h"

@implementation KWCallSite

#pragma mark - Initializing

- (id)initWithFilename:(NSString *)aFilename lineNumber:(NSUInteger)aLineNumber {
    self = [super init];
    if (self) {
        _filename = [aFilename copy];
        _lineNumber = aLineNumber;
    }

    return self;
}

+ (id)callSiteWithFilename:(NSString *)aFilename lineNumber:(NSUInteger)aLineNumber {
    return [[self alloc] initWithFilename:aFilename lineNumber:aLineNumber];
}

#pragma mark - Identifying and Comparing

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@%u", self.filename, (unsigned)self.lineNumber] hash];
}

- (BOOL)isEqual:(id)anObject {
    if (![anObject isKindOfClass:[KWCallSite class]])
        return NO;

    return [self isEqualToCallSite:anObject];
}

- (BOOL)isEqualToCallSite:(KWCallSite *)aCallSite {
    return [self.filename isEqualToString:aCallSite.filename] && (self.lineNumber == aCallSite.lineNumber);
}

@end
