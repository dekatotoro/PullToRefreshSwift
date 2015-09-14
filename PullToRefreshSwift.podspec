Pod::Spec.new do |s|
  s.name         = "PullToRefreshSwift"
  s.version      = "2.0.0"
  s.summary      = "iOS Simple PullToRefresh Library."
  s.homepage     = "https://github.com/dekatotoro/PullToRefreshSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Yuji Hato" => "hatoyujidev@gmail.com" }
  s.social_media_url   = "https://twitter.com/dekatotoro"
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/dekatotoro/PullToRefreshSwift.git", :tag => "2.0.0" }
  s.source_files = "Source/**/*.{h,m,swift}"
  s.resources    = 'Source/**/*.{svg,png,xib}'
  s.requires_arc = true
end

