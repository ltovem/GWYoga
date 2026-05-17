Pod::Spec.new do |s|
  s.name             = 'GWYogaKit'
  s.version          = '1.0.5'
  s.summary          = 'Complete GWYoga UIKit integration (Core + Animation + DSL + Stylesheet + LayoutCache)'
  s.description      = <<-DESC
    GWYogaKit provides complete UIKit integration for the GWYoga layout engine:
    YogaLayoutView, YogaProperties, UIView extensions, Animation, DSL (VStack/HStack),
    CSS stylesheet, HTML tags, LayoutCache, data binding, and ObjC bridge.
    One pod, all features.
  DESC
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }

  s.source_files = 'Sources/GWYogaKit/**/*.swift'
  s.dependency 'GWYoga', '~> 1.0'
end
