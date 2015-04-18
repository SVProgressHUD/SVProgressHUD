//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWCountType.h"
#import "KWMessageSpying.h"

@class KWMessagePattern;

@interface KWMessageTracker : NSObject<KWMessageSpying>

#pragma mark - Initializing

- (id)initWithSubject:(id)anObject messagePattern:(KWMessagePattern *)aMessagePattern countType:(KWCountType)aCountType count:(NSUInteger)aCount;

+ (id)messageTrackerWithSubject:(id)anObject messagePattern:(KWMessagePattern *)aMessagePattern countType:(KWCountType)aCountType count:(NSUInteger)aCount;

#pragma mark - Properties

@property (nonatomic, readonly) id subject;
@property (nonatomic, readonly) KWMessagePattern *messagePattern;
@property (nonatomic, readonly) KWCountType countType;
@property (nonatomic, readonly) NSUInteger count;

#pragma mark - Stopping Tracking

- (void)stopTracking;

#pragma mark - Getting Message Tracker Status

- (BOOL)succeeded;

#pragma mark - Getting Phrases

- (NSString *)expectedCountPhrase;
- (NSString *)receivedCountPhrase;

@end
