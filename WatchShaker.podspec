Pod::Spec.new do |s|
  s.name             = "WatchShaker"
  s.version          = "0.0.1"
  s.summary          = "watchOS shake moviment"

  s.description      = <<-DESC
                       WatchShaker is a watchOS helper to get your ⌚️ shake moviment.
                       DESC

  s.homepage         = "https://github.com/ezefranca/WatchShaker"
  s.license          = 'MIT'
  s.author           = { "Ezequiel França" => "" }
  s.source           = { :git => "https://github.com/ezefranca/WatchShaker.git", :tag => s.version.to_s }

  s.platform     = :watchos, '3.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'Foundation', 'WatchKit', 'CoreMotion'
end