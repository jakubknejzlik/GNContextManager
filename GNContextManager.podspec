#
#  Be sure to run `pod spec lint GNContextManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "GNContextManager"
  s.version      = "0.0.1"
  s.summary      = "CoreData helper"
  s.description  = <<-DESC
                   Manager for helping with CoreData stuff
                   DESC
  s.homepage     = "https://github.com/jakubknejzlik/GNContextManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jakub Knejzlik" => "jakub.knejzlik@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/jakubknejzlik/GNContextManager.git", :tag => "0.0.1" }
  s.source_files  = "GNContextManager/*.{h,m}"
  s.frameworks = "UIKit"
  s.requires_arc = true
  s.dependency "CWLSynthesizeSingleton"
end
