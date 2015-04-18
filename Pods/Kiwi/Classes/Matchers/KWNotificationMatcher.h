//
//  KWNotificationMatcher.h
//
//  Created by Paul Zabelin on 7/12/12.
//  Copyright (c) 2012 Blazing Cloud, Inc. All rights reserved.
//

#import "KWMatcher.h"

typedef void (^PostedNotificationBlock)(NSNotification* note);

@interface KWNotificationMatcher : KWMatcher

- (void)bePosted;
- (void)bePostedWithObject:(id)object;
- (void)bePostedWithUserInfo:(NSDictionary *)userInfo;
- (void)bePostedWithObject:(id)object andUserInfo:(NSDictionary *)userInfo;
- (void)bePostedEvaluatingBlock:(PostedNotificationBlock)block;

@end
