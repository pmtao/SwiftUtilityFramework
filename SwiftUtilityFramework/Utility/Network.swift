//
//  Network.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-8-31.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import Foundation


public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}


/// http session 类型
///
/// - Default: 默认
/// - Ephemeral: 临时
/// - Background: 后台
public enum SessionType: String {
    case Default
    case Ephemeral
    case Background
}

public enum TaskType: String {
    case DataTask
    case UploadTask
    case DownloadTask
    case StreamTask
}

/// http session 结构体
public struct HttpSession {
    let sessionType: SessionType
    let taskType: TaskType
    /// 如果 session 是 background 模式，需要一个标识符。
    var backgroundSessionIdentifier: String?
    var request: URLRequest!
    
    /// 初始化 http session 结构体
    ///
    /// - Parameters:
    ///   - sessionType: session 类型
    ///   - taskType: 任务类型
    public init(sessionType: SessionType, taskType: TaskType) {
        self.sessionType = sessionType
        self.taskType = taskType
    }
    
    
    /// 配置 seesion 对象
    ///
    /// - Returns: 配置好的 URLSession 对象
    public func sessionConfig() -> URLSession {
        // 定义 session 配置对象
        var sessionConfig: URLSessionConfiguration
        
        switch sessionType {
        case .Default:
            sessionConfig = URLSessionConfiguration.default
        case .Ephemeral:
            sessionConfig = URLSessionConfiguration.ephemeral
        case .Background:
            if backgroundSessionIdentifier != nil && !(backgroundSessionIdentifier!.isEmpty) {
                sessionConfig = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier!)
            } else {
                sessionConfig = URLSessionConfiguration.default
            }
        }
        
        // Configuring caching behavior for the default session
        // 配置缓存目录等
        let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheURL = cachesDirectoryURL.appendingPathComponent("MyCache")
        let diskPath = cacheURL.path
        
        let cache = URLCache(memoryCapacity:16384, diskCapacity: 268435456, diskPath: diskPath)
        sessionConfig.urlCache = cache
        sessionConfig.requestCachePolicy = .useProtocolCachePolicy
        // Creating sessions
        let session = URLSession(configuration: sessionConfig)
        
        return session
    }
    
    public mutating func post(url: String,
                     postString: String? = nil,
                     headerfields: [String: String] = [:],
                     session: URLSession = URLSession.shared,
                     completion: ((Data?, URLResponse?, Error?) -> Void)? = nil)
    {
        let httpMethod: HTTPMethod = .post
        //创建URL对象
        let urlStruct = URL(string: url)
        //创建请求对象
        request = URLRequest(url: urlStruct!)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = postString?.data(using: .utf8)
        for (key, value) in headerfields{
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 打印 request 日志
//        print("request url: \(request.url!)")
//        print("request httpMethod: \(request.httpMethod!)")
//        print("request httpBodyString: \(postString!)")
//        print("request httpBody: \(request.httpBody!)")
//        print("request allHTTPHeaderFields: \(request.allHTTPHeaderFields!)")
        
        var dataTask: URLSessionTask
        if completion != nil {
            dataTask = session.dataTask(
                with: request,
                completionHandler: completion!) as URLSessionTask
        } else {
            dataTask = session.dataTask(with: request) as URLSessionTask
        }
        
        //使用resume方法启动任务
        dataTask.resume()
    }
    
    public mutating func get(url: String,
                    getString: String? = nil,
                    session: URLSession = URLSession.shared,
                    completion: ((Data?, URLResponse?, Error?) -> Void)? = nil)
    {
        let httpMethod: HTTPMethod = .get
        //创建URL对象
        let urlStruct = URL(string: url)
        //创建请求对象
        request = URLRequest(url: urlStruct!)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = getString?.data(using: .utf8)
        
        var dataTask: URLSessionTask
        if completion != nil {
            dataTask = session.dataTask(
                with: request,
                completionHandler: completion!) as URLSessionTask
        } else {
            dataTask = session.dataTask(with: request) as URLSessionTask
        }
        
        //使用resume方法启动任务
        dataTask.resume()
    }
    
}

    
    
