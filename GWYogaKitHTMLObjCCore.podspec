Pod::Spec.new do |s|
  s.name             = 'GWYogaKitHTMLObjCCore'
  s.version          = '1.0.0'
  s.summary          = 'Objective-C bridge for GWYogaKitHTML'
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }
  s.source_files = 'GWYogaKit/HTML/ObjC/**/*.swift'
  s.dependency 'GWYogaKitHTML', '~> 1.0'
end
