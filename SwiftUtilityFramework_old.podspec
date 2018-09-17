Pod::Spec.new do |s|
  s.name         = "SwiftUtilityFramework"
  s.version      = "0.0.1"
  s.summary      = "swift 开发框架，封装常用的数据类型、方法、算法等。"
  s.homepage     = "https://github.com/pmtao/SwiftUtilityFramework"
  s.license      = "MIT"
  s.authors      = { 'Meler Paine' => 'pmtnmd@gmail.com'}
  s.platform     = :ios, "8.0"
  s.swift_version = '4.1'
  s.source       = { :git => 'https://github.com/pmtao/SwiftUtilityFramework.git', :tag => s.version }
  s.source_files = 'SwiftUtilityFramework/**/*.{h,m,swift}'
  s.resources = 'SwiftUtilityFramework/**/*.{png}'
  s.requires_arc = true
  s.preserve_paths = 'SwiftUtilityFramework/**/*'
  s.pod_target_xcconfig = {
    #'SWIFT_INCLUDE_PATHS' => '/Users/pmtao/Tech/Repositories/Github/SwiftUtilityFramework/SwiftUtilityFramework/CommonCrypto'
    #'$(SRCROOT)/SwiftUtilityFramework/SwiftUtilityFramework/CommonCrypto'
  }
end