Pod::Spec.new do |s|
  s.name             = 'GWYogaKitStylesheet'
  s.version          = '1.0.0'
  s.summary          = 'CSS stylesheet support for GWYogaKit'
  s.description      = <<-DESC
    Parse and apply CSS stylesheets to GWYogaKit layout views.
  DESC
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }

  s.source_files = 'GWYogaKit/Stylesheet/Swift/**/*.swift'
  s.dependency 'GWYogaKit', '~> 1.0'
end
