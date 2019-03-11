//
//  Result.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-9-19.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import UIKit

public enum Result<Value> {
    case success(Value)
    case error(Error)
}

extension Result {
    public func resolve() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .error(let error):
            throw error
        }
    }
}

extension Result where Value == Data {
    public func decode<T: Decodable>(by decoder: GeneralDecoder) throws -> T {
        let data = try resolve()
        return try decoder.decode(T.self, from: data)
    }
    
    public func decoded<T: DataInitializable>() throws -> T {
        let data = try resolve()
        if let value = T(data: data) {
            return value
        } else {
            throw DataInitializeError.invalidData
        }
    }
}

/// 支持各类解码器的基础协议
public protocol GeneralDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: GeneralDecoder {}
extension PropertyListDecoder: GeneralDecoder {}

/// 支持直接从 Data 类型进行初始化的类型协议
public protocol DataInitializable {
    init?(data: Data)
}

public enum DataInitializeError: Error {
    case invalidData
}

extension UIImage: DataInitializable {
}
