//
//  BetterWKWebView.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-7-24.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import WebKit

/// 常用 WKWebView 注入脚本
public struct CommonWKWebViewScript {
    /// 解决 html 显示时字体过小的脚本
    static public let fontSizeBiggerScript =
    """
    var meta = document.createElement('meta');
    meta.setAttribute('name', 'viewport');
    meta.setAttribute('content', 'width=device-width');
    document.getElementsByTagName('head')[0].appendChild(meta);
    """
    
    /// 禁止缩放脚本
    static public let unscalableScript =
    """
    var meta = document.createElement('meta');
    meta.setAttribute('name', 'viewport');
    meta.setAttribute('content', 'initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no');
    document.getElementsByTagName('head')[0].appendChild(meta);
    """
    
    /// 禁止横屏时自动调整字体大小
    static public let fontSizeAdjustScript =
    """
    var style = document.createElement('style');
    style.setAttribute('type', 'text/css');
    style.innerHTML = 'body { -webkit-text-size-adjust: 100%; }';
    document.getElementsByTagName('head')[0].appendChild(style);
    """
    
    
    /// 禁用链接长按时弹出菜单
    static public let forbidTouchCallout =
    "document.documentElement.style.webkitTouchCallout='none';"
    
    
    /// 获取选中的文本
    static public let getSelectedStringScript = "window.getSelection().toString()"
    
    
}


/// 针对常见问题优化过的 WKWebView
open class BetterWKWebView: WKWebView {
    
    
    // MARK: --初始化方法-----------
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    /// 使用包含默认优化脚本的配置文件进行初始化
    public convenience init(frame: CGRect) {
        self.init(frame: frame,
                  configuration: BetterWKWebView.defaultScriptedConfiguration())
    }
    
    
    /// 生成包含默认优化脚本的配置文件
    public static func defaultScriptedConfiguration(
        _ scriptSources: [String] = [CommonWKWebViewScript.fontSizeBiggerScript,
                                     CommonWKWebViewScript.unscalableScript,
                                     CommonWKWebViewScript.fontSizeAdjustScript],
        messageHandler: WKScriptMessageHandler? = nil,
        handlerName: String? = nil)
        -> WKWebViewConfiguration
    {
        let webConfiguration = WKWebViewConfiguration()
        let UserScripts = importScriptSources(scriptSources)
        let userContentController =
            setScriptController(UserScripts,
                                messageHandler: messageHandler,
                                named: handlerName)
        webConfiguration.userContentController = userContentController
        return webConfiguration
    }
    
    
    
    // MARK: --脚本注入相关方法-------------------👇
    
    /// 导入自定义脚本文件(支持导入多个。)
    ///
    /// - Parameter names: 脚本名称数组：[a.js, b.js, c.js...]
    /// - Returns: 可注入的脚本对象
    public static func importScriptFiles(
        _ scriptNames: [String],
        injectionTime: WKUserScriptInjectionTime = .atDocumentEnd,
        forMainFrameOnly: Bool = false) -> [WKUserScript]
    {
        var UserScripts = [WKUserScript]()
        let bundle = Bundle.init(for: self)
        for name in scriptNames {
            let scriptPath = bundle.path(forResource: name, ofType: "js")
            let script = try! String(contentsOfFile: scriptPath!, encoding: .utf8)
            UserScripts.append(WKUserScript(source: script,
                                            injectionTime: injectionTime,
                                            forMainFrameOnly: forMainFrameOnly))
        }
        return UserScripts
    }
    
    /// 导入自定义脚本源码(直接输入源码字符串，支持导入多个。)
    ///
    /// - Parameter sources: 脚本源码字符串数组：["source1", "source2", "source3"...]
    /// - Returns: 可注入的脚本对象
    public static func importScriptSources(
        _ scriptSources: [String],
        injectionTime: WKUserScriptInjectionTime = .atDocumentEnd,
        forMainFrameOnly: Bool = false) -> [WKUserScript]
    {
        var UserScripts = [WKUserScript]()
        for scriptSource in scriptSources {
            UserScripts.append(WKUserScript(source: scriptSource,
                                            injectionTime: injectionTime,
                                            forMainFrameOnly: forMainFrameOnly))
        }
        return UserScripts
    }
    
    /// 设置脚本控制器
    ///
    /// - Parameter userScripts: 可注入的脚本对象
    /// - Returns: WKUserContentController 对象
    public static func setScriptController(_ userScripts: [WKUserScript],
                                    messageHandler: WKScriptMessageHandler? = nil,
                                    named handlerName: String? = nil)
        -> WKUserContentController
    {
        let userContentController = WKUserContentController()
        for userScript in userScripts {
            userContentController.addUserScript(userScript)
        }
        if messageHandler != nil && handlerName != nil {
            userContentController.add(messageHandler!, name: handlerName!)
        }
        
        return userContentController
    }
    
    
    
}
