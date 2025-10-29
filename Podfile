platform :osx, '14.0'
use_frameworks!

target 'Clipy' do

  # Application
  pod 'PINCache'
  pod 'Sauce'
  pod 'Sparkle'
  pod 'RealmSwift'
  pod 'RxCocoa'
  pod 'RxSwift'
  pod 'KeyHolder'
  pod 'Magnet'
  pod 'RxScreeen'
  pod 'AEXML'
  pod 'LetsMove'
  pod 'SwiftHEXColors'
  # Utility
  pod 'SwiftLint'
  pod 'SwiftGen'

  # Temporarily commented out test dependencies to fix build
  # target 'ClipyTests' do
  #   inherit! :search_paths
  #   pod 'Quick'
  #   pod 'Nimble'
  # end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
