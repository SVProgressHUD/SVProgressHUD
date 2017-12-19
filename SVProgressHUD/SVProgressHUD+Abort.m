//
//  SVProgressHUD+Abort.m
//  SVProgressHUD
//
//  Created by Alexej Scheffel on 23.11.17.
//  Copyright © 2017 EmbeddedSources. All rights reserved.
//

#import "SVProgressHUD+Abort.h"

@implementation SVProgressHUD (Abort)

static NSString *_abortText;
static SVAbortBlock _abortBlock;

+ (void)showProgress:(float)progress status:(NSString *)status withAbortBlock:(SVAbortBlock)abortBlock {
    
    // set mask type//
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    // register notification //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abort) name:SVProgressHUDDidTouchDownInsideNotification object:nil];
    
    // validate status //
    status = status ? : @"";
    status = [status stringByAppendingString:_abortText ? : @""];
    
    // block //
    _abortBlock = abortBlock;
    
    // present //
    [SVProgressHUD showProgress:progress status:status];
}

+ (void)abort {
    // execute the abort block //
    if (_abortBlock) {
        _abortBlock();
    }
    
    // kill the block property -> dont run multiple times //
    _abortBlock = nil;
}

+ (void)dismissAbortBlock {
    _abortBlock = nil;
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
}

+ (void)setAbortText:(NSString *)abortText {
    _abortText = abortText ? : @"";
}

@end
