Pod::Spec.new do |s|
  s.name         = "GNContextManager"
  s.version      = "0.3.11"
  s.summary      = "CoreData helper"
  s.description  = <<-DESC
                   Manager for helping with CoreData stuff
                   DESC
  s.homepage     = "https://github.com/jakubknejzlik/GNContextManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jakub Knejzlik" => "jakub.knejzlik@gmail.com" }
  s.platform     = :ios, "6.0"
  s.platform     = :tvos, "9.0"
  s.source       = { :git => "https://github.com/jakubknejzlik/GNContextManager.git", :tag => s.version.to_s }
  s.source_files  = "GNContextManager/*.{h,m}"
  s.frameworks = "UIKit","CoreData"
  s.requires_arc = true
  s.dependency "CWLSynthesizeSingleton"
end
