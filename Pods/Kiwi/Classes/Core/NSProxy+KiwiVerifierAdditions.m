//
// Licensed under the terms in License.txt
//
// Copyright 2013 Allen Ding. All rights reserved.
//
// Contributed by https://github.com/dwlnetnl
//

#import "NSProxy+KiwiVerifierAdditions.h"
#import "KWVerifying.h"

@implementation NSProxy (KiwiVerifierAdditions)

#pragma mark - Attaching to Verifiers

- (id)attachToVerifier:(id<KWVerifying>)aVerifier {
    [aVerifier setSubject:self];
    return aVerifier;
}

- (id)attachToVerifier:(id<KWVerifying>)firstVerifier verifier:(id<KWVerifying>)secondVerifier {
    [firstVerifier setSubject:self];
    [secondVerifier setSubject:self];
    return firstVerifier;
}

@end
