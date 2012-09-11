//
//  SVProgressHUDAppDelegate.h
//  SVProgressHUD
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *__weak window;
    ViewController *__weak viewController;
}

@property (weak, nonatomic) IBOutlet UIWindow *window;
@property (weak, nonatomic) IBOutlet ViewController *viewController;

@end

