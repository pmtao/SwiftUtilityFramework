//
//  Array+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-2-22.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import Foundation

extension Array {
    
    /// 给定一个初始值，与数组中的元素共同进行指定的计算，并将结果传递给下一个元素重复相同的计算。
    ///
    /// - Parameters:
    ///   - initialResult: 初始值
    ///   - nextPartialResult: 递进计算方法
    ///   - result: 上一个计算结果
    ///   - item: 当前元素
    /// - Returns: 每一步递进计算的结果组成的数组
    func accumulate<Result>(_ initialResult: Result,
                            _ nextPartialResult: (_ result: Result, _ item: Element) -> Result) -> [Result]
    {
        var running = initialResult
        return map { next in
            running = nextPartialResult(running, next)
            return running
        }
    }
    
    /// 计算满足条件的元素个数
    ///
    /// - Parameters:
    ///   - where: 筛选条件
    ///   - item: 集合内元素
    /// - Returns: 元素个数
    public func count(where predicate: (_ item: Element) -> Bool) -> Int {
        if isEmpty {
            return 0
        }
        
        var count = 0
        for item in self {
            if predicate(item) {
                count += 1
            }
        }
        return count
    }
}
