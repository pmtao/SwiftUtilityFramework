//
//  Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-8-16.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit
import CommonCrypto

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
    
    // let's suppose alpha is the first component (ARGB)
    
    /// 通过一个16进制的整数 argb 值生成 UIColor 对象
    ///
    /// - Parameter argb: 6位长(0x000000~0xFFFFFF)或8位长(0x00000000~0xFFFFFFFF)的16进制整数。
    /// 按照：alpha、red、green、blue 的顺序。（alpha 可省略，默认为0xFF，即 alpha 为1）
    public convenience init(argb: Int) {
        var alpha = 0x0
        //如果入参中不包含 alpha 值，则默认为1
        alpha = (argb >> 24) & 0xFF
        
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: alpha
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

extension UIImage {

    /// 根据指定颜色的 hex 值，生成对应图片
    ///
    /// - Parameters:
    ///   - rgb: hex 类型代表的颜色值（0x000000~0xffffff）
    ///   - a: alpha 值（0x00~0xff）
    /// - Returns: 生成的 UIImage 对象
    static public func SUF_makeColorImage(rgb: Int, a: Int = 0xFF) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor(rgb: rgb, a: a).cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}

extension String {
    
    /// 生成字符串的 md5 值
    ///
    /// - Returns: 32位的 md5 值。
    public func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        return String(format: hash as String)
    }
    
    /// 通过范围表达式形式读取字符串
    /// 例如，可以使用 String[3...] 读取字符串从第 4 位到末尾的 Substring。
    /// - Parameter digitIndex: 范围表达式 n...
    public subscript(digitIndex: PartialRangeFrom<Int>) -> Substring? {
        let lowerBound = digitIndex.lowerBound
        let size = self.count
        if lowerBound < 0 || lowerBound > size - 1 {
            return nil
        }
        let lowerBoundIndex = index(startIndex, offsetBy: lowerBound)
        return self[lowerBoundIndex...]
    }
    
    /// 通过范围表达式形式读取字符串
    /// 例如，可以使用 String[...3] 读取字符串从第 1 位到第 4 位的 Substring。
    /// - Parameter digitIndex: 范围表达式 ...n
    public subscript(digitIndex: PartialRangeThrough<Int>) -> Substring? {
        let upperBound = digitIndex.upperBound
        let size = self.count
        if upperBound < 0 || upperBound > size - 1 {
            return nil
        }
        let upperBoundIndex = index(startIndex, offsetBy: upperBound)
        return self[...upperBoundIndex]
    }
    
    /// 通过范围表达式形式读取字符串
    /// 例如，可以使用 String[..<3] 读取字符串从第 1 位到第 3 位的 Substring。
    /// - Parameter digitIndex: 范围表达式 ..<n
    public subscript(digitIndex: PartialRangeUpTo<Int>) -> Substring? {
        let upperBound = digitIndex.upperBound
        let size = self.count
        if upperBound < 1 || upperBound > size {
            return nil
        }
        let upperBoundIndex = index(startIndex, offsetBy: upperBound)
        return self[..<upperBoundIndex]
    }
    
    
    
    
}

