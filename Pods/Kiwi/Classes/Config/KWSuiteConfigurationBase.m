//
//  KWSuiteConfigurationBase.m
//  Kiwi
//
//  Created by Adam Sharp on 14/12/2013.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import "KWSuiteConfigurationBase.h"
#import "KWSpec.h"

#define INVOKE(block) if((block)) { (block)(); }

void beforeEachSpec(void (^block)(void));
void afterEachSpec(void (^block)(void));

@interface KWSuiteConfigurationBase ()
@property (nonatomic, copy) void (^beforeEachSpecBlock)(void);
@property (nonatomic, copy) void (^afterEachSpecBlock)(void);
@end

@implementation KWSuiteConfigurationBase

+ (instancetype)defaultConfiguration
{
    static Class configClass;
    static KWSuiteConfigurationBase *defaultConfiguration;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configClass = NSClassFromString(@"KWSuiteConfiguration");
        if (configClass && [configClass isSubclassOfClass:[self class]]) {
            defaultConfiguration = [configClass new];
        }
    });

    return defaultConfiguration;
}

- (void)configureSuite {}

- (void)setUp {
    [self configureSuite];
    INVOKE(self.beforeAllSpecsBlock);
}

- (void)tearDown {
    INVOKE(self.afterAllSpecsBlock);
}

#pragma mark - Unused methods

- (void)setUpSpec:(KWSpec *)spec {
    INVOKE(self.beforeEachSpecBlock);
}

- (void)tearDownSpec:(KWSpec *)spec {
    INVOKE(self.afterEachSpecBlock);
}

@end

void beforeAllSpecs(void (^block)(void)) {
    [[KWSuiteConfigurationBase defaultConfiguration] setBeforeAllSpecsBlock:block];
}

void afterAllSpecs(void (^block)(void)) {
    [[KWSuiteConfigurationBase defaultConfiguration] setAfterAllSpecsBlock:block];
}

void beforeEachSpec(void (^block)(void)) {
    [[KWSuiteConfigurationBase defaultConfiguration] setBeforeEachSpecBlock:block];
}

void afterEachSpec(void (^block)(void)) {
    [[KWSuiteConfigurationBase defaultConfiguration] setAfterEachSpecBlock:block];
}
