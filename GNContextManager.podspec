Pod::Spec.new do |s|
  s.name         = "GNContextManager"
  s.version      = "0.3.12"
  s.summary      = "CoreData helper"
  s.description  = "Manager for helping with CoreData stuff"
  s.homepage     = "https://github.com/jakubknejzlik/GNContextManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jakub Knejzlik" => "jakub.knejzlik@gmail.com" }
  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/jakubknejzlik/GNContextManager.git", :tag => s.version.to_s }
  s.source_files  = "GNContextManager/*.{h,m}"
  s.frameworks = "UIKit","CoreData"
  s.requires_arc = true
  s.dependency "CWLSynthesizeSingleton"
end
