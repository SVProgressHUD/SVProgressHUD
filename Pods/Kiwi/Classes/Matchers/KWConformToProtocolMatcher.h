//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

@interface KWConformToProtocolMatcher : KWMatcher

#pragma mark - Configuring Matchers

- (void)conformToProtocol:(Protocol *)aProtocol;

@end
