#
# Be sure to run `pod lib lint SQLAid.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SQLAids"
  s.version          = "0.2.1"
  s.summary          = "Small SQLite wrapper."
  s.description      = "Small \"blocks oriented\" sqlite wrapping tool for Objective-C"
  s.homepage         = "https://github.com/eduardomendoncaSnow/SQLAids"
  s.license          = 'MIT'
  s.author           = { "Pietro Caselani" => "pietro.caselani@involves.com.br" }
  s.source           = { :git => "https://github.com/eduardomendoncaSnow/SQLAids.git", :tag => s.version.to_s }
  s.platform         = :ios, '10.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes/**/*'
  
  s.dependency 'SQLite.swift', '0.13.2'
end
