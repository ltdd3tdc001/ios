platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def third_lib
  pod 'Alamofire', '4.4.0'
  pod 'ObjectMapper', '2.2.6'
  pod 'SwiftLint', '0.16.1'
  pod 'SwiftUtils', '2.1.1'
  pod 'MVVM-Swift'
  pod 'XCGLogger'
  pod 'YouTubePlayer-Swift'
  pod 'AlamofireObjectMapper', '~> 4.0'
  pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git', :branch => 'feature/swift-3'
  pod 'RealmSwift', '~> 2.8.3'
  pod 'ObjectMapper_RealmSwift'
end

target 'Youtube' do
  # Pods for Youtube
  third_lib
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      target.build_settings('Debug')['ONLY_ACTIVE_ARCH'] = 'YES'
      target.build_settings('Release')['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
