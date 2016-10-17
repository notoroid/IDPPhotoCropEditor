Pod::Spec.new do |s|
  s.name         = "IDPPhotoCropEditor"
  s.version      = "0.0.1"
  s.summary      = "IDPPhotoCropEditor is middleware that provides a Instagram-like photo clip function."

  s.description  = <<-DESC
                   
IDPPhotoCropEditor is middleware that provides a Instagram-like photo clip function. support iOS9 SDK or later. - IDPPhotoCropEditor はInstagram ライクな写真クリップ機能を提供するミドルウェアです。iOS9 以降対応。
                   DESC

  s.homepage     = "https://github.com/notoroid/IDPPhotoCropEditor"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "notoroid" => "noto@irimasu.com" }
  s.social_media_url   = "http://twitter.com/notoroid"

  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/notoroid/IDPPhotoCropEditor.git", :tag => "v0.0.1" }

  s.source_files  = "Lib/**/*.{h,m}"
  s.public_header_files = "Lib/**/*.h"

  s.requires_arc = true
end
