//
//  String+Encode.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-6-11.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import Foundation

extension String {
    /// 根据 RFC 3986 标准不需要编码的字符集合: http://www.ietf.org/rfc/rfc3986.txt
    static let RFC3986Strings = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    
    /// 对 URL 类型的字符串进行编码，以便符合 URL 标准。默认采用 urlQueryAllowed 集合。
    public func urlEncode(_ charSet: CharacterSet = .urlQueryAllowed) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: charSet)!
    }
    
    /// 生成 base64 编码后的字符串
    public func base64Encode() -> String? {
        // 将字符串进行 UTF-8 编码成 NSData
        let utf8EncodeData = self.data(using: .utf8, allowLossyConversion: true)
        
        // 将NSData进行base64编码
        let base64EncodedString = utf8EncodeData?.base64EncodedString()
        return base64EncodedString
    }
    
    /// 对 base64 编码的字符串进行解码
    public func base64Decode() -> String? {
        // 将 base64 字符串转换成 NSData
        guard let base64EncodedData = Data(base64Encoded: self) else {
            return nil
        }
        // 对 NSData 数据进行 UTF-8 解码
        guard let decodedString =
            String(data: base64EncodedData, encoding: .utf8) else {
                return nil
        }
        return decodedString
    }
    
}

extension CharacterSet {
    /// 根据 RFC 3986 标准定义的编码保留字符集
    static public let RFC3986Set = CharacterSet(charactersIn: String.RFC3986Strings)
}
