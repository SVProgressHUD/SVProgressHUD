//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import <XCTest/XCTest.h>
#import "KWExpectationType.h"
#import "KWVerifying.h"
#import "KWExampleDelegate.h"

@class KWCallSite;

@interface KWSpec : XCTestCase<KWExampleDelegate>

#pragma mark - Adding Verifiers

+ (id)addVerifier:(id<KWVerifying>)aVerifier;
+ (id)addExistVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite;
+ (id)addMatchVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite;
+ (id)addAsyncVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite timeout:(NSTimeInterval)timeout shouldWait:(BOOL)shouldWait;

#pragma mark - Building Example Groups

+ (NSString *)file;
+ (void)buildExampleGroups;

@end
