//
//  Information.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-4-26.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import UIKit

/// UI 信息展示相关的便利方法
public struct UIInfo {
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
}
