Pod::Spec.new do |s|
  s.name             = "AFNetworking-BoltsSupport"
  s.version          = "1.0.0"
  s.summary          = "Bolts support for AFNetworking."
  s.homepage         = "https://github.com/taka0125/AFNetworking-BoltsSupport"
  s.license          = 'MIT'
  s.author           = { "Takahiro Ooishi" => "taka0125@gmail.com" }
  s.source           = { :git => "https://github.com/taka0125/AFNetworking-BoltsSupport.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/taka0125'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.dependency 'AFNetworking', '>= 2.6'
  s.dependency 'Bolts', '>= 1.3'
end
