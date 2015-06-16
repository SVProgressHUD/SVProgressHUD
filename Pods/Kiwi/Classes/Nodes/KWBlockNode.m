//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWBlockNode.h"

@implementation KWBlockNode

@synthesize description = _description;

#pragma mark - Initializing

- (id)initWithCallSite:(KWCallSite *)aCallSite description:(NSString *)aDescription block:(void (^)(void))block {
    self = [super init];
    if (self) {
        _callSite = aCallSite;
        _description = [aDescription copy];
        _block = [block copy];
    }

    return self;
}

- (void)performBlock {
    if (self.block != nil) { self.block(); }
}

@end
