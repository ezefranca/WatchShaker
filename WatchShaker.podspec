Pod::Spec.new do |s|
  s.name             = "WatchShaker"
  s.version          = "0.0.2"
  s.summary          = "watchOS shake moviment"

  s.description      = <<-DESC
                       WatchShaker is a watchOS helper to get your ⌚️ shake moviment.
                       DESC

  s.homepage         = "https://github.com/ezefranca/WatchShaker"
  s.license          = 'MIT'
  s.author       = {'ezefranca' => 'https://github.com/ezefranca'}
  s.source           = { :git => "https://github.com/ezefranca/WatchShaker.git", :tag => s.version.to_s }

  s.platform     = :watchos, '3.0'
  s.requires_arc = false
  s.social_media_url   = "http://twitter.com/ezefranca"
  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'Foundation', 'WatchKit', 'CoreMotion'
end
