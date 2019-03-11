//
//  Information.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-4-26.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import UIKit

/// UI 信息展示相关的便利方法
public class UIInfo {
    static var alertWindow: UIWindow?
    
    /// 只显示一个提示信息的提示框
    static public func simpleAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        UIApplication.shared.keyWindow!.rootViewController!.present(
            alertController, animated: true, completion: nil)
    }
    
    /// 只显示一个提示信息的提示框，点击按钮后可执行指定操作。
    static public func simpleAlert(title: String,
                                   message: String,
                                   buttonTitle: String,
                                   handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "算了", style: .cancel, handler: nil)
        let performAction = UIAlertAction(title: buttonTitle, style: .default, handler: handler)
        alertController.addAction(cancelAction)
        alertController.addAction(performAction)
        UIApplication.shared.keyWindow!.rootViewController!.present(
            alertController, animated: true, completion: nil)
    }
    
    /// 简单信息提示框(可在任意页面显示)
    static public func hint(title: String, message: String) {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "知道了", style: .cancel) { (alertAction) in
            alertWindow?.resignKey()
            alertWindow?.isHidden = true
            alertWindow = nil
        }
        alertController.addAction(cancelAction)
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = nil
        alertWindow?.rootViewController = rootVC
        alertWindow?.makeKeyAndVisible()
        rootVC.present(alertController, animated: true)
        
        // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
        if let topWindow = UIApplication.shared.windows.last {
            alertWindow?.windowLevel = topWindow.windowLevel + 1
        }
    }
    
    /// 简单信息提示框(可在任意页面显示)，支持执行指定操作。
    ///
    /// - Parameters:
    ///   - title: 提示框标题
    ///   - message: 提示框信息
    ///   - cancelButtonTitle: 取消按钮标题
    ///   - actions: 操作数组，数组元素为一个元组，元组中元素依次为操作标题、操作 handler、操作是否为首选项。
    static public func hint(title: String,
                            message: String,
                            cancelButtonTitle: String = "取消",
                            defaultTextColor: UIColor? = nil,
                            actions: [(String, (UIAlertAction) -> Void, Bool)]) {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let alertController = UIAlertController(title: title.isEmpty ? nil : title,
                                                message: message.isEmpty ? nil : message,
                                                preferredStyle: .actionSheet)
        if defaultTextColor != nil {
            alertController.view.tintColor = defaultTextColor!
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (alertAction) in
            alertWindow?.resignKey()
            alertWindow?.isHidden = true
            alertWindow = nil
        }
        alertController.addAction(cancelAction)
        for action in actions {
            let style: UIAlertAction.Style = action.2 ? .destructive : .default
            let performAction = UIAlertAction(title: action.0, style: style) { (alertAction) in
                action.1(alertAction)
                alertWindow?.resignKey()
                alertWindow?.isHidden = true
                alertWindow = nil
            }
            alertController.addAction(performAction)
        }
        
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = nil
        // setting only for iPad
        alertController.popoverPresentationController?.sourceView = rootVC.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100, width: 0, height: 0)

        
        alertWindow?.rootViewController = rootVC
        alertWindow?.makeKeyAndVisible()
        rootVC.present(alertController, animated: true)
        
        // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
        if let topWindow = UIApplication.shared.windows.last {
            alertWindow?.windowLevel = topWindow.windowLevel + 1
        }
    }
    
    
}
