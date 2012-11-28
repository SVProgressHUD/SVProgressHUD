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

static float progress = 0.0f;
- (IBAction)showWithProgress:(id)sender {
    progress = 0.0f;
    [SVProgressHUD showRingWithProgress:0.0f];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
}

- (void)setProgress {
    progress+=0.1f;
    if (progress > 1.0f) {
        progress = 1.0f;
    }
    //Only following line does the real thing
    //Others are used to simulate the loading process
    [SVProgressHUD setRingProgress:progress];
    
    if (progress == 1.0f && timer) {
        [timer invalidate];
        timer = nil;
        
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
    }
}

- (void)show {
	[SVProgressHUD show];
}

- (void)showWithStatus {
	[SVProgressHUD showWithStatus:@"Doing Stuff"];
}


#pragma mark -
#pragma mark Dismiss Methods Sample

- (void)dismiss {
	[SVProgressHUD dismiss];
}

- (void)dismissSuccess {
	[SVProgressHUD showSuccessWithStatus:@"Great Success!"];
}

- (void)dismissError {
	[SVProgressHUD showErrorWithStatus:@"Failed with Error"];
}

@end
