# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

target 'StrollPlaces' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for StrollPlaces
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'NSObject+Rx'
  pod 'RealmSwift'
  pod 'SnapKit'
  pod 'NVActivityIndicatorView'
  pod 'Cluster'
  pod 'ViewAnimator'
  pod 'SPIndicator'
  pod 'lottie-ios'
  pod 'IQKeyboardManagerSwift', '6.5.10'
  pod 'TransitionableTab', '~> 0.2.0'
  pod 'SkyFloatingLabelTextField', '~> 3.0'
  pod 'FaveButton'
  pod 'Hero'
  pod 'Cosmos', '~> 23.0'
  pod 'Floaty', '~> 4.2.0'
  #pod 'AcknowList'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'FirebasePerformance'
  #pod 'Google-Mobile-Ads-SDK'
  #pod 'PopOverMenu', '~> 3.0'
  #pod 'DropDown'
  #pod 'SettingsIconGenerator'
  #pod 'IVBezierPathRenderer'
  
  target 'StrollPlacesTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'StrollPlacesUITests' do
    # Pods for testing
  end
  
  target 'TrackingExtension' do
    inherit!  :search_paths
    # Pods for extension
  end
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
end
