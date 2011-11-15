Pod::Spec.new do |s|
  s.name     = 'SVProgressHUD'
  s.version  = '0.1'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'A clean and lightweight progress HUD for your iOS app.'
  s.homepage = 'http://samvermette.com/199'
  s.author   = { 'Sam Vermette' => 'samvermette@gmail.com' }
  s.source   = { :git => 'https://github.com/samvermette/SVProgressHUD.git', :tag => '0.1' }

  s.description = 'SVProgressHUD is a clean, lightweight and unobtrusive progress HUD for iOS. ' \
                  'It’s a simplified and prettified alternative to the popular MBProgressHUD. '  \
                  'Its fade in/out animations are highly inspired on Lauren Britcher’s HUD in '  \
                  'Tweetie for iOS. The success and error icons are from Glyphish.'

  s.source_files = 'SVProgressHUD/*.{h,m}'
  s.clean_paths  = 'Demo'
  s.framework    = 'QuartzCore'
  s.resources    = 'SVProgressHUD/SVProgressHUD.bundle'
end
