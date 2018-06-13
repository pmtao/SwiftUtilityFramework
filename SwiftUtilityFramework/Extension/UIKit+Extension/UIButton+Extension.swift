//
//  UIButton+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-12-25.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit

extension UIButton {
    
    /// 平滑修改按钮显示的标题文字，修复 system 类型按钮直接修改文字时的轻微闪动。
    ///
    /// - Parameters:
    ///   - title: 待修改的标题文字
    ///   - state: 待修改的按钮状态
    func changeTitleSmoothly(_ title: String, for state : UIControlState) {
        self.titleLabel?.text = title
        self.setTitle(title, for: state)
    }
}
