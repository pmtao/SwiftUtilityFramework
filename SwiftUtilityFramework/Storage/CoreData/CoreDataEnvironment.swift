//
//  CoreDataEnvironment.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-9-20.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import Foundation

/// 用于配置 Core Data 相关的环境信息，通过扩展的方式增加具体的属性。提供了 Name, Key 等命名空间。
/// ## 扩展示例：
/// ```
/// extension CoreDataEnvironment.Name {
///     static let modelName = CoreDataEnvironment.Name("appStore")
/// }
/// ```
public struct CoreDataEnvironment {
    public struct Name: RawRepresentable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public struct Key: RawRepresentable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
