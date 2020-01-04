#
# Be sure to run `pod lib lint APTips.podspec` to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'APTips'
  s.version          = '1.0.1'
  s.summary          = 'A simple tip to easily notify a user about something in a app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple tip that shows message to a user. It able to point to the element center and adjust its side depending on an available space but it uses only top and bottom sides. It able to handle complex UI with reusable cells and views in most cases. It also has an ability to show some tips only once so you won't need to write an additional logic for that.
                       DESC

  s.homepage         = 'https://github.com/APUtils/APTips'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Plebanovich' => 'anton.plebanovich@gmail.com' }
  s.source           = { :git => 'https://github.com/APUtils/APTips.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_versions = ['5.1']

  s.source_files = 'APTips/Classes/**/*'
  
  # s.resource_bundles = {
  #   'APTips' => ['APTips/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
