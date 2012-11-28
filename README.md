_**If your project doesn't use ARC**: you must add the `-fobjc-arc` compiler flag to `SVProgressHUD.m` in Target Settings > Build Phases > Compile Sources._

# SVProgressHUD

SVProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task.


![SVProgressHUD](http://f.cl.ly/items/3r2x0b1E1O2F0V422a3R/screenshots2.png)

## Installation

* Drag the `SVProgressHUD/SVProgressHUD` folder into your project.
* Add the **QuartzCore** framework to your project.

_If you plan on using SVProgressHUD in a lot of places inside your app, I recommend importing it directly inside your prefix file._

## Usage

(see sample Xcode project in `/Demo`)

SVProgressHUD is created as a singleton (i.e. it doesn't need to be explicitly allocated and instantiated; you directly call `[SVProgressHUD method]`).

### Showing the HUD

You can show the status of inderterminate tasks using:

```objective-c
+ (void)show;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType;
+ (void)showWithStatus:(NSString*)string;
+ (void)showWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)maskType;
```

If you'd like the HUD to reflect the progress of a task, use:

```objective-c
+ (void)showProgress:(CGFloat)progress;
+ (void)showProgress:(CGFloat)progress status:(NSString*)status;
+ (void)showProgress:(CGFloat)progress status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;
```

##### SVProgressHUDMaskType

You can optionally disable user interactions while the HUD is shown using the `maskType` property:

```objective-c
enum {
    SVProgressHUDMaskTypeNone = 1, // allow user interactions, don't dim background UI (default)
    SVProgressHUDMaskTypeClear, // disable user interactions, don't dim background UI
    SVProgressHUDMaskTypeBlack, // disable user interactions, dim background UI with 50% translucent black
    SVProgressHUDMaskTypeGradient // disable user interactions, dim background UI with translucent radial gradient (a-la-alertView)
};
```

### Dismissing the HUD

It can be dismissed right away using:

```objective-c
+ (void)dismiss;
```

Or show a confirmation glyph before before getting dismissed 1 second later using:

```objective-c
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showImage:(UIImage*)image status:(NSString*)string; // use 28x28 white pngs
```

## Credits

SVProgressHUD is brought to you by [Sam Vermette](http://samvermette.com) and [contributors to the project](https://github.com/samvermette/SVProgressHUD/contributors). The success and error icons are from [Glyphish](http://glyphish.com/). If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/samvermette/SVProgressHUD/issues/new). If you're using SVProgressHUD in your project, attribution would be nice.