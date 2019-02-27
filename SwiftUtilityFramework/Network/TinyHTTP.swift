//
//  TinyHTTP.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/2/20.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

public enum HTTPBodyType {
    /// [String: String] encoded as x-www-form-urlencoded
    case formURLEncoded
    /// json string
    case json
}

/// 极简 http 请求方法（支持 get, post）
open class TinyHTTP {
    var session: URLSession
    /// 如果 session 是 background 模式，需要一个标识符。
    var backgroundSessionIdentifier: String?
    var request: URLRequest?
    var reponse: URLResponse?
    
    public init(sessionType: SessionType = .Default,
                backgroundSessionIdentifier: String? = nil,
                usingCache: Bool = false)
    {
        // 定义 session 配置对象
        var sessionConfig: URLSessionConfiguration
        
        switch sessionType {
        case .Default:
            sessionConfig = URLSessionConfiguration.default
        case .Ephemeral:
            sessionConfig = URLSessionConfiguration.ephemeral
        case .Background:
            if backgroundSessionIdentifier != nil && !(backgroundSessionIdentifier!.isEmpty) {
                self.backgroundSessionIdentifier = backgroundSessionIdentifier!
                sessionConfig = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier!)
            } else {
                sessionConfig = URLSessionConfiguration.default
            }
        }
        
        if usingCache {
            // Configuring caching behavior for the default session
            // 配置缓存目录等
            let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let cacheURL = cachesDirectoryURL.appendingPathComponent("MyCache")
            let diskPath = cacheURL.path
            
            let cache = URLCache(memoryCapacity:16384, diskCapacity: 268435456, diskPath: diskPath)
            sessionConfig.urlCache = cache
            sessionConfig.requestCachePolicy = .useProtocolCachePolicy
        }
        
        // Creating sessions
        session = URLSession(configuration: sessionConfig)
    }
    
    /// 兼容 get 与 post 的原始请求方法，一般不直接调用。
    public func originGetOrPost(url: String,
                                header: [String: String]? = nil,
                                body: Data? = nil,
                                method: HTTPMethod = .get,
                                completion: ((Data?, URLResponse?, Error?) -> Void)? = nil)
    {
        guard (method == .get || method == .post) else { return }
        
        // 创建URL对象
        guard let url = URL(string: url) else { return }
        // 创建请求对象
        request = URLRequest(url: url)
        request?.httpMethod = method.rawValue
        if header != nil {
            for (key, value) in header! {
                request?.setValue(value, forHTTPHeaderField: key)
            }
        }
        request?.httpBody = body
        
        // 创建任务
        var dataTask: URLSessionTask
        if completion != nil {
            dataTask = session.dataTask(with: request!, completionHandler: completion!)
        } else {
            dataTask = session.dataTask(with: request!)
        }
        
        // 启动任务
        dataTask.resume()
    }
    
    /// 支持 url 请求参数转义与编码，body 请求参数转义与编码的 get 与 post 兼容方法。
    public func getOrPost(baseURL: String,
                          urlParams: [String: String]? = nil,
                          header: [String: String]? = nil,
                          bodyParams: [String: JSONValueCompatible]? = nil,
                          bodyType: HTTPBodyType = .formURLEncoded,
                          method: HTTPMethod = .get,
                          completion: ((Data?, URLResponse?, Error?) -> Void)? = nil)
    {
        guard (method == .get || method == .post) else { return }
        
        var fullURL = ""
        var bodyData: Data? = nil
        
        if urlParams != nil && urlParams!.isEmpty == false {
            fullURL = baseURL + "?" + HTTPRequestEncoder.joinAndEscapeParams(urlParams!)
        } else {
            fullURL = baseURL
        }
        if bodyParams != nil {
            bodyData = HTTPRequestEncoder(params: bodyParams!).encode(bodyType: bodyType)
        }
        originGetOrPost(url: fullURL,
                        header: header,
                        body: bodyData,
                        method: method,
                        completion: completion)
    }
    
    
}
