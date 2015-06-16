//
//  KWAsyncVerifier.m
//  iOSFalconCore
//
//  Created by Luke Redpath on 13/01/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "KWAsyncVerifier.h"
#import "KWFailure.h"
#import "KWMatching.h"
#import "KWReporting.h"
#import "KWProbePoller.h"

@implementation KWAsyncVerifier

+ (id)asyncVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite matcherFactory:(KWMatcherFactory *)aMatcherFactory reporter:(id<KWReporting>)aReporter probeTimeout:(NSTimeInterval)probeTimeout shouldWait:(BOOL)shouldWait {
    KWAsyncVerifier *verifier = [[self alloc] initWithExpectationType:anExpectationType callSite:aCallSite matcherFactory:aMatcherFactory reporter:aReporter];
    verifier.timeout = probeTimeout;
    verifier.shouldWait = shouldWait;
    return verifier;
}

- (id)initWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite matcherFactory:(KWMatcherFactory *)aMatcherFactory reporter:(id<KWReporting>)aReporter {
    self = [super initWithExpectationType:anExpectationType callSite:aCallSite matcherFactory:aMatcherFactory reporter:aReporter];
    if (self) {
        self.timeout = kKW_DEFAULT_PROBE_TIMEOUT;
    }
    return self;
}

- (void)verifyWithProbe:(KWAsyncMatcherProbe *)aProbe {
    @try {
        KWProbePoller *poller = [[KWProbePoller alloc] initWithTimeout:self.timeout delay:kKW_DEFAULT_PROBE_DELAY shouldWait: self.shouldWait];
        
        if (![poller check:aProbe]) {
            if (self.expectationType == KWExpectationTypeShould) {
                NSString *message = [aProbe.matcher failureMessageForShould];
                KWFailure *failure = [KWFailure failureWithCallSite:self.callSite message:message];
                [self.reporter reportFailure:failure];
            }
        } else {
            // poller returned YES -- fail if expectation is NOT
            if (self.expectationType == KWExpectationTypeShouldNot) {
                NSString *message = [aProbe.matcher failureMessageForShouldNot];
                KWFailure *failure = [KWFailure failureWithCallSite:self.callSite message:message];
                [self.reporter reportFailure:failure];
            }
        }
		
        
    } @catch (NSException *exception) {
        KWFailure *failure = [KWFailure failureWithCallSite:self.callSite message:[exception description]];
        [self.reporter reportFailure:failure];
    }
}

- (void)verifyWithMatcher:(id<KWMatching>)aMatcher {
    KWAsyncMatcherProbe *probe = [[KWAsyncMatcherProbe alloc] initWithMatcher:aMatcher];
    [self verifyWithProbe:probe];
}

@end

@implementation KWAsyncMatcherProbe

- (id)initWithMatcher:(id<KWMatching>)aMatcher {
    self = [super init];
    if (self) {
        _matcher = aMatcher;
        
        // make sure the matcher knows we are going to evaluate it multiple times
        if ([aMatcher respondsToSelector:@selector(willEvaluateMultipleTimes)]) {
            [aMatcher setWillEvaluateMultipleTimes:YES];
        }
    }
    return self;
}


- (BOOL)isSatisfied {
    return self.matchResult;
}

- (void)sample {
    self.matchResult = [self.matcher evaluate];
}

@end

