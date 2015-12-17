Pod::Spec.new do |s|
  s.name     = 'SVProgressHUD'
  s.version  = '2.0-beta1'
  s.ios.deployment_target = '6.1'
  s.tvos.deployment_target = '9.0'
  s.license  = 'MIT'
  s.summary  = 'A clean, easy-to-use and lightweight progress HUD for iOS and tvOS.'
  s.homepage = 'http://samvermette.com/199'
  s.authors   = { 'Sam Vermette' => 'hello@samvermette.com', 'Tobias Tiemerding' => 'tobias@tiemerding.com' }
  s.source   = { :git => 'https://github.com/TransitApp/SVProgressHUD.git', :tag => s.version.to_s }

  s.description = 'SVProgressHUD is a clean, easy-to-use and lightweight progress HUD for iOS and tvOS. It can be used to display the progress of an ongoing task. The bundled icons are from Freepik.'

  s.source_files = 'SVProgressHUD/*.{h,m}'
  s.framework    = 'QuartzCore'
  s.resources    = 'SVProgressHUD/SVProgressHUD.bundle'
  s.requires_arc = true
end
