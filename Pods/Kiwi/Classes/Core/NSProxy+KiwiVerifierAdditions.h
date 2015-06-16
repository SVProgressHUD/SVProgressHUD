//
// Licensed under the terms in License.txt
//
// Copyright 2013 Allen Ding. All rights reserved.
//
// Contributed by https://github.com/dwlnetnl
//

#import "KiwiConfiguration.h"

@protocol KWVerifying;

@interface NSProxy (KiwiVerifierAdditions)

#pragma mark - Attaching to Verifiers

- (id)attachToVerifier:(id<KWVerifying>)aVerifier;
- (id)attachToVerifier:(id<KWVerifying>)firstVerifier verifier:(id<KWVerifying>)secondVerifier;

@end
