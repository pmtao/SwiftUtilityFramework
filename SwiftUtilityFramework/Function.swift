//
//  Function.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-8-16.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit
import CommonCrypto

/// 数字格式化(Double类型数字)
///
/// - Parameter with: 待格式化的数据
/// - Returns: 格式化结果字符串
public func SUF_numberFormat(with: Double) -> String {
    
    let format = NumberFormatter()
    var numberFormated: String
    
    format.numberStyle = .decimal
    format.maximumFractionDigits = 9 //最长9位小数
    numberFormated = format.string(from: NSNumber(value: with))!
    
    return numberFormated
    
}

/// 数字格式化(Int类型数字)
///
/// - Parameter with: 待格式化的数据
/// - Returns: 格式化结果字符串
public func SUF_numberFormat(with: Int) -> String {
    
    let format = NumberFormatter()
    var numberFormated: String
    
    format.numberStyle = .decimal
    numberFormated = format.string(from: NSNumber(value: with))!
    
    return numberFormated
    
}

/// 数字格式化(String类型数字)
///
/// - Parameter with: 待格式化的数据
/// - Returns: 格式化结果字符串
public func SUF_numberFormat(with: String) -> String {
    
    let format = NumberFormatter()
    var numberFormated: String
    
    format.numberStyle = .decimal
    numberFormated = format.string(from: format.number(from: with)!)!
    
    return numberFormated
    
}

/// 数字格式化(String类型数字)
///
/// - Parameter with: 待格式化的数据
/// - Returns: 格式化结果
public func SUF_stringToNumber(with: String) -> Double? {
    
    let format = NumberFormatter()
    var numberFormated: Double?
    
    //    format.numberStyle = .decimal
    numberFormated = format.number(from: with)?.doubleValue
    
    return numberFormated
    
}

/// 将 Double 值转为字符串，并进行格式化（添加千分位，如果等同于整数，则去掉小数部分）
///
/// - Parameter value: 要转换的值
/// - Returns: 转换后的字符串
public func SUF_doubleToFormatedString(value: Double) -> String {
    let intValue = Int(value)
    var doubleString = ""
    
    if Double(intValue) == value {
        doubleString = SUF_numberFormat(with: intValue)
    } else {
        doubleString = SUF_numberFormat(with: value)
    }
    return doubleString
}

    
/// 将一个能转为大小相同的 Double 值转为 Int 值
///
/// - Parameter value: 要转换的值
/// - Returns: 转换后的 Int 值，转换不成功则为 nil。
public func SUF_doubleToEqualInt(value: Double) -> Int? {
    var intValue: Int? = Int(value)
    if Double(intValue!) < value {
        intValue = nil
    }
    return intValue
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
}








