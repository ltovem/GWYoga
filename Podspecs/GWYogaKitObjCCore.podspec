Pod::Spec.new do |s|
  s.name             = 'GWYogaKitObjCCore'
  s.version          = '1.0.2'
  s.summary          = 'Objective-C bridge for GWYogaKit'
  s.description      = <<-DESC
    Objective-C compatible wrappers for GWYogaKit, exposing
    yoga layout properties to Objective-C code.
  DESC
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }

  s.source_files = 'Sources/GWYogaKit/Core/ObjC/**/*.swift'
  s.dependency 'GWYogaKit', '~> 1.0'
end
