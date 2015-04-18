//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWExampleNode.h"

@interface KWLetNode : NSObject<KWExampleNode>

- (instancetype)initWithSymbolName:(NSString *)aSymbolName objectRef:(id *)anObjectRef block:(id (^)(void))block;
+ (instancetype)letNodeWithSymbolName:(NSString *)aSymbolName objectRef:(id *)anObjectRef block:(id (^)(void))block;

@property (nonatomic, copy) NSString *symbolName;
@property (nonatomic, copy) id (^block)(void);
@property (nonatomic, readonly) __autoreleasing id *objectRef;

- (id)evaluate;
- (void)evaluateTree;

- (void)addLetNode:(KWLetNode *)aNode;
- (void)unlink;

// The parent/child relationship describes let nodes declared in nested
// contexts -- evaluating a node returns the value of the deepest
// evaluated child.
@property (nonatomic, readonly, weak) KWLetNode *parent;
@property (nonatomic, readonly, strong) KWLetNode *child;

// The next/previous relationship describes the order in which nodes
// of different symbols were declared.
@property (nonatomic, readonly, strong) KWLetNode *next;
@property (nonatomic, readonly, weak) KWLetNode *previous;

@end
