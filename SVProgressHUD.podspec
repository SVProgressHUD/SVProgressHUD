Pod::Spec.new do |s|
  s.name     = 'SVProgressHUD'
  s.version  = '2.0-beta'
  s.ios.deployment_target = '6.1'
  s.tvos.deployment_target = '9.0'
  s.license  = 'MIT'
  s.summary  = 'A clean and lightweight progress HUD for your iOS app.'
  s.homepage = 'https://github.com/rlozhkin/SVProgressHUD.git'
  s.authors   = { 'Sam Vermette' => 'hello@samvermette.com', 'Tobias Tiemerding' => 'tobias@tiemerding.com' }
  s.source   = { :git => 'https://github.com/rlozhkin/SVProgressHUD.git', :tag => s.version.to_s }

  s.description = 'SVProgressHUD is an easy-to-use, clean and lightweight progress HUD for iOS. It’s a simplified and prettified alternative to the popular MBProgressHUD. The success and error icons are from Freepik.'

  s.source_files = 'SVProgressHUD/*.{h,m}'
  s.framework    = 'QuartzCore'
  s.resources    = 'SVProgressHUD/SVProgressHUD.bundle'
  s.requires_arc = true
end
