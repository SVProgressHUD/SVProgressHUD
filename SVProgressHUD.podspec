Pod::Spec.new do |s|
  s.name     = 'SVProgressHUD'
  s.version  = '2.2.6'
  s.ios.deployment_target = '8.3'
  s.tvos.deployment_target = '9.0'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A clean and lightweight progress HUD for your iOS and tvOS app.'
  s.homepage = 'https://github.com/SVProgressHUD/SVProgressHUD'
  s.authors   = { 'Sam Vermette' => 'hello@samvermette.com', 'Tobias Tiemerding' => 'tobias@tiemerding.com' }
  s.source   = { :git => 'https://github.com/SVProgressHUD/SVProgressHUD.git', :tag => s.version.to_s }

  s.description = 'SVProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS. The success and error icons are from Freepik from Flaticon and are licensed under Creative Commons BY 3.0.'

  s.framework    = 'QuartzCore'
  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'SVProgressHUD/*.{h,m}'
    core.resources = 'SVProgressHUD/SVProgressHUD.bundle'
  end

  s.subspec 'AppExtension' do |ext|
    ext.source_files = 'SVProgressHUD/*.{h,m}'
    ext.resources = 'SVProgressHUD/SVProgressHUD.bundle'
    ext.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'SV_APP_EXTENSIONS=1' }
  end
end
