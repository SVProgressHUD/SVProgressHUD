# SVProgressHUD

![Pod Version](https://img.shields.io/cocoapods/v/SVProgressHUD.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/SVProgressHUD.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/SVProgressHUD.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`SVProgressHUD` is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS.

![SVProgressHUD](http://f.cl.ly/items/2G1F1Z0M0k0h2U3V1p39/SVProgressHUD.gif)

## Demo		

Try `SVProgressHUD` on [Appetize.io](https://appetize.io/app/p8r2cvy8kq74x7q7tjqf5gyatr).

## Installation

### From CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like `SVProgressHUD` in your projects. First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'SVProgressHUD'
```

If you want to use the latest features of `SVProgressHUD` add `:head`:

```ruby
pod 'SVProgressHUD', :head
```

This pulls from the `master` branch directly. We are usually careful about what we push there and this is the version we use ourselves in all of our projects.

Second, install `SVProgressHUD` into your project:

```ruby
pod install
```

### Carthage

You can install `SVProgressHUD` with [Carthage](https://github.com/Carthage/Carthage).

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/SVProgressHUD/SVProgressHUD)

### Manually

* Drag the `SVProgressHUD/SVProgressHUD` folder into your project.
* Take care that `SVProgressHUD.bundle` is added to `Targets->Build Phases->Copy Bundle Resources`.
* Add the **QuartzCore** framework to your project.

## Usage

(see sample Xcode project in `/Demo`)

`SVProgressHUD` is created as a singleton (i.e. it doesn't need to be explicitly allocated and instantiated; you directly call `[SVProgressHUD method]`).

**Use `SVProgressHUD` wisely! Only use it if you absolutely need to perform a task before taking the user forward. Bad use case examples: pull to refresh, infinite scrolling, sending message.**

Using `SVProgressHUD` in your app will usually look as simple as this (using Grand Central Dispatch):

```objective-c
[SVProgressHUD show];
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // time-consuming task
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
});
```

### Showing the HUD

You can show the status of indeterminate tasks using one of the following:

```objective-c
+ (void)show;
+ (void)showWithStatus:(NSString*)string;
```

If you'd like the HUD to reflect the progress of a task, use one of these:

```objective-c
+ (void)showProgress:(CGFloat)progress;
+ (void)showProgress:(CGFloat)progress status:(NSString*)status;
```

### Dismissing the HUD

The HUD can be dismissed using:

```objective-c
+ (void)dismiss;
+ (void)dismissWithDelay:(NSTimeInterval)delay;
```

If you'd like to stack HUDs, you can balance out every show call using:

```objective-c
+ (void)popActivity;
```

The HUD will get dismissed once the `popActivity` calls will match the number of show calls.  

Or show a confirmation glyph before before getting dismissed a little bit later. The display time depends on the length of the given string (between 0.5 and 5 seconds).

```objective-c
+ (void)showInfoWithStatus:(NSString *)string;
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showImage:(UIImage*)image status:(NSString*)string;
```

## Customization

`SVProgressHUD` can be customized via the following methods:

```objective-c
+ (void)setDefaultStyle:(SVProgressHUDStyle)style;                  // default is SVProgressHUDStyleLight
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType;         // default is SVProgressHUDMaskTypeNone
+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type;   // default is SVProgressHUDAnimationTypeFlat
+ (void)setMinimumSize:(CGSize)minimumSize;                         // default is CGSizeZero, can be used to avoid resizing for a larger message
+ (void)setRingThickness:(CGFloat)width;                            // default is 2 pt
+ (void)setRingRadius:(CGFloat)radius;                              // default is 18 pt
+ (void)setRingNoTextRadius:(CGFloat)radius;                        // default is 24 pt
+ (void)setCornerRadius:(CGFloat)cornerRadius;                      // default is 14 pt
+ (void)setFont:(UIFont*)font;                                      // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setForegroundColor:(UIColor*)color;                         // default is [UIColor blackColor], only used for SVProgressHUDStyleCustom
+ (void)setBackgroundColor:(UIColor*)color;                         // default is [UIColor whiteColor], only used for SVProgressHUDStyleCustom
+ (void)setInfoImage:(UIImage*)image;                               // default is the bundled info image provided by Freepik
+ (void)setSuccessImage:(UIImage*)image;                            // default is bundled success image from Freepik
+ (void)setErrorImage:(UIImage*)image;                              // default is bundled error image from Freepik
+ (void)setViewForExtension:(UIView*)view;                          // default is nil, only used if #define SV_APP_EXTENSIONS is set
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;     // default is 5.0 seconds
```

Additionally `SVProgressHUD` supports the `UIAppearance` protocol for most of the above methods.

### Hint

As standard `SVProgressHUD` offers two preconfigured styles:

* `SVProgressHUDStyleLight`: White background with black spinner and text
* `SVProgressHUDStyleDark`: Black background with white spinner and text

If you want to use custom colors with `setForegroundColor` and `setBackgroundColor:`  don't forget to set `SVProgressHUDStyleCustom` via `setDefaultStyle:`.

## Notifications

`SVProgressHUD` posts four notifications via `NSNotificationCenter` in response to being shown/dismissed:
* `SVProgressHUDWillAppearNotification` when the show animation starts
* `SVProgressHUDDidAppearNotification` when the show animation completes
* `SVProgressHUDWillDisappearNotification` when the dismiss animation starts
* `SVProgressHUDDidDisappearNotification` when the dismiss animation completes

Each notification passes a `userInfo` dictionary holding the HUD's status string (if any), retrievable via `SVProgressHUDStatusUserInfoKey`.

`SVProgressHUD` also posts `SVProgressHUDDidReceiveTouchEventNotification` when users touch on the overall screen or `SVProgressHUDDidTouchDownInsideNotification` when a user touches on the HUD directly. For this notifications `userInfo` is not passed but the object parameter contains the `UIEvent` that related to the touch.

## App Extensions

When using `SVProgressHUD` in an App Extension, `#define SV_APP_EXTENSIONS` to avoid using unavailable APIs. Additionally call `setViewForExtension:` from your extensions view controller with `self.view`.

## Contributing to this project

If you have feature requests or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/SVProgressHUD/SVProgressHUD/issues/new). Please take a moment to
review the guidelines written by [Nicolas Gallagher](https://github.com/necolas/):

* [Bug reports](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#bugs)
* [Feature requests](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#features)
* [Pull requests](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#pull-requests)

## Credits

`SVProgressHUD` is brought to you by [Sam Vermette](http://samvermette.com), [Tobias Tiemerding](http://tiemerding.com) and [contributors to the project](https://github.com/SVProgressHUD/SVProgressHUD/contributors). If you're using `SVProgressHUD` in your project, attribution would be very appreciated. The success, error and info icons are made by [Freepik](http://www.freepik.com) from [Flaticon](http://www.flaticon.com) and are licensed under [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/). 
