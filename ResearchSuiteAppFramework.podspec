#
# Be sure to run `pod lib lint ResearchSuiteAppFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ResearchSuiteAppFramework'
  s.version          = '0.0.1'
  s.summary          = 'The ResearchSuiteAppFramework is the easiest way to build mobile health research studies.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The ResearchSuiteAppFramework is the easiest way to build mobile health research studies.
                       DESC

  s.homepage         = 'https://github.com/jdkizer9/ResearchSuiteAppFramework'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => "Apache 2", :file => "LICENSE" }
  s.author           = { "James Kizer, Curiosity Health" => "james at curiosityhealth dot com" }
  s.source           = { :git => 'https://github.com/ResearchSuite/ResearchSuiteAppFramework-iOS', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.subspec 'Core' do |core|
    core.source_files = 'Source/Core/**/*'
    core.dependency 'ResearchKit', '~> 1.4'
    core.dependency 'ReSwift', '~> 3.0'
    core.dependency 'ResearchSuiteTaskBuilder', '~> 0.2'
    core.dependency 'ResearchSuiteResultsProcessor', '~> 0.2'
    core.dependency 'Gloss', '~> 1.2'
  end

  s.subspec 'Lab' do |lab|
    lab.source_files = 'Source/Lab/Classes/*'
    lab.resource_bundles = {
      'LabResources' => ['Source/Lab/Storyboards/*.storyboard']
    }
    lab.dependency 'ResearchSuiteAppFramework/Core'
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
