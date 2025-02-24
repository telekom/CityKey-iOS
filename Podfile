# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

  target 'NotificationExtension' do
  use_frameworks!
#	pod 'MORichNotification','5.3.0'
  end


target 'OSCA' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OSCA
  #
	
  pod 'GoogleMaps' #'4.0.0'
  pod 'Adjust', '~> 5.0.0'
  pod "TTGSnackbar",'1.11.1'
  pod 'EasyTipView', '~> 2.1.0'
  pod 'KeychainSwift', '~> 20.0'
  pod 'lottie-ios', '~>4.4.0' 
  pod 'SwiftLint'
  
  target 'OSCATests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'CityKeyWidgetExtension' do
    inherit! :search_paths
    # Pods for testing
    pod 'KeychainSwift', '~> 20.0'
  end
  
  target 'CitiesIntentHandler' do
    inherit! :search_paths
    # Pods for testing
    pod 'KeychainSwift', '~> 20.0'
  end



end

#bitcode enable
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|

      # set valid architecture
      #config.build_settings['VALID_ARCHS'] = 'arm64 armv7 armv7s i386 x86_64'

      # build active architecture only (Debug build all)
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'

      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
      
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
            
      config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
      
      config.build_settings['SUPPORTS_MACCATALYST'] = 'NO'
      
      config.build_settings['SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD'] = 'NO'


     end
  end
end
