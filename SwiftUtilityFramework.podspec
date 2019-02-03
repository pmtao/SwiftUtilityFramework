Pod::Spec.new do |s|
  s.name         = "SwiftUtilityFramework"
  s.version      = "0.0.1"
  s.summary      = "swift 开发框架，封装常用的数据类型、方法、算法等。"
  s.homepage     = "https://github.com/pmtao/SwiftUtilityFramework"
  s.license      = "MIT"
  s.authors      = { 'Meler Paine' => 'pmtnmd@gmail.com'}
  s.platform     = :ios, "10.0"
  s.swift_version = '4.2'
  s.source       = { :git => 'https://github.com/pmtao/SwiftUtilityFramework.git', :tag => s.version }
  s.source_files = 'SwiftUtilityFramework/**/*.{h,m,swift}'
  s.resources = 'SwiftUtilityFramework/**/*.{png,xib,storyboard}'
  s.requires_arc = true
  s.preserve_paths = 'SwiftUtilityFramework/**/*'
  s.pod_target_xcconfig = {
    #'SWIFT_INCLUDE_PATHS' => '/Users/pmtao/Tech/Repositories/Github/SwiftUtilityFramework/SwiftUtilityFramework/CommonCrypto'
    #'$(SRCROOT)/SwiftUtilityFramework/SwiftUtilityFramework/CommonCrypto'
  }
  
  s.default_subspec = 'SwiftUtilityFramework'
  s.subspec 'SwiftUtilityFramework' do |suf|
    suf.source_files = 'SwiftUtilityFramework/**/*.{h,m,swift}'
  end
  
  # Foundation 子模块
  s.subspec 'Foundation' do |foundation|
    foundation.source_files = 'SwiftUtilityFramework/Foundation/**/*.{h,m,swift}'
  end

  # UIKit 子模块
  s.subspec 'UIKit' do |uiKit|
    uiKit.source_files = 'SwiftUtilityFramework/UIKit/**/*.{h,m,swift}'
    uiKit.resources = 'SwiftUtilityFramework/UIKit/**/*.{png,xib,storyboard}'
  end
  
  # Polyfill 子模块
  s.subspec 'Polyfill' do |polyfill|
    polyfill.source_files = 'SwiftUtilityFramework/Polyfill/**/*.{h,m,swift}'
  end
  
  # Storage 子模块
  s.subspec 'Storage' do |storage|
    storage.source_files = 'SwiftUtilityFramework/Storage/**/*.{h,m,swift}'
    storage.dependency 'SwiftUtilityFramework/Foundation'
  end
  
  # Network 子模块
  s.subspec 'Network' do |network|
    network.source_files = 'SwiftUtilityFramework/Network/**/*.{h,m,swift}'
  end
  
  # ImageProcess 子模块
  s.subspec 'ImageProcess' do |imageProcess|
    imageProcess.source_files = 'SwiftUtilityFramework/ImageProcess/**/*.{h,m,swift}'
  end
  
    # Algorithm 子模块
  s.subspec 'Algorithm' do |algorithm|
    algorithm.source_files = 'SwiftUtilityFramework/Algorithm/**/*.{h,m,swift}'
  end
  
end