platform :ios, '9.3'
use_frameworks!

target 'DrawCollab' do
pod 'IQKeyboardManagerSwift', :git => 'https://github.com/hackiftekhar/IQKeyboardManager.git', :branch => 'swift3'
pod 'PartyTime'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-DrawCollab/Pods-DrawCollab-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    
    
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
