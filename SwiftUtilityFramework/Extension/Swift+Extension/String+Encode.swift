//
//  String+Encode.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-6-11.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import Foundation

extension String {
    /// 根据 RFC 3986 标准不需要编码的字符集合: http://www.ietf.org/rfc/rfc3986.txt
    static let RFC3986Strings = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    
    /// 对 URL 类型的字符串进行编码，以便符合 URL 标准。默认采用 urlQueryAllowed 集合。
    public func urlEncode(_ charSet: CharacterSet = .urlQueryAllowed) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: charSet)!
    }
}

extension CharacterSet {
    /// 根据 RFC 3986 标准定义的编码保留字符集
    static public let RFC3986Set = CharacterSet(charactersIn: String.RFC3986Strings)
}
