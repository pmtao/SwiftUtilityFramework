//
//  FixedDurationTimer.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-7-4.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import Foundation

/// 固定总时长的计时器（包括暂停时间）
public class FixedDurationTimer {
    
    
    // MARK: --公开属性-----------
    
    public var timer: DispatchSourceTimer?
    public var isValid: Bool {
        return timer != nil
    }
    /// 计时器状态
    public var state: Poppin.State = .suspended
    
    // MARK: --私有属性-----------
    
    /// 计时开始的时间间隔
    private var startTime: Int = 0
    private var duration: Int = 0
    private var endTime: Int = 0
    private var repeating: Int = 0
    private var observingPoints: [Int] = []
    private var observingSlices: [(Int, Int)] = []
    /// 计时精度
    private var accuracy: Poppin.Accuracy = .microseconds
    /// 后台处理的队列
    private var backgroundHandleQueue: DispatchQueue?
    /// UI 处理闭包
    private var uiHandler: ((_ remainingTime: Int) -> Void)? = nil
    /// 后台处理闭包
    private var backgroundHandler: ((_ remainingTime: Int) -> Void)? = nil
    
    /// 开始时间戳(纳秒)
    private var startTimestamp: Int = 0
    /// 最后一次启动时间戳(纳秒)
    private var latestStartTimestamp: Int = 0
    /// 最后一次暂停时间戳(纳秒)
    private var latestSuspendTimestamp: Int = 0
    /// 总运行时间(纳秒)
    private var totalRunningTime: Int = 0
    /// 总暂停时间(纳秒)
    private var totalSuspendedTime: Int = 0
    
    
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
    public func startFixedDurationTimer(
        from startTime: Int = 0,
        duration: Int,
        repeating: Int,
        accuracy: Poppin.Accuracy = .microseconds,
        backgroundQueue: DispatchQueue? = nil,
        uiHandler: ((_ remainingTime: Int) -> Void)? = nil,
        backgroundHandler: ((_ remainingTime: Int) -> Void)? = nil)
    {
        // 重置内部属性
        resetProperties()
        
        // 创建新计时器
        let timer = createFixedDurationTimer(
            from: startTime,
            duration: duration,
            repeating: repeating,
            accuracy: accuracy,
            backgroundQueue: backgroundQueue,
            uiHandler: uiHandler,
            backgroundHandler: backgroundHandler)
        // 取消现有计时器
        if self.isValid {
            switch state {
            case .running:
                cancel()
            case .suspended:
                resume()
                cancel()
            default:
                break
            }
        }
        
        self.timer = timer
        resume()
    }
    
    /// 激活计时器
    public func resume() {
        //        if state == .canceled {
        //            return
        //        }
        // 在 canceled / suspended 状态下都可以启动
        if state == .running {
            return
        } else {
            let currentTimeStamp = Date.getTimeStamp(.nanoseconds)
            
            if latestSuspendTimestamp > 0 {
                // 记录暂停时间
                totalSuspendedTime += currentTimeStamp - latestSuspendTimestamp
                // 在暂停之后又重新恢复前，需要重新创建计时器，以解决暂停时积压的时间信号。
                // 如果继续使用原有计时器，在恢复计时后，前两次发出的时间信号将不准确（短于间隔时间）。
                let remainingTime = startTimestamp + duration.getNanoseconds(accuracy) - currentTimeStamp
                print("已计时: \(totalRunningTime.toTimeStamp(.milliseconds)) 毫秒")
                print("已暂停: \(totalSuspendedTime.toTimeStamp(.milliseconds)) 毫秒")
                print("剩余: \(remainingTime.toTimeStamp(.milliseconds)) 毫秒")
                
                if remainingTime <= 0 {
                    // 此时已超过原定的持续时间，计时器应取消。
                    self.timer?.resume()
                    self.timer?.cancel()
                    self.timer = nil
                    self.state = .canceled
                    print("计时器已超时取消 at \(currentTimeStamp.toTimeStamp(.milliseconds)) 毫秒")
                    return
                } else {
                    // 创建新的计时器，并替换现有的计时器，保持原有持续时间不变。
                    let newTimer = createFixedDurationTimer(
                        from: 0,
                        duration: duration,
                        repeating: repeating,
                        accuracy: accuracy,
                        backgroundQueue: backgroundHandleQueue,
                        uiHandler: uiHandler,
                        backgroundHandler: backgroundHandler)
                    self.timer?.resume()
                    self.timer?.cancel()
                    self.timer = nil
                    print("原计时器已取消，已替换为新的计时器。")
                    self.timer = newTimer
                }
            }
            timer?.resume()
            state = .running
            latestStartTimestamp = currentTimeStamp
            print("计时器启动了：\(currentTimeStamp.toTimeStamp(.milliseconds)) 毫秒")
        }
    }
    
    /// 暂停计时器
    public func suspend() {
        if state == .canceled {
            return
        }
        
        if state == .suspended {
            return
        } else {
            let currentTimeStamp = Date.getTimeStamp(.nanoseconds)
            // 记录运行时间
            totalRunningTime += currentTimeStamp - latestStartTimestamp
            timer?.suspend()
            state = .suspended
            latestSuspendTimestamp = currentTimeStamp
            print("计时器暂停了：\(currentTimeStamp.toTimeStamp(.milliseconds)) 毫秒")
        }
    }
    
    /// 取消计时器
    public func cancel(_ message: String = "") {
        if state == .canceled {
            return
        } else {
            if state != .running {
                resume()
            }
            timer?.setEventHandler{}
            timer?.cancel()
            timer = nil
            state = .canceled
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
    private func createFixedDurationTimer(
        from startTime: Int = 0,
        duration: Int,
        repeating: Int,
        accuracy: Poppin.Accuracy = .microseconds,
        backgroundQueue: DispatchQueue? = nil,
        uiHandler: ((_ remainingTime: Int) -> Void)? = nil,
        backgroundHandler: ((_ remainingTime: Int) -> Void)? = nil)
        -> DispatchSourceTimer?
    {
        self.startTime = startTime
        self.duration = duration
        self.repeating = repeating
        self.accuracy = accuracy
        self.backgroundHandleQueue = backgroundQueue
        self.uiHandler = uiHandler
        self.backgroundHandler = backgroundHandler
        
        // 数据有效性校验
        if startTime < 0 {
            return nil
        }
        if duration <= 0 {
            return nil
        }
        if repeating <= 0 {
            return nil
        }
        if repeating > duration {
            return nil
        }
        
        let timer = DispatchSource.makeTimerSource()
        print("核心计时器已创建：\(timer) at \(Date.getTimeStamp(.nanoseconds)) 纳秒")
        timer.schedule(deadline: .now() + .nanoseconds(startTime.getNanoseconds(accuracy)),
                       repeating: .nanoseconds(repeating.getNanoseconds(accuracy)),
                       leeway: .nanoseconds(1.getNanoseconds(accuracy)))
        
        timer.setEventHandler {
            let currentTimeStamp = Date.getTimeStamp(.nanoseconds)
            print("currentTimeStamp: \(currentTimeStamp) 纳秒")
            // 记录第一次启动时间
            if self.startTimestamp == 0 {
                self.startTimestamp = currentTimeStamp
                self.latestStartTimestamp = currentTimeStamp
                print("startTimestamp: \(self.startTimestamp) 纳秒")
            }
            
            let remainingTime = (self.startTimestamp + self.duration.getNanoseconds(accuracy)) - currentTimeStamp
            print("剩余时间：\(remainingTime) 纳秒")
            let uiHandler = self.prepareEventHandler(queue: DispatchQueue.main, handler: uiHandler)
            let backgroundHandler = self.prepareEventHandler(queue: backgroundQueue, handler: backgroundHandler)
            
            if self.state == .running {
                // 计时器未结束时，继续执行。
                if remainingTime > 0 {
                    print("\n开始执行计时器事件：\(Date.getTimeStamp(.microseconds)) 微秒====>")
                    uiHandler(remainingTime)
                    backgroundHandler(remainingTime)
                    print("结束计时器事件：\(Date.getTimeStamp(.microseconds)) 微秒 <====\n")
                }
                
                // 还有不足间隔时间的剩余时间，延迟到结束时再执行一次。
                if remainingTime <= repeating.getNanoseconds(accuracy)
                    && remainingTime > 0 {
                    
                    self.cancel("还有不足间隔时间的剩余时间 \(remainingTime) 纳秒") // 先取消计时器
                    DispatchQueue.global().asyncAfter(
                    deadline: .now() + .nanoseconds(remainingTime)) {
                        uiHandler(0)
                        backgroundHandler(0)
                    }
                }
                
                // 计时器刚结束，继续执行。
                if remainingTime == 0 {
                    self.cancel("计时器刚结束") // 取消计时器
                    uiHandler(remainingTime)
                    backgroundHandler(remainingTime)
                }
                
                // 已过时效，取消计时器。
                if remainingTime < 0 {
                    self.cancel("已过时效，取消计时器")
                }
                
            } else if self.state == .suspended {
                // 当前如果是暂停状态，事件无需执行。
                print("计时器已取消了：\(Date.getTimeStamp(.microseconds)) 毫秒")
            }
        }
        return timer
    }
    
    // MARK: --辅助方法-----------
    
    /// 准备事件处理闭包
    func prepareEventHandler(queue: DispatchQueue? = nil,
                             handler: ((_ remainingTime: Int) -> Void)? = nil)
        -> ((Int) -> Void)
    {
        let packedHandler = { (_ remainingTime: Int) in
            if queue == nil {
                if handler != nil {
                    handler!(remainingTime)
                }
            } else {
                if handler != nil {
                    queue!.async {
                        handler!(remainingTime)
                    }
                }
            }
        }
        
        return packedHandler
    }
    
    /// 重置内部属性，在启动新计时器第一步时使用。
    private func resetProperties() {
        state = .suspended
        startTime = 0
        startTimestamp = 0
        duration = 0
        endTime = 0
        repeating = 0
        observingPoints = []
        observingSlices = []
        backgroundHandleQueue = nil
        uiHandler = nil
        backgroundHandler = nil
        accuracy = .microseconds
        latestStartTimestamp = 0
        latestSuspendTimestamp = 0
        totalRunningTime = 0
        totalSuspendedTime = 0
    }
    
}
