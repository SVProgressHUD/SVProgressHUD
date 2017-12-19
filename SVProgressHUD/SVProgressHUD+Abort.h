//
//  SVProgressHUD+Abort.h
//  SVProgressHUD
//
//  Created by Alexej Scheffel on 23.11.17.
//  Copyright © 2017 EmbeddedSources. All rights reserved.
//

// #import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

typedef void(^SVAbortBlock)(void);

@interface SVProgressHUD (Abort)

+ (void)showProgress:(float)progress status:(NSString *)status withAbortBlock:(SVAbortBlock)abortBlock;
+ (void)dismissAbortBlock;
+ (void)setAbortText:(NSString *)abortText;

@end
