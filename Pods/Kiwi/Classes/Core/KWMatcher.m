//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWMatcher.h"
#import "KWFormatter.h"
#import "KWFutureObject.h"

@implementation KWMatcher

#pragma mark - Initializing

- (id)initWithSubject:(id)anObject {
    self = [super init];
    if (self) {
        _subject = anObject;
    }

    return self;
}

+ (id)matcherWithSubject:(id)anObject {
    return [[self alloc] initWithSubject:anObject];
}


#pragma mark - Properties

- (id)subject
{
  if ([_subject isKindOfClass:[KWFutureObject class]]) {
    return [(KWFutureObject *)_subject object];
  }
  return _subject;
}

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return nil;
}

#pragma mark - Getting Matcher Compatability

+ (BOOL)canMatchSubject:(id)anObject {
    return YES;
}

#pragma mark - Matching

- (BOOL)evaluate {
    [NSException raise:NSInternalInconsistencyException format:@"%@ must override -evaluate",
                                                               [KWFormatter formatObject:[self class]]];
    return NO;
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return @"subject did not meet expectation";
}

- (NSString *)failureMessageForShouldNot {
    NSString *failureMessageForShould = [self failureMessageForShould];
    NSRange markerRange = [failureMessageForShould rangeOfString:@" to "];

    if (markerRange.location == NSNotFound)
        return @"subject did not meet expectation";

    NSRange replacementRange = NSMakeRange(0, markerRange.location + markerRange.length);
    NSString *message = [failureMessageForShould stringByReplacingOccurrencesOfString:@" to "
                                                                        withString:@" not to "
                                                                           options:0
                                                                             range:replacementRange];
    return message;
}

@end
