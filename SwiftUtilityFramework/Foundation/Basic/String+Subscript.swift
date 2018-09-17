//
//  String+Subscript.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-12-25.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

extension String {
    
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
