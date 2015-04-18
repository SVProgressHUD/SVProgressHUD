//
//  XCTestSuite+KWConfiguration.m
//  Kiwi
//
//  Created by Adam Sharp on 1/07/2014.
//  Copyright (c) 2014 Allen Ding. All rights reserved.
//

#import <XCTest/XCTestSuite.h>
#import <objc/runtime.h>
#import "KWSuiteConfigurationBase.h"

@interface _KWAllTestsSuite : XCTestSuite
@end

@implementation _KWAllTestsSuite

- (void)setUp {
    [super setUp];
    [[KWSuiteConfigurationBase defaultConfiguration] setUp];
}

- (void)tearDown {
    [[KWSuiteConfigurationBase defaultConfiguration] tearDown];
    [super tearDown];
}

@end

@interface XCTestSuite (KWConfiguration)
@end

@implementation XCTestSuite (KWConfiguration)

+ (void)load {
    Method testSuiteWithName = class_getClassMethod(self, @selector(testSuiteWithName:));
    Method kiwi_testSuiteWithName = class_getClassMethod(self, @selector(kiwi_testSuiteWithName:));
    method_exchangeImplementations(testSuiteWithName, kiwi_testSuiteWithName);
}

+ (id)kiwi_testSuiteWithName:(NSString *)aName {
    id suite = [self kiwi_testSuiteWithName:aName];
    if ([aName isEqualToString:@"All tests"]) {
        if ([suite isMemberOfClass:[XCTestSuite class]]) {
            object_setClass(suite, [_KWAllTestsSuite class]);
        }
    }
    return suite;
}

@end
