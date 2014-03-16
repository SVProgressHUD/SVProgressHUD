# SVProgressHUD

SVProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task.

![SVProgressHUD](http://f.cl.ly/items/2G1F1Z0M0k0h2U3V1p39/SVProgressHUD.gif)

## Installation

### From CocoaPods

I'm not a big fan of CocoaPods, so tend to not keep it updated. If you really want to use SVProgressHUD with CocoaPods, I suggest you use `pod 'SVProgressHUD', :head` to pull from the `master` branch directly. I'm usually careful about what I push there and is the version I use myself in all my projects.

### Manually

* Drag the `SVProgressHUD/SVProgressHUD` folder into your project.
* Add the **QuartzCore** framework to your project.

## Usage

(see sample Xcode project in `/Demo`)

SVProgressHUD is created as a singleton (i.e. it doesn't need to be explicitly allocated and instantiated; you directly call `[SVProgressHUD method]`).

**Use SVProgressHUD wisely! Only use it if you absolutely need to perform a task before taking the user forward. Bad use case examples: pull to refresh, infinite scrolling, sending message.**

Using SVProgressHUD in your app will usually look as simple as this (using Grand Central Dispatch):

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
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType;
+ (void)showWithStatus:(NSString*)string;
+ (void)showWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)maskType;
```

If you'd like the HUD to reflect the progress of a task, use one of these:

```objective-c
+ (void)showProgress:(CGFloat)progress;
+ (void)showProgress:(CGFloat)progress status:(NSString*)status;
+ (void)showProgress:(CGFloat)progress status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;
```

### Dismissing the HUD

It can be dismissed right away using:

```objective-c
+ (void)dismiss;
```

If you'd like to stack HUDs, you can balance out every show call using:

```objective-c
+ (void)popActivity;
```

The HUD will get dismissed once the `popActivity` calls will match the number of show calls.  

Or show a confirmation glyph before before getting dismissed 1 second later using:

```objective-c
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showImage:(UIImage*)image status:(NSString*)string; // use 28x28 pngs
```

## Customization

SVProgressHUD can be customized via the following methods:

```objective-c
+ (void)setBackgroundColor:(UIColor*)color; // default is [UIColor whiteColor]
+ (void)setForegroundColor:(UIColor*)color; // default is [UIColor blackColor]
+ (void)setRingThickness:(CGFloat)width; // default is 4 pt
+ (void)setFont:(UIFont*)font; // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setSuccessImage:(UIImage*)image; // default is bundled success image from Glyphish
+ (void)setErrorImage:(UIImage*)image; // default is bundled error image from Glyphish
```

## Notifications

`SVProgressHUD` posts four notifications via `NSNotificationCenter` in response to being shown/dismissed:
* `SVProgressHUDWillAppearNotification` when the show animation starts
* `SVProgressHUDDidAppearNotification` when the show animation completes
* `SVProgressHUDWillDisappearNotification` when the dismiss animation starts
* `SVProgressHUDDidDisappearNotification` when the dismiss animation completes

Each notification passes a `userInfo` dictionary holding the HUD's status string (if any), retrievable via `SVProgressHUDStatusUserInfoKey`.

`SVProgressHUD` also posts `SVProgressHUDDidReceiveTouchEventNotification` when users touch on the screen. For this notification `userInfo` is not passed but the object parameter contains the `UIEvent` that related to the touch.

## Credits

SVProgressHUD is brought to you by [Sam Vermette](http://samvermette.com) and [contributors to the project](https://github.com/samvermette/SVProgressHUD/contributors). The success and error icons are from [Glyphish](http://glyphish.com/). If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/samvermette/SVProgressHUD/issues/new). If you're using SVProgressHUD in your project, attribution would be nice.
