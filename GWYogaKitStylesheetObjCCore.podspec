Pod::Spec.new do |s|
  s.name             = 'GWYogaKitStylesheetObjCCore'
  s.version          = '1.0.1'
  s.summary          = 'Objective-C bridge for GWYogaKitStylesheet'
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }
  s.source_files = 'GWYogaKit/Stylesheet/ObjC/**/*.swift'
  s.dependency 'GWYogaKitStylesheet', '~> 1.0'
end
