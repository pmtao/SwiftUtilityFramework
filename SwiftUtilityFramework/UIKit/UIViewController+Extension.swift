//
//  UIViewController+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-6-27.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import UIKit

extension UIViewController {

    
    /// 只显示一个提示信息的提示框，点击按钮后可执行指定操作。
    @available(*, deprecated, message: "This function has issue, please use UIInfo.hint(title:message:)")
    public func simpleAlert(title: String,
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
        if self.presentedViewController == nil {
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
