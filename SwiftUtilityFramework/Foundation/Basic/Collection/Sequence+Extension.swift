//
//  Sequence+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-2-22.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import Foundation


// MARK: --普通序列扩展-------------------👇

extension Sequence {
    
    /// 检查一个序列中的所有元素是否全部都满足某个条件
    ///
    /// - Parameters:
    ///   - predicate: 筛选条件
    public func all(matching predicate: (Element) -> Bool) -> Bool {
        // 对于一个条件，如果没有元素不满足它的话，那意味着所有元素都满足它：
        return !contains { !predicate($0) }
    }
    
    /// 检查一个序列中的所有元素是否全部都不满足某个条件
    ///
    /// - Parameters:
    ///   - predicate: 筛选条件
    public func none(matching predicate: (Element) -> Bool) -> Bool {
        return !contains { predicate($0) }
    }
 
    /// 返回一个包含满足某个标准的所有元素的索引的列表，
    /// 和 index(where:) 类似，但是不会在遇到首个元素时就停止。
    ///
    /// - Parameters:
    ///   - predicate: 筛选条件
    public func indices(where predicate: (Element) -> Bool ) -> [Int] {
        var reuslt:[Int] = []
        for (index, item) in self.enumerated() {
            if predicate(item) {
                reuslt.append(index)
            }
        }
        return reuslt
    }
}

// MARK: --特定序列扩展：元素可转换为 Decimal 类型-------------------👇

/// 可转换为 Decimal 类型协议
protocol DecimalConvertible {
    /// 将值转换为对应的 Decimal 类型
    func decimalValue() -> Decimal
}
extension Decimal: DecimalConvertible {
    /// 将值转换为对应的 Decimal 类型
    func decimalValue() -> Decimal {
        return self
    }
}
extension Int: DecimalConvertible {
    /// 将值转换为对应的 Decimal 类型
    func decimalValue() -> Decimal {
        return Decimal(self)
    }
}
extension Double: DecimalConvertible {
    /// 将值转换为对应的 Decimal 类型
    func decimalValue() -> Decimal {
        return Decimal(self)
    }
}

extension Sequence where Element: DecimalConvertible {
    
    /// 对序列进行交替加减计算：1+2-3+4-5+6...
    func plusAndMinusInTurn() -> Decimal {
        var shouldPlus = true
        var shouldPlusFirst = true
        return reduce(Decimal(0)) { result, value in
            let running = result.decimalValue()
            let num = value.decimalValue()
            
            if shouldPlusFirst {
                shouldPlusFirst = false
                return running + num
            }
            
            if shouldPlus {
                shouldPlus = false
                return running + num
            } else {
                shouldPlus = true
                return running - num
            }
        }
    }
    
    /// 对序列进行交替减加计算：1-2+3-4+5-6...
    func minusAndPlusInTurn() -> Decimal {
        var shouldPlus = true
        return reduce(Decimal(0)) { result, value in
            let running = result.decimalValue()
            let num = value.decimalValue()
            
            if shouldPlus {
                shouldPlus = false
                return running + num
            } else {
                shouldPlus = true
                return running - num
            }
        }
    }
}
