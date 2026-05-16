Pod::Spec.new do |s|
  s.name             = 'GWYoga'
  s.version          = '1.0.1'
  s.summary          = 'Swift Yoga layout engine'
  s.description      = <<-DESC
    GWYoga core layout engine — flexbox + grid implementation in pure Swift.
  DESC
  s.homepage         = 'https://github.com/ltovem/GWYoga'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tianGaoWei' => 't@ltove.com' }
  s.ios.deployment_target  = '13.0'
  s.swift_version     = '5.6'
  s.source           = { :git => 'https://github.com/ltovem/GWYoga.git', :tag => s.version.to_s }

  s.source_files = 'Sources/GWYoga/**/*.swift'
  s.exclude_files = 'Sources/GWYoga/API_REFERENCE.md'
end
