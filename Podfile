platform :ios, '9.3'
use_frameworks!

target 'DrawCollab' do
pod 'IQKeyboardManagerSwift'
pod 'PartyTime'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-DrawCollab/Pods-DrawCollab-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end