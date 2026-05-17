Pod::Spec.new do |s|
  s.name             = 'GWYogaKitAnimationObjCCore'
  s.version          = '1.0.2'
  s.summary          = 'Objective-C bridge for GWYogaKitAnimation'
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }
  s.source_files = 'Sources/GWYogaKit/Animation/ObjC/**/*.swift'
  s.dependency 'GWYogaKitAnimation', '~> 1.0'
end
