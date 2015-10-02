#
# Be sure to run `pod lib lint SVGPlayButton.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SVGPlayButton"
  s.version          = "0.1.0"
  s.summary          = "A circular play/pause button with progress track."

  s.description      = "This is a button to most likely use for playing audio or video. It toggles between 'play' and 'pause', has a circle around it, and has the capability to display a 'progress track' as whatever you've wired it up to play, plays. It's a sub-class of UIButton and all visual elements are SVG which means it will scale infinitely up and/or down. The example app demonstrates some of this capability via a slider."

  s.homepage         = "https://github.com/maml/SVGPlayButton"
  s.license          = 'MIT'
  s.author           = { "Matthew Loseke" => "mloseke@gmail.com" }
  s.source           = { :git => "https://github.com/maml/SVGPlayButton.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mattloseke'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SVGPlayButton' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'

end
