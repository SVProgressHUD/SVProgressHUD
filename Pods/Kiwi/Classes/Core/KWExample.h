//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWLet.h"
#import "KWBlock.h"
#import "KWVerifying.h"
#import "KWExpectationType.h"
#import "KWExampleNode.h"
#import "KWExampleNodeVisitor.h"
#import "KWReporting.h"
#import "KWExampleDelegate.h"

@class KWCallSite;
@class KWExampleSuite;
@class KWContextNode;

@interface KWExample : NSObject <KWExampleNodeVisitor, KWReporting>

@property (nonatomic, strong, readonly) NSMutableArray *lastInContexts;
@property (nonatomic, weak) KWExampleSuite *suite;
@property (nonatomic, strong) id<KWVerifying> unresolvedVerifier;


- (id)initWithExampleNode:(id<KWExampleNode>)node;

#pragma mark - Adding Verifiers

- (id)addVerifier:(id<KWVerifying>)aVerifier;
- (id)addExistVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite;
- (id)addMatchVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite;
- (id)addAsyncVerifierWithExpectationType:(KWExpectationType)anExpectationType callSite:(KWCallSite *)aCallSite timeout:(NSTimeInterval)timeout shouldWait:(BOOL)shouldWait;

#pragma mark - Report failure

- (void)reportFailure:(KWFailure *)failure;

#pragma mark - Running

- (void)runWithDelegate:(id<KWExampleDelegate>)delegate;

#pragma mark - Anonymous It Node Descriptions

- (NSString *)generateDescriptionForAnonymousItNode;

#pragma mark - Checking if last in context

- (BOOL)isLastInContext:(KWContextNode *)context;

#pragma mark - Full description with context

- (NSString *)descriptionWithContext;

#pragma mark - Format description as a valid selector

@property (readonly) NSString *selectorName;

@end

#pragma mark - Building Example Groups

void describe(NSString *aDescription, void (^block)(void));
void context(NSString *aDescription, void (^block)(void));
void registerMatchers(NSString *aNamespacePrefix);
void beforeAll(void (^block)(void));
void afterAll(void (^block)(void));
void beforeEach(void (^block)(void));
void afterEach(void (^block)(void));
void let_(id *anObjectRef, const char *aSymbolName, id (^block)(void));
void it(NSString *aDescription, void (^block)(void));
void specify(void (^block)(void));
void pending_(NSString *aDescription, void (^block)(void));

void describeWithCallSite(KWCallSite *aCallSite, NSString *aDescription, void (^block)(void));
void contextWithCallSite(KWCallSite *aCallSite, NSString *aDescription, void (^block)(void));
void registerMatchersWithCallSite(KWCallSite *aCallSite, NSString *aNamespacePrefix);
void beforeAllWithCallSite(KWCallSite *aCallSite, void (^block)(void));
void afterAllWithCallSite(KWCallSite *aCallSite, void (^block)(void));
void beforeEachWithCallSite(KWCallSite *aCallSite, void (^block)(void));
void afterEachWithCallSite(KWCallSite *aCallSite, void (^block)(void));
void letWithCallSite(KWCallSite *aCallSite, id *anObjectRef, NSString *aSymbolName, id (^block)(void));
void itWithCallSite(KWCallSite *aCallSite, NSString *aDescription, void (^block)(void));
void pendingWithCallSite(KWCallSite *aCallSite, NSString *aDescription, void (^block)(void));

/**
 Declares a local helper variable that is re-initialised before each
 example with the return value of the provided block.

 You can declare multiple `let` blocks in a context (unlike `beforeEach`,
 which can only be used once per context):

    describe(@"multiple let blocks", ^{
        let(subject, ^{ return @"world"; });
        let(greeting, ^{
            return [NSString stringWithFormat:@"Hello, %@!", subject];
        });

        it(@"allows you to declare multiple variables", ^{
            [[greeting should] equal:@"Hello, world!"];
        });
    });

 You can also redefine a `let` variable inside a nested context. This
 allows for some very useful kinds of code reuse:

    describe(@"greetings in different contexts", ^{
        let(subject, nil); // no subject by default
        let(greeting, ^{
            // greeting references subject
            return [NSString stringWithFormat:@"Hello, %@!", subject];
        });

        context(@"greeting the world", ^{
            let(subject, ^{ return @"world"; }); // redefine subject

            specify(^{
                [[greeting should] equal:@"Hello, world!"];
            });
        });

        context(@"greeting Kiwi", ^{
            let(subject, ^{ return @"Kiwi"; }); // redefine subject

            specify(^{
                [[greeting should] equal:@"Hello, Kiwi!"];
            });
        });
    });

 @param name  A name for the local variable
 @param block The block to evaluate

 @note `let` blocks are evaluated before each example, and also prior to
    evaluating the `beforeEach` block. You should not reference a `let`
    variable in a `beforeAll` block, as its value is undefined at this point.
*/
void let(id name, id (^block)(void)); // coax Xcode into autocompleting
#define let(var, ...) \
    __block __typeof__((__VA_ARGS__)()) var = nil; \
    let_(KW_LET_REF(var), #var, __VA_ARGS__)

#define PRAGMA(x) _Pragma (#x)
#define PENDING(x) PRAGMA(message ( "Pending: " #x ))

#define pending(title, args...) \
PENDING(title) \
pending_(title, ## args)
#define xit(title, args...) \
PENDING(title) \
pending_(title, ## args)
