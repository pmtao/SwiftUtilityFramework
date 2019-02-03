//
//  StoppingSignalTimer.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-7-4.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import Foundation

/// 计时器状态数据
public struct TimerStatus {
    /// 当前状态
    var state: Poppin.State
    /// 第一次发出时间信号的时间戳(纳秒)
    var startTimestamp: Int
    /// 最后一次发出时间信号的时间戳(纳秒)
    var latestStartTimestamp: Int
    /// 最后一次暂停的时间戳(纳秒)
    var latestSuspendTimestamp: Int
    /// 计时器有效计时总时间(纳秒)
    var totalRunningTime: Int
    /// 计时器总暂停时间 - Poppin.State.suspended (纳秒)
    var totalSuspendedTime: Int
    
    public init(state: Poppin.State,
        startTimestamp: Int,
        latestStartTimestamp: Int,
        latestSuspendTimestamp: Int,
        totalRunningTime: Int,
        totalSuspendedTime: Int) {
       self.state = state
       self.startTimestamp = startTimestamp
       self.latestStartTimestamp = latestStartTimestamp
       self.latestSuspendTimestamp = latestSuspendTimestamp
       self.totalRunningTime = totalRunningTime
       self.totalSuspendedTime = totalSuspendedTime
    }
}


/// 基础计时器类
/// ## 特性：
/// 1. 指定开始时间后，一直运行，以固定的间隔时间执行回调闭包。
/// 2. 直到调用取消方法，计时器才停止计时。
/// 3. 回调方法中可以指定两个闭包，一个处理 UI 事件，一个处理后台线程（可指定后台队列）。
public class StoppingSignalTimer {
    
    
    // MARK: --公开属性-----------
    
    public var timer: DispatchSourceTimer?
    public var isValid: Bool {
        return timer != nil
    }
    
    // MARK: --私有属性-----------
    
    /// 计时开始的时间间隔
    private var startTime: Int = 0
    private var repeating: Int = 0
    /// 计时精度
    private var accuracy: Poppin.Accuracy = .microseconds
    /// 后台处理的队列
    private var backgroundHandleQueue: DispatchQueue?
    /// UI 处理闭包
    private var uiHandler: ((TimerStatus) -> Void)? = nil
    /// 后台处理闭包
    private var backgroundHandler: ((TimerStatus) -> Void)? = nil
    
    /// 计时器状态数据
    private var timerStatus = TimerStatus(state: .suspended,
                                          startTimestamp: 0,
                                          latestStartTimestamp: 0,
                                          latestSuspendTimestamp: 0,
                                          totalRunningTime: 0,
                                          totalSuspendedTime: 0)
    
    // MARK: --公开方法-----------
    
    /// 启动新的计时器，指定开始时间和总时长(包括暂停时间)，按照固定的时间间隔循环执行事件，从开始时间立即执行。
    ///
    /// - Parameters:
    ///   - startTime: 几秒后开始
    ///   - duration: 总时长
    ///   - repeating: 时间间隔秒数
    ///   - accuracy: 时间精度
    ///   - backgroundQueue: 用于后台处理的队列
    ///   - uiHandler: UI 相关的事件处理闭包
    ///   - backgroundHandler: 后台相关的事件处理闭包
    ///   - remainingTime: 剩余时间
    public func startStoppingSignalTimer(
        from startTime: Int = 0,
        repeating: Int,
        accuracy: Poppin.Accuracy = .microseconds,
        backgroundQueue: DispatchQueue? = nil,
        uiHandler: ((TimerStatus) -> Void)? = nil,
        backgroundHandler: ((TimerStatus) -> Void)? = nil)
    {
        // 重置内部属性
        resetProperties()
        
        // 创建新计时器
        let timer = createStoppingSignalTimer(
            from: startTime,
            repeating: repeating,
            accuracy: accuracy,
            backgroundQueue: backgroundQueue,
            uiHandler: uiHandler,
            backgroundHandler: backgroundHandler)
        // 取消现有计时器
        if self.isValid {
            if timerStatus.state != .canceled {
                cancel()
            }
        }
        self.timer = timer
        resume()
    }
    
    /// 激活计时器
    public func resume() {
        if timerStatus.state == .canceled {
            return
        }
        if timerStatus.state == .running {
            return
        }
        
        if timerStatus.state == .suspended {
            let currentTimeStamp = Date.getTimeStamp(.nanoseconds)
            // 计算总暂停时间
            #warning("暂停时间计算待确定")
            if timerStatus.latestSuspendTimestamp > 0 {
                timerStatus.totalSuspendedTime +=
                    currentTimeStamp - timerStatus.latestSuspendTimestamp
            }
            timerStatus.latestStartTimestamp = currentTimeStamp
            // 只在第一次启动时执行真正的启动操作，其他时候只更改状态。
            if self.timerStatus.startTimestamp == 0 {
                timer?.resume()
            }
            timerStatus.state = .running
            print("计时器启动了：\(currentTimeStamp.toTimeStamp(.milliseconds)) 毫秒")
        }
    }
    
    /// 暂停计时器
    public func suspend() {
        if timerStatus.state == .canceled {
            return
        }
        
        if timerStatus.state == .suspended {
            return
        } else {
            let currentTimeStamp = Date.getTimeStamp(.nanoseconds)
            // 计算总运行时间
            #warning("运行时间计算待确定")
            timerStatus.totalRunningTime +=
                currentTimeStamp - timerStatus.latestStartTimestamp
            // 不执行暂停操作，只更改状态。
            timerStatus.state = .suspended
            timerStatus.latestSuspendTimestamp = currentTimeStamp
            print("计时器暂停了：\(currentTimeStamp.toTimeStamp(.milliseconds)) 毫秒")
        }
    }
    
    /// 取消计时器
    public func cancel(_ message: String = "") {
        if timerStatus.state == .canceled {
            return
        } else {
            timer?.setEventHandler{}
            timer?.cancel()
            timer = nil
            timerStatus.state = .canceled
            print("计时器取消了：\(Date.getTimeStamp(.milliseconds))  毫秒 from \(message)")
        }
    }
    
    // MARK: --私有方法-----------
    
    /// 创建计时器，指定开始时间和总时长(包括暂停时间)，按照固定的时间间隔循环执行事件，从开始时间立即执行。
    ///
    /// - Parameters:
    ///   - startTime: 几秒后开始
    ///   - duration: 总时长
    ///   - repeating: 时间间隔秒数
    ///   - accuracy: 时间精度
    ///   - backgroundQueue: 用于后台处理的队列
    ///   - uiHandler: UI 相关的事件处理闭包
    ///   - backgroundHandler: 后台相关的事件处理闭包
    ///   - remainingTime: 剩余时间
    private func createStoppingSignalTimer(
        from startTime: Int = 0,
        repeating: Int,
        accuracy: Poppin.Accuracy = .microseconds,
        backgroundQueue: DispatchQueue? = nil,
        uiHandler: ((TimerStatus) -> Void)? = nil,
        backgroundHandler: ((TimerStatus) -> Void)? = nil)
        -> DispatchSourceTimer?
    {
        self.startTime = startTime
        self.repeating = repeating
        self.accuracy = accuracy
        self.backgroundHandleQueue = backgroundQueue
        self.uiHandler = uiHandler
        self.backgroundHandler = backgroundHandler
        
        // 数据有效性校验
        if startTime < 0 {
            return nil
        }
        if repeating <= 0 {
            return nil
        }
        
        let timer = DispatchSource.makeTimerSource()
        print("核心计时器已创建：\(timer) at \(Date.getTimeStamp(.nanoseconds)) 纳秒")
        timer.schedule(deadline: .now() + .nanoseconds(startTime.getNanoseconds(accuracy)),
                       repeating: .nanoseconds(repeating.getNanoseconds(accuracy)),
                       leeway: .nanoseconds(1.getNanoseconds(accuracy)))
        
        timer.setEventHandler {
            let currentTimeStamp = Date.getTimeStamp(.nanoseconds)
//            print("currentTimeStamp: \(currentTimeStamp) 纳秒")
            // 记录第一次启动时间
            if self.timerStatus.startTimestamp == 0 {
                self.timerStatus.startTimestamp = currentTimeStamp
                self.timerStatus.latestStartTimestamp = currentTimeStamp
//                print("startTimestamp: \(self.timerStatus.startTimestamp) 纳秒")
            }
            if self.timerStatus.state == .running {
                // 准备回调闭包
                let uiHandler = self.prepareEventHandler(queue: DispatchQueue.main, handler: uiHandler)
                let backgroundHandler = self.prepareEventHandler(queue: backgroundQueue, handler: backgroundHandler)
                // 执行闭包
                uiHandler(self.timerStatus)
                backgroundHandler(self.timerStatus)
            } else if self.timerStatus.state == .suspended {
//                print("计时器已暂停，暂不执行闭包。")
            }
        }
        return timer
    }
    
    // MARK: --辅助方法-----------
    
    /// 选择合适的队列准备事件处理闭包
    func prepareEventHandler(queue: DispatchQueue? = nil,
                             handler: ((TimerStatus) -> Void)? = nil)
        -> ((TimerStatus) -> Void)
    {
        let packedHandler = { (timerStatus: TimerStatus) in
            if queue == nil {
                if handler != nil {
                    handler!(timerStatus)
                }
            } else {
                if handler != nil {
                    queue!.async {
                        handler!(timerStatus)
                    }
                }
            }
        }
        
        return packedHandler
    }
    
    /// 重置内部属性，在启动新计时器第一步时使用。
    private func resetProperties() {
        startTime = 0
        repeating = 0
        backgroundHandleQueue = nil
        uiHandler = nil
        backgroundHandler = nil
        accuracy = .microseconds
        timerStatus = TimerStatus(state: .suspended,
                                  startTimestamp: 0,
                                  latestStartTimestamp: 0,
                                  latestSuspendTimestamp: 0,
                                  totalRunningTime: 0,
                                  totalSuspendedTime: 0)
    }

}
