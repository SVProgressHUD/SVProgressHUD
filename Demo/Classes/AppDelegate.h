//
//  SVProgressHUDAppDelegate.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2017 Sam Vermette and contributors. All rights reserved.
//


#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet ViewController *viewController;

@end

