//
//  JSONValueCompatible.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/2/20.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

/// 用于 HTTPRequestEncoder 中，对 http 请求信息中 json 类型的键值转为字符串形式以进行转义和编码。
public protocol JSONValueCompatible {
    var stringValue: String { get }
}

extension String: JSONValueCompatible {
    public var stringValue: String {
        return self
    }
}

extension Bool: JSONValueCompatible {
    public var stringValue: String {
        return self ? "true" : "false"
    }
}

extension Int: JSONValueCompatible {
    public var stringValue: String {
        return String(self)
    }
}

extension Double: JSONValueCompatible {
    public var stringValue: String {
        return String(self)
    }
}
