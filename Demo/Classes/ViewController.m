//
//  SVProgressHUDViewController.m
//  SVProgressHUD
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"

@implementation ViewController {
    NSTimer *timer;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Show Methods Sample

- (void)show {
	[SVProgressHUD show];
}

- (void)showWithStatus {
	[SVProgressHUD showWithStatus:@"Doing Stuff"];
}

static float progress = 0.0f;
- (IBAction)showWithProgress:(id)sender {
    progress = 0.0f;
    [SVProgressHUD showProgress:0 status:@"Loading"];
    if (timer) {
        [timer invalidate];
    }
        
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
}

- (void)setProgress {
    progress+=0.1f;
    [SVProgressHUD showProgress:progress status:@"Loading"];

    if(progress >= 1.0f) {
        [timer invalidate];
        timer = nil;
        
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
    }
}


#pragma mark -
#pragma mark Dismiss Methods Sample

- (void)dismiss {
	[SVProgressHUD dismiss];
    [timer invalidate];
}

- (void)dismissSuccess {
	[SVProgressHUD showSuccessWithStatus:@"Great Success!"];
    [timer invalidate];
}

- (void)dismissError {
	[SVProgressHUD showErrorWithStatus:@"Failed with Error"];
    [timer invalidate];
}

@end
