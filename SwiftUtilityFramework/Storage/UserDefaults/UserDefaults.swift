//
//  UserDefaults.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-10-21.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import Foundation

// 用法
// 通过扩展添加需要自定义的 UserDefaults key
// extension LocalKeys {
//     static let SomeKey = LocalKey<Bool>("SomeKey")
// }
//
// 使用时：Defaults[.SomeKey]

/// 本类抽象了一种类型，可用于 UserDefaults 中存储信息对应的 key。
public class LocalKeys: RawRepresentable, Hashable {
    public let rawValue: String
    
    public required init!(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public convenience init(_ key: String) {
        self.init(rawValue: key)
    }
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
}

/// LocalKeys 的范型封装，用于指定 UserDefaults 中存储的值类型。
public final class LocalKey<T>: LocalKeys { }

public let Defaults = UserDefaults.standard
/// 扩展 UserDefaults 的下标用法
public extension UserDefaults {
    
    subscript(key: LocalKey<Int>) -> Int {
        get {
            return Defaults.integer(forKey: key.rawValue)
        }
        set {
            Defaults.set(newValue, forKey: key.rawValue)
        }
    }
    
    subscript(key: LocalKey<Bool>) -> Bool {
        get {
            return Defaults.bool(forKey: key.rawValue)
        }
        set {
            Defaults.set(newValue, forKey: key.rawValue)
        }
    }
    
    subscript(key: LocalKey<String>) -> String? {
        get {
            return Defaults.string(forKey: key.rawValue)
        }
        set {
            Defaults.set(newValue, forKey: key.rawValue)
        }
    }
    
}
