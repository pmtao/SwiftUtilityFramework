# 框架说明

![swift version](https://img.shields.io/badge/Swift-4.2-E65497.svg) ![platform](https://img.shields.io/badge/Platform-iOS-green.svg) ![CocoaPods](https://img.shields.io/badge/CocoaPods-0.0.1-red.svg)

本框架主要目标是提供各类常用的方法封装、扩展，减少工作中编写各类体力式代码，提升编码效率。

## 功能说明



## CocoaPods [待开通]

本框架支持通过 CocoaPods 引用，在 Podfile 中添加：

```
pod 'SwiftUtilityFramework', '~>0.0.1'
```

同时工程划分为 5 个子模块，可以在 CocoaPods 单独引用：

```
SwiftUtilityFramework/Foundation
SwiftUtilityFramework/UIKit
SwiftUtilityFramework/ImageProcess
SwiftUtilityFramework/Network
SwiftUtilityFramework/Algorithm
```



## 构建说明

### Xcode 工程配置说明

对 Xcode 构建设置有特殊要求的项，记录在以下文件中：

- `Debug.xcconfig`: 用于 debug 环境
- `Release.xcconfig`: 用于 Release 环境
- `Common.xcconfig`: 以上所有环境统一引用的公共配置


