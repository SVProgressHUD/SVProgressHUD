//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "NSObject+KiwiVerifierAdditions.h"
#import "KWVerifying.h"

@implementation NSObject(KiwiVerifierAdditions)

#pragma mark - Attaching to Verifiers

- (id)attachToVerifier:(id<KWVerifying>)aVerifier {
    [aVerifier setSubject:self];
    return aVerifier;
}

@end
