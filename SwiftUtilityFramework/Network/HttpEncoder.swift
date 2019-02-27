//
//  HttpEncoder.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/2/20.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

/// 需要转义的文本类型
public enum StringEscapeType {
    /// 用于 URL 的查询参数
    case queryString
    /// 用于 http body 的编码数据
    case formURLEncoded
}

/// 本类用于简化 http 请求信息常见的转义与编码方法
public class HTTPRequestEncoder {
    /// 需要编码的参数字典，value 需要支持 JSONValueCompatible 协议（即可用文本表示）
    var params: [String: JSONValueCompatible]
    
    public init(params: [String: JSONValueCompatible]) {
        self.params = params
    }
    
    /// 根据指定的 body 类型和转义类型，对参数字典进行转义并编码。
    public func encode(bodyType: HTTPBodyType = .formURLEncoded,
                       escapeType: StringEscapeType = .formURLEncoded) -> Data? {
        var encodedData: Data?
        switch bodyType {
        case .json:
            encodedData = try? JSONSerialization.data(withJSONObject: params)
        case .formURLEncoded:
            encodedData = HTTPRequestEncoder.joinAndEscapeParams(params, escapeType: escapeType)
                .data(using: String.Encoding.utf8)
        }
        return encodedData
    }
    
    /// 指定转义类型，对参数字典进行转义，最终合并输出一个完整字符串（未经 Data 序列化）。
    static public func joinAndEscapeParams(_ params: [String: JSONValueCompatible],
                                           escapeType: StringEscapeType = .queryString) -> String {
        let escapedParams = HTTPRequestEncoder.escapeParams(params, type: escapeType)
        let joined = escapedParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        return joined
    }
    
    /// 指定转义类型，对参数字典进行转义，输出转义后的字典（未经 Data 序列化）。
    static public func escapeParams(_ params: [String: JSONValueCompatible],
                                    type: StringEscapeType = .queryString)
        -> [String: JSONValueCompatible] {
        switch type {
        case .queryString:
            return params.map { (HTTPRequestEncoder.queryStringEscape($0),
                                 HTTPRequestEncoder.queryStringEscape($1.stringValue)) }
        case .formURLEncoded:
            return params.map { (HTTPRequestEncoder.formStringEscape($0),
                                 HTTPRequestEncoder.formStringEscape($1.stringValue)) }
        }
    }
    
    /// https://useyourloaf.com/blog/how-to-percent-encode-a-url-string/
    /// 对用于 URL 查询参数类型的文本进行转义
    static public func queryStringEscape(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._~/?")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
    }
    
    /// 对用于 http body 编码数据类型的文本进行转义
    static public func formStringEscape(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+") // 替换普通空格(U+0020) 为加号
    }
}

