//
//  DispatchObject+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-6-28.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import Foundation

extension DispatchObject {
    
    /// 延迟执行闭包
    ///
    /// - Parameters:
    ///   - time: 几秒后执行
    ///   - block: 待执行的闭包
    public static func dispatch_later(_ time: TimeInterval, block: @escaping ()->()) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    
    
    /// 可以对原任务进行替换的闭包，并支持指定新延迟时间。
    /// （新的延迟时间与原有延迟时间都从相同的时间起点计算）
    ///
    /// - Parameters:
    ///   - newDelayTime: 新任务执行时的延迟时间
    ///   - anotherTask: 待替换的新任务
    public typealias ExchangableTask = (
        _ newDelayTime: TimeInterval?, _ anotherTask:@escaping (() -> ())
        ) -> Void
    
    /// 延迟执行一个任务，并支持在实际执行前替换为新的任务，并设定新的延迟时间。
    ///
    /// - Parameters:
    ///   - time: 延迟时间
    ///   - yourTask: 要执行的任务
    /// - Returns: 可替换原任务的闭包
    public static func delay(_ time: TimeInterval, yourTask: @escaping ()->()) -> ExchangableTask {
        var exchangingTask: (() -> ())? // 备用替代任务
        var newDelayTime: TimeInterval? // 新的延迟时间
        
        let finalClosure = { () -> Void in
            if exchangingTask == nil {
                DispatchQueue.main.async(execute: yourTask)
            } else {
                if newDelayTime == nil {
                    DispatchQueue.main.async {
                        print("任务已更改，现在是：\(Date().timeIntervalSince1970 * 1000) 毫秒")
                        exchangingTask!()
                    }
                }
                print("原任务取消了，现在是：\(Date().timeIntervalSince1970 * 1000) 毫秒")
            }
        }
        
        dispatch_later(time) { finalClosure() }
        
        let exchangableTask: ExchangableTask =
        { delayTime, anotherTask in
            exchangingTask = anotherTask
            newDelayTime = delayTime
            
            if delayTime != nil {
                self.dispatch_later(delayTime!) {
                    anotherTask()
                    print("任务已更改，现在是：\(Date().timeIntervalSince1970 * 1000) 毫秒")
                }
            }
        }
        
        return exchangableTask
    }
}


