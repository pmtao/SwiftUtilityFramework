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
}
