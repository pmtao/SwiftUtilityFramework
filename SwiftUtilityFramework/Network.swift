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

public struct HttpSession {
    let sessionType: SessionType
    let taskType: TaskType
    var backgroundSessionIdentifier: String?
    
    public init(sessionType: SessionType, taskType: TaskType) {
        self.sessionType = sessionType
        self.taskType = taskType
    }
    
    public func sessionConfig() -> URLSession {
        var sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default
        
        switch sessionType {
        case .Default:
            sessionConfig = URLSessionConfiguration.default
        case .Ephemeral:
            sessionConfig = URLSessionConfiguration.ephemeral
        case .Background:
            if backgroundSessionIdentifier != nil && !(backgroundSessionIdentifier!.isEmpty) {
                sessionConfig = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier!)
            }
        }
        
        // Configuring caching behavior for the default session
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
    
    public func post(url: String,
                     postString: String? = nil,
                     session: URLSession = URLSession.shared,
                     completion: ((Data?, URLResponse?, Error?) -> Void)? = nil)
    {
        let httpMethod: HTTPMethod = .post
        //创建URL对象
        let urlStruct = URL(string: url)
        //创建请求对象
        var request = URLRequest(url: urlStruct!)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = postString?.data(using: .utf8)
        
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
    
    public func get(url: String,
                    getString: String? = nil,
                    session: URLSession = URLSession.shared,
                    completion: ((Data?, URLResponse?, Error?) -> Void)? = nil)
    {
        let httpMethod: HTTPMethod = .get
        //创建URL对象
        let urlStruct = URL(string: url)
        //创建请求对象
        var request = URLRequest(url: urlStruct!)
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

    
    
