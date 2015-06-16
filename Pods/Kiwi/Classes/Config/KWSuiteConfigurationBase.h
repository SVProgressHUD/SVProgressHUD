//
//  KWSuiteConfigurationBase.h
//  Kiwi
//
//  Created by Adam Sharp on 14/12/2013.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWSuiteConfigurationBase : NSObject

+ (instancetype)defaultConfiguration;

- (void)configureSuite;

- (void)setUp;
- (void)tearDown;

@property (nonatomic, copy) void (^beforeAllSpecsBlock)(void);
@property (nonatomic, copy) void (^afterAllSpecsBlock)(void);

@end

void beforeAllSpecs(void (^block)(void));
void afterAllSpecs(void (^block)(void));
