Pod::Spec.new do |s|
  s.name         = "GNContextManager"
  s.version      = "0.0.3"
  s.summary      = "CoreData helper"
  s.description  = <<-DESC
                   Manager for helping with CoreData stuff
                   DESC
  s.homepage     = "https://github.com/jakubknejzlik/GNContextManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jakub Knejzlik" => "jakub.knejzlik@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/jakubknejzlik/GNContextManager.git", :tag => "0.0.3" }
  s.source_files  = "GNContextManager/*.{h,m}"
  s.frameworks = "UIKit"
  s.requires_arc = true
  s.dependency "CWLSynthesizeSingleton"
end
