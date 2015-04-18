//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWExpectationType.h"
#import "KWVerifying.h"

@class KWCallSite;

@protocol KWReporting;

@interface KWExistVerifier : NSObject<KWVerifying>

#pragma mark - Initializing

- (id)initWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite reporter:(id<KWReporting>)aReporter;

+ (id)existVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite reporter:(id<KWReporting>)aReporter;

#pragma mark - Properties

@property (nonatomic, strong) id subject;

@end
