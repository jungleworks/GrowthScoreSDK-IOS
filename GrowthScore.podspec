#
# Be sure to run `pod lib lint GrowthScore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |s|
  s.name             = 'GrowthScore'
   s.version          = '1.0.0'
   s.summary          = 'GrowthScore iOS SDK'
   s.homepage         = 'https://github.com/jungleworks/GrowthScoreSDK-IOS'
   s.license          = { :type => 'MIT', :file => 'LICENSE' }
   s.author           = { 'JungleWorks' => 'neha.vaish@jungleworks.com' }

   s.source           = {
     :git => 'https://github.com/jungleworks/GrowthScoreSDK-IOS.git',
     :tag => s.version.to_s
   }

   s.ios.deployment_target = '15.0'
   s.swift_version         = '5.9'

  s.source_files = 'Sources/**/*.swift'
  s.resource_bundles = {
    'GrowthScore' => [
      'GrowthScore/Resources/**/*'
    ]
  }

end
