//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWFailure.h"
#import "KWCallSite.h"

@implementation KWFailure

#pragma mark - Initializing

- (id)initWithCallSite:(KWCallSite *)aCallSite message:(NSString *)aMessage {
    self = [super init];
    if (self) {
        _callSite = aCallSite;
        _message = [aMessage copy];
    }

    return self;
}

- (id)initWithCallSite:(KWCallSite *)aCallSite format:(NSString *)format, ... {
    va_list argumentList;
    va_start(argumentList, format);
    NSString *aMessage = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    return [self initWithCallSite:aCallSite message:aMessage];
}

+ (id)failureWithCallSite:(KWCallSite *)aCallSite message:(NSString *)aMessage {
    return [[self alloc] initWithCallSite:aCallSite message:aMessage];
}

+ (id)failureWithCallSite:(KWCallSite *)aCallSite format:(NSString *)format, ... {
    va_list argumentList;
    va_start(argumentList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    return [self failureWithCallSite:aCallSite message:message];
}

@end
