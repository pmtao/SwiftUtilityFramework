//
//  URLScheme.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-4-26.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import Foundation
import SafariServices

/// 让 app 支持其他应用通过 URLScheme 调用自己，也支持自己通过 URLScheme 调用其他应用。
/// 使用步骤：
/// 1. 初始化 URLScheme 结构体，指定本 app 的 scheme、要允许互相调用的 app bundle 字典、要支持的外部调用本 app 的动作字典
/// 2. 判断外部唤起的来源 app 是否有效
/// 3. 解析外部调用的动作和参数
/// 4. 根据动作和参数执行对应的操作
@available(iOS 10.0, *)
public struct URLScheme {
    // MARK: --属性----------------👇
    
    /// 初始定义的可通过 URL Scheme 调用的 App 集合
    var XcallBackAppBundleDefaultNames: [String: String]  = [
        "instager": "com.sinkingsoul.Instager",
        "bear": "net.shinyfrog.bear-iOS",
        "fantastical": "com.flexibits.fantastical2.iphone",
        "things": "com.culturedcode.ThingsiPhone",
        "drafts5": "com.agiletortoise.Drafts5",
        "evernote": "com.evernote.iPhone.Evernote",
        "ulysses": "com.ulyssesapp.ios",
        "notes": "com.apple.mobilenotes"
    ]
    
    /// 用户自定义的可通过 URL Scheme 调用的 App 集合
    var XcallBackAppBundleNames: [String: String]
    
    /// 初始定义的 URL Scheme 支持的动作集合
    var XcallBackDefaultActions: [String: [String]]  = [
        "Bear": ["saveToBear", "openBearNote"]
    ]
    
    /// 用户自定义的 URL Scheme 支持的动作集合
    var XcallBackActions: [String: [String]]
    
    /// 当前 app 被调用时的 Scheme
    var myScheme: String
    /// 当前 app 的基础 url，如：scheme://x-callback-url/
    var myBaseURL: String
    
    // MARK: --枚举集合----------------👇
    
    /// 解析 URL Scheme 时发生的错误
    public enum ResolveURLSchemeError: Error {
        case invalidSourceAppBundle // 不支持的源 app bundle
        case badPrefix // 错误的前缀
        case noAction // 未指定动作
        case noParam // 未指定参数
        case invalidAction // 不支持的动作
    }
    
    // MARK: --初始化方法----------------👇
    
    /// 初始化 URLScheme 结构体
    ///
    /// - Parameters:
    ///   - appBundleNames: 需要支持 XcallBack 操作的 AppBundle 字典，如：["bear": "net.shinyfrog.bear-iOS"]
    ///   - actions: 需要支持 XcallBack 操作的动作字典，如：["Bear": ["saveToBear", "openBearNote"]]
    public init(myScheme: String,
         appBundleNames: [String: String],
         actions: [String: [String]]) {
        self.myScheme = myScheme
        self.myBaseURL = "\(myScheme)://x-callback-url/"
        self.XcallBackAppBundleNames =
            URLScheme.combineAppBundles(XcallBackAppBundleDefaultNames,
                                        userAppBundles: appBundleNames)
        self.XcallBackActions =
            URLScheme.combineActions(XcallBackDefaultActions,
                                     userActions: actions)
    }
    
    // MARK: --主方法----------------👇
    
    /// 检查发起 App 的有效性，并返回有效的 App Scheme、Bundle ID。
    /// 返回结果为元组，第一个值为确认有效的 App Scheme，无效时为 nil）；
    /// 第二个值为源 App Bundle ID，始终有值；
    /// 第三个值为检查发生错误的类型，无错误时为 nil。
    public func checkSourceApp(options: [UIApplicationOpenURLOptionsKey : Any])
        -> (String?, String, Error?)
    {
        // 获取发起 App 的 Bundle ID
        let sourceAppBundleID = options[UIApplicationOpenURLOptionsKey.sourceApplication]! as! String
        // 判断是否为支持的 App
        guard let sourceApp = XcallBackAppBundleNames.first( where: {
            $0.value == sourceAppBundleID
        }) else {
            // 不支持的 App bundle ID
            return (nil, sourceAppBundleID, ResolveURLSchemeError.invalidSourceAppBundle)
        }
        return (sourceApp.key, sourceAppBundleID, nil)
    }
    
    /// 解析并执行 URL 动作
    ///
    /// - Parameters:
    ///   - url: 外部发起调用的 url
    ///   - sourceApp: 源 app 信息，元组类型，格式：("appName": "appBundleID")
    ///   - actionHandler: 处理 url 动作的方法，
    ///   - action: 动作名称
    ///   - params: 动作附带的参数字典
    ///   - sourceAppDic: 源 app 字典信息，同 sourceApp。
    /// - Throws: 解析 url 过程中的错误，类型：URLScheme.ResolveURLSchemeError
    public func handleURL(_ url: URL,
                          from sourceApp: (String, String),
                          actionHandler: (_ action: String,
                                          _ params: [String : String],
                                          _ sourceAppDic: (String, String)) -> Void)
        throws {
        guard let (action, params)
            = try resolveURLScheme(url, from: sourceApp.1) else {
                return
        }
        // 让 app 自行处理相应动作
        actionHandler(action, params, sourceApp)
    }
    
    /// 打开 URL 页面，自动匹配两种方式：Safari 内置网页、通过 URL Scheme 打开其他 App。
    static func openApp(_ url: URL, in vc: UIViewController) {
        if url.scheme == "http" || url.scheme == "https" {
            print("Not app link: \(url)")
        } else {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: --URL 编解码处理----------------👇
    
    /// 将原始 url 字符串转换为经过编码处理的 URL 字符串
    static public func encodeURLString(string:String) -> URL {
        let urlwithPercentEscapes = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlwithPercentEscapes!)
        return url!
    }
    
    
    /// 将经过编码处理的 URL 字符串转换为原始字符串
    static public func decodeURLString(string:String) -> String {
        return string.removingPercentEncoding!
    }
    
    // MARK: --URL 参数解析----------------👇
    
    /// 解析 URL Scheme 参数
    ///
    /// - Parameters:
    ///   - url: 原始调用的 URL 信息
    ///   - appBundleID: 调用方 App Bundle ID
    /// - Returns: 动作和参数的元组，第一个是动作，第二个是参数字典。
    /// - Throws: 解析错误 ResolveURLSchemeError 类型枚举值
    public func resolveURLScheme(_ url: URL, from sourceAppBundleID: String)
        throws -> (String, [String: String])?
    {
        var result = ("", [String: String]()) // 最后解析结果
        
        // 解析步骤：
        // 1. 先判断已编码的 url 是否包含 instager://x-callback-url/ 前缀，如果包含再进行分割。
        // 2. 取分割后的参数字符串，将所有参数分解到数组中。
        // 3. 将参数的值进行解码
        // 4. 将参数和值的数组，交给 App 专用解析的方法近一步解析。
        // 5. 返回 App 接下来要执行的动作和参数值
        
        
        //获取 url 已编码的字符串
        let urlEncodedString = url.absoluteString
        if urlEncodedString.hasPrefix(myBaseURL) == false {
            throw ResolveURLSchemeError.badPrefix // 前缀不符，抛出错误。
        }
        
        // 定义解析后的动作和参数
        var action = "" // URL 中的动作
        var parameterArray = [String]() // URL 中的参数数组
        
        // 分别获取 URL Scheme 的路径与参数
        let pathComponents = url.pathComponents
        let querys = url.query
        
        if pathComponents.isEmpty || pathComponents.count == 1 {
            throw ResolveURLSchemeError.noAction // 无动作
        } else {
            action = pathComponents.last!
        }
        
        if querys == nil || querys!.isEmpty {
            throw ResolveURLSchemeError.noParam // 无参数
        } else {
            // 分割获得参数数组
            parameterArray = querys!.components(separatedBy: "&")
            // 去除分割后的空参数
            parameterArray = parameterArray.filter {
                $0.isEmpty == false
            }
        }
        
        // 将参数列表转为字典
        let parameterDict: [String: String] =
            turnParamArrayIntoDecodedDiction(paramArray: parameterArray)
//        // 根据不同的 App 处理参数
//        switch appBundleID {
//        case .bear:
//            result = try resolveParamOfBear(parameterDict, with: action)
//        case .ulysses:
//            result = try resolveParamOfUlysses(parameterDict, with: action)
//        default:
//            break
//        }
        result = (action, parameterDict)
        return result
            
    }
    
    /// 将参数数组转换为字典，并将参数值进行解码。
    func turnParamArrayIntoDecodedDiction(paramArray: [String]) -> [String: String] {
        var paramDiction = [String: String]()
        for param in paramArray {
            let array = param.components(separatedBy: "=")
            if array[0].isEmpty == false && array[1].isEmpty == false {
                paramDiction[array[0]] = URLScheme.decodeURLString(string: array[1])
            }
        }
        return paramDiction
    }
    
    // MARK: --不同 App 参数处理----------------👇
    
//    /// 解析来自 bear 的参数
//    public func resolveParamOfBear(_ param: [String: String], with action: String)
//        throws -> (String, [String: String])
//    {
//        // 判断 action 是否有效
//        guard Actions.Bear(rawValue: action) != nil else {
//            throw ResolveURLSchemeError.invalidAction
//        }
//        return (action, param)
//    }
//
//    /// 解析来自 Ulysses 的参数
//    public func resolveParamOfUlysses(_ param: [String: String], with action: String)
//        throws -> (String, [String: String])
//    {
//        // 判断 action 是否有效
//        guard Actions.Ulysses(rawValue: action) != nil else {
//            throw ResolveURLSchemeError.invalidAction
//        }
//        return (action, param)
//    }
    
    // MARK: --便利方法----------------👇
    
    /// 合并用户与默认提供的 appBundles，如果有重复，以用户数据优先。
    static func combineAppBundles(_ defaultAppBundles: [String: String],
                                   userAppBundles: [String: String])
    -> [String: String] {
        return defaultAppBundles.merging(userAppBundles)
        { (_, new) in new }
    }
    
    /// 合并用户与默认提供的 actions，如果有重复，以用户数据优先。
    static func combineActions(_ defaultActions: [String: [String]],
                                   userActions: [String: [String]])
    -> [String: [String]] {
        return defaultActions.merging(userActions)
        { (_, new) in new }
    }
}
