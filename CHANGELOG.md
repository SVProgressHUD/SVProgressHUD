## Version 2.2.5
* Use GitHub official license style

## Version 2.2.4
* Can't see checkmark when using SVProgressHUDStyleDark #873
* Updated README’s instructions for Carthage deployment #876
* Added a stale configuration

## Version 2.2.3
* Off-screen keyboard returns a positive value in iOS 11.2 as its height #835, #846, #852
* Fix bug where status label hiddenness is not updated when setStatus is called #854
* Use @available to suppress warnings in Xcode 9 #821 #864 #870

## Version 2.2.2
* Rollback of popActivity #824

## Version 2.2
* Update project to AutoLayout (finally)
* Added grace time #556
* New Fade in / Fade out animation #703, #757, #776, #779, #791, #793, #798, #800
* Remove vibrancy for better readability on iOS 11 (and below)

## Version 2.1.3
* Fixed: Background resize #709
* Update year to 2017

## Version 2.1.2
* Fixed: Status message goes offscreen #699
* Fixed: HUD customization behaving unexpectedly #700

## Version 2.1.1
* Fixed: dismissWithDelay #647, #649, #594, #591, #662

## Version 2.1
* New: Implicitly set default style to custom when setting colors #692
* New: Add HUD to UIView instead of UIWindow #685
* Fixed: UIVisualEffectViews transition error #680
* Fixed: Minimum size #697, #674, #359

## Version 2.0.4
* New: Allow to set max allowed window level #607
* New: Add completion block to dismiss methods
* Fixed: Live blurring due to wrong background color #517 / #624
* Fixed: Remove any old instances of UIVisualEffectViews, when the HUDStyle… #667
* Fixed: Ring not centered in HUD #635
* Fixed: SVProgressHUD failing to build on tvos #672 / #673
* Update to Xcode 8 recommended settings

## Version 2.0.3
* Fixed: Carthage support #592, #590

## Version 2.0.2
* Fixed: Fixes tvOS demos, Changed return type #586, #587

## Version 2.0.1
* Fixed: Build issues for tvOS, as UIKeyboard notifications are gone #576
* Fixed: HUD does not hide if ismiss is called directly after show #555
* Fixed: Reset ring layer stroke end upon dismiss #580
* Fixed: Ringlayer not resized when values properties change during runtime #584

## Version 2.0
* Fixed: `:head` not available anymore in Cocoapods #552
* Fixed: Redraw resource images as the look blurry on 2x/3x. #562
* Fixed: Problem where displayDurationForString can return duration shoter than minimumDismissTimeInterval #574
* Fixed: iOS7+ alert black dimming view has an alpha of 0.4, not 0.5 #570
* Fixed: Bugfix for hidden HUD if defaultMaskStyle is changed during runtime

## Version 2.0-beta8
* Fixed: Progress HUD intersects with default spinner #551
* Fixed: Update Carthage installation guides #550
* Fixed: Outdated licenses

## Version 2.0-beta6
* Fixed: Added success image back, was removed to test a bugfix

## Version 2.0-beta5
* Fixed: HUD not showing on root view controller in `viewDidLoad` and `viewWillAppear` #536
* Fixed: When showing with `nil` image, layout wrong size #548

## Version 2.0-beta4
* Fixed: Notification typo #545
* Fixed: Remove duplicate declarations

## Version 2.0-beta3
* Fixed: Cocoapods bundle problem #542

## Version 2.0-beta2
* Fixed: Dismiss duration 0.15 maybe lead to a bug #529
* Fixed: Don't apply blur for custom style #508
* Fixed: No supported interface orientation in real time #490

## Version 2.0-beta
* New: Support for tvOS 
* New: UIAppearance support
* New: Moved Repo to an own organisation
* Fixed: Many things ... 
