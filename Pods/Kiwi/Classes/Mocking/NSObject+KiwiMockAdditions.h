//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@protocol KiwiMockAdditions <NSObject>

#pragma mark - Creating Mocks

+ (id)mock;
+ (id)mockWithName:(NSString *)aName;

+ (id)nullMock;
+ (id)nullMockWithName:(NSString *)aName;

@end

@interface NSObject(KiwiMockAdditions) <KiwiMockAdditions>

@end
