//
//  UIColor+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-12-25.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// 根据 RGB 的整数值(0~255)直接生成 UIColor 对象
    ///
    /// - Parameters:
    ///   - red: red 整数值
    ///   - green: green 整数值
    ///   - blue: blue 整数值
    ///   - a: 可选参数，默认为 1。
    public convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    /// 通过一个16进制的整数 argb 值生成 UIColor 对象
    ///
    /// - Parameter argb: 8位长(0x00000000~0xFFFFFFFF)的16进制整数。
    /// 按照：alpha、red、green、blue 的顺序。
    public convenience init(argb: Int64) {
        self.init(
            red: Int((argb >> 16) & 0xFF),
            green: Int((argb >> 8) & 0xFF),
            blue: Int(argb & 0xFF),
            a: Int((argb >> 24) & 0xFF)
        )
    }
    
    
    /// 通过一个16进制的整数 rgb 值生成 UIColor 对象
    ///
    /// - Parameters:
    ///   - rgb: 16进制整数形式的 RGB 值(0x000000~0xFFFFFF)
    ///   - a: 16进制整数形式的 Alpha 值(0x00~0xFF)，可省略，默认为0xFF。
    public convenience init(rgb: Int, a: Int = 0xFF) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
    
}
