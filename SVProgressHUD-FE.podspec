Pod::Spec.new do |s|
  s.name     = 'SVProgressHUD-FE'
  s.version  = '2.0'
  s.ios.deployment_target = '6.1'
  s.tvos.deployment_target = '9.0'
  s.license  = 'MIT'
  s.summary  = 'fork的SVProgressHUD，自己加了一些方法'
  s.homepage = 'https://github.com/wzf/SVProgressHUD-FE'
  s.authors   = { 'Jeff' => 'feng4job@gamil.com'}
  s.source   = { :git => 'https://github.com/wzf/SVProgressHUD-FE.git', :tag => s.version.to_s }

  s.description = '著名的SVProgressHUD，应用起来也难免有不合适的敌方，自己fork了一份，添加了一些平时的修改，尽量保证SVProgressHUD是最新版本。'

  s.source_files = 'SVProgressHUD/*.{h,m}'
  s.framework    = 'QuartzCore'
  s.resources    = 'SVProgressHUD/SVProgressHUD.bundle'
  s.requires_arc = true
end
