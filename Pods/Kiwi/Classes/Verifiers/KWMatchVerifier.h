//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWExpectationType.h"
#import "KWVerifying.h"

@class KWCallSite;
@class KWMatcherFactory;

@protocol KWMatching;
@protocol KWReporting;

@interface KWMatchVerifier : NSObject<KWVerifying>

#pragma mark - Properties

@property (nonatomic, readonly) KWExpectationType expectationType;

@property (nonatomic, readonly) KWMatcherFactory *matcherFactory;
@property (nonatomic, readonly) id<KWReporting> reporter;

@property (nonatomic, strong) id subject;


#pragma mark - Initializing

- (id)initForShouldWithCallSite:(KWCallSite *)aCallSite matcherFactory:(KWMatcherFactory *)aMatcherFactory reporter:(id<KWReporting>)aReporter;
- (id)initForShouldNotWithCallSite:(KWCallSite *)aCallSite matcherFactory:(KWMatcherFactory *)aMatcherFactory reporter:(id<KWReporting>)aReporter;
- (id)initWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite matcherFactory:(KWMatcherFactory *)aMatcherFactory reporter:(id<KWReporting>)aReporter;

+ (id<KWVerifying>)matchVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite matcherFactory:(KWMatcherFactory *)aMatcherFactory reporter:(id<KWReporting>)aReporter;

- (void)verifyWithMatcher:(id<KWMatching>)aMatcher;

@end
