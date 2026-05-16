Pod::Spec.new do |s|
  s.name             = 'GWYogaKitDSL'
  s.version          = '1.0.1'
  s.summary          = 'Declarative DSL for GWYogaKit'
  s.description      = <<-DESC
    Declarative layout DSL with VStack, HStack, ZStack, and controls.
  DESC
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }

  s.source_files = 'Sources/GWYogaKit/DSL/Swift/**/*.swift'
  s.dependency 'GWYogaKit', '~> 1.0'
end
