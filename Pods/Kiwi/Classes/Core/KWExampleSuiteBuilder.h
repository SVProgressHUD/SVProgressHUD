//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWBlock.h"

@class KWCallSite;
@class KWExample;
@class KWExampleSuite;
@class KWContextNode;

@interface KWExampleSuiteBuilder : NSObject

#pragma mark - Initializing

+ (id)sharedExampleSuiteBuilder;

#pragma mark - Building Example Groups

@property (nonatomic, readonly) BOOL isBuildingExampleSuite;
@property (nonatomic, strong, readonly) KWExampleSuite *currentExampleSuite;
@property (nonatomic, strong) KWExample *currentExample;
@property (nonatomic, strong) KWCallSite *focusedCallSite;

//spec file name:line number of callsite
- (void)focusWithURI:(NSString *)nodeUrl;
- (KWExampleSuite *)buildExampleSuite:(void (^)(void))buildingBlock;

- (void)pushContextNodeWithCallSite:(KWCallSite *)aCallSite description:(NSString *)aDescription;
- (void)popContextNode;
- (void)setRegisterMatchersNodeWithCallSite:(KWCallSite *)aCallSite namespacePrefix:(NSString *)aNamespacePrefix;
- (void)setBeforeAllNodeWithCallSite:(KWCallSite *)aCallSite block:(void (^)(void))block;
- (void)setAfterAllNodeWithCallSite:(KWCallSite *)aCallSite block:(void (^)(void))block;
- (void)setBeforeEachNodeWithCallSite:(KWCallSite *)aCallSite block:(void (^)(void))block;
- (void)setAfterEachNodeWithCallSite:(KWCallSite *)aCallSite block:(void (^)(void))block;
- (void)addLetNodeWithCallSite:(KWCallSite *)aCallSite objectRef:(id *)anObjectRef symbolName:(NSString *)aSymbolName block:(id (^)(void))block;
- (void)addItNodeWithCallSite:(KWCallSite *)aCallSite description:(NSString *)aDescription block:(void (^)(void))block;
- (void)addPendingNodeWithCallSite:(KWCallSite *)aCallSite description:(NSString *)aDescription;

- (BOOL)isFocused;
- (BOOL)foundFocus;

@end
