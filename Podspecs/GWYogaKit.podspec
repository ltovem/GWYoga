Pod::Spec.new do |s|
  s.name             = 'GWYogaKit'
  s.version          = '1.0.1'
  s.summary          = 'UIKit integration for GWYoga layout engine'
  s.description      = <<-DESC
    GWYogaKit provides UIKit integration for the GWYoga layout engine,
    including YogaLayoutView, YogaProperties, and UIView extensions.
  DESC
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }

  s.source_files = 'Sources/GWYogaKit/Core/Swift/**/*.swift'
  s.dependency 'GWYoga', '~> 1.0'
end
