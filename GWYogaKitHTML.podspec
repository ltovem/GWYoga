Pod::Spec.new do |s|
  s.name             = 'GWYogaKitHTML'
  s.version          = '1.0.0'
  s.summary          = 'HTML-style tag DSL for GWYogaKit'
  s.description      = <<-DESC
    HTML-style layout tags (div, section, h1, row, etc.) for GWYogaKit.
  DESC
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }

  s.source_files = 'GWYogaKit/HTML/Swift/**/*.swift'
  s.dependency 'GWYogaKitDSL', '~> 1.0'
  s.dependency 'GWYogaKitStylesheet', '~> 1.0'
end
