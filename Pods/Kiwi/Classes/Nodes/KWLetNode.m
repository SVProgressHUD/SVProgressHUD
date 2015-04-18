//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWLetNode.h"
#import "KWExampleNodeVisitor.h"

@interface KWLetNode ()

@property (nonatomic, weak) KWLetNode *parent;
@property (nonatomic, strong) KWLetNode *child;

@property (nonatomic, strong) KWLetNode *next;
@property (nonatomic, weak) KWLetNode *previous;

@end

@implementation KWLetNode

@synthesize objectRef = _objectRef;

- (instancetype)initWithSymbolName:(NSString *)aSymbolName objectRef:(__autoreleasing id *)anObjectRef block:(id (^)(void))block
{
    if ((self = [super init])) {
        _symbolName = [aSymbolName copy];
        _objectRef = anObjectRef;
        _block = [block copy];
    }
    return self;
}

+ (instancetype)letNodeWithSymbolName:(NSString *)aSymbolName objectRef:(__autoreleasing id *)anObjectRef block:(id (^)(void))block
{
    return [[self alloc] initWithSymbolName:aSymbolName objectRef:anObjectRef block:block];
}

#pragma mark - Evaluating nodes

- (id)evaluate
{
    id result = nil;
    if (self.child) {
        result = [self.child evaluate];
    }
    else if (self.block) {
        result = self.block();
    }

    *self.objectRef = result;
    return result;
}

- (void)evaluateTree
{
    [self evaluate];
    [self.next evaluateTree];
}

#pragma mark - Managing node relationships

- (void)addLetNode:(KWLetNode *)aNode
{
    if (![aNode isEqual:self]) {
        if ([aNode.symbolName isEqualToString:self.symbolName]) {
            [self addChild:aNode];
        }
        else if (self.next) {
            [self.next addLetNode:aNode];
        }
        else {
            self.next = aNode;
        }
    }
}

- (void)addChild:(KWLetNode *)aNode
{
    if (self.child && ![self.child isEqual:aNode]) {
        [self.child addChild:aNode];
    }
    else {
        self.child = aNode;
    }
}

- (void)setNext:(KWLetNode *)aNode
{
    aNode.previous = self;
    _next = aNode;
}

- (void)setChild:(KWLetNode *)aNode
{
    aNode.parent = self;
    _child = aNode;
}

- (void)unlink
{
    [self.next unlink];
    self.previous.next = nil;
    self.previous = nil;

    [self.child unlink];
    self.parent.child = nil;
    self.parent = nil;
}

#pragma mark - Accepting visitors

- (void)acceptExampleNodeVisitor:(id<KWExampleNodeVisitor>)aVisitor
{
    [aVisitor visitLetNode:self];
}

#pragma mark - Describing nodes

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {%@\n}", [[self class] description], [self recursiveDescription]];
}

- (NSString *)nodeDescription
{
    return [NSString stringWithFormat:@"<%@ \"%@\">", [[self class] description], self.block ? self.block() : nil];
}

- (NSString *)recursiveDescription
{
    if (!self.parent) {
        NSMutableString *description = [NSMutableString stringWithFormat:@"\n\t%@:\n\t\t%@", self.symbolName, [self nodeDescription]];
        if (self.child) [description appendFormat:@"%@", [self.child recursiveDescription]];
        if (self.next) [description appendString:[self.next recursiveDescription]];
        return [description copy];
    }
    else {
        NSMutableString *description = [NSMutableString stringWithFormat:@",\n\t\t%@", [self nodeDescription]];
        if (self.child) [description appendString:[self.child recursiveDescription]];
        return [description copy];
    }
}

@end
