//
//  Poppin.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-7-4.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import Foundation

/// 一个像机器般精确运转的计时器，
/// 基于 DispatchSourceTimer，真正的暂停、恢复功能。
public class Poppin {
    // MARK: --不同类型计时器-----------
    var fixedDurationTimer: FixedDurationTimer?
    var stoppingSignalTimer: StoppingSignalTimer?
    
    
    
    // MARK: --需要初始化的属性-----------
    let timingMode: TimingMode
    
    // MARK: --枚举类型-----------
    
    /// 计时模式
    ///
    /// - fixedDuration: 固定总时长，包括暂停时间。
    /// - fixedActiveDuration: 固定活跃总时长，不包括暂停时间。
    /// - fixedEndingTime: 固定截止时间，到时间即停止计时，即使在暂停状态。
    /// - stoppingSignal: 根据信号结束计时
    /// - observingPoints: 固定观测时间点
    /// - observingSlices: 固定观测时间段
    public enum TimingMode {
        case fixedDuration
        case fixedActiveDuration
        case fixedEndingTime
        case stoppingSignal
        case observingPoints
        case observingSlices
    }
    
    /// 计时精度
    ///
    /// - seconds: 秒
    /// - milliseconds: 毫秒
    /// - microseconds: 微秒
    /// - nanoseconds: 纳秒
    public enum Accuracy {
        /// 秒
        case seconds
        /// 毫秒
        case milliseconds
        /// 微秒
        case microseconds
        /// 纳秒
        case nanoseconds
    }
    
    /// 计时器状态类型
    public enum State {
        /// 暂停
        case suspended
        /// 运行中
        case running
        /// 已取消
        case canceled
    }
    
    /// 当前计时器是否有效
    public var isValid: Bool {
        switch timingMode {
        case .fixedDuration:
            return fixedDurationTimer != nil
        case .stoppingSignal:
            return stoppingSignalTimer != nil
        default:
            return false
        }
    }
    
    public init(_ timingMode: TimingMode) {
        self.timingMode = timingMode
    }
    
    // MARK: --计时器创建方法(通用)-----------
    
    // 不同类型计时器，handler 参数不同，暂不统一。
    
//    /// 创建并启动指定类型计时器(通用方法)
//    ///
//    /// - Parameters:
//    ///   - timingMode: 计时模式
//    ///   - startTime: 多少时间后开始
//    ///   - duration: 总时长
//    ///   - endTime: 多少时间后结束
//    ///   - repeating: 时间间隔
//    ///   - observingPoints: 观测时间点数组
//    ///   - observingSlices: 观测时间段数组
//    ///   - accuracy: 时间精度
//    ///   - backgroundQueue: 用于后台处理的队列
//    ///   - uiHandler: UI 相关的事件处理闭包
//    ///   - backgroundHandler: 后台相关的事件处理闭包
//    ///   - remainingTime: 剩余时间
//    public func startTimer(
//        _ timingMode: TimingMode,
//        from startTime: Int = 0,
//        duration: Int = 0,
//        to endTime: Int = 0,
//        repeating: Int = 0,
//        observingPoints: [Int] = [],
//        observingSlices: [(Int, Int)] = [],
//        accuracy: Poppin.Accuracy = .seconds,
//        backgroundQueue: DispatchQueue? = nil,
//        uiHandler: ((_ remainingTime: Int) -> Void)? = nil,
//        backgroundHandler: ((_ remainingTime: Int) -> Void)? = nil)
//    {
//        switch timingMode {
//        case .fixedDuration:
//            startFixedDurationTimer(
//                from: startTime,
//                duration: duration,
//                repeating: repeating,
//                accuracy: accuracy,
//                backgroundQueue: backgroundQueue,
//                uiHandler: uiHandler,
//                backgroundHandler: backgroundHandler)
//        case .stoppingSignal:
//            startStoppingSignalTimer(
//                from: startTime,
//                repeating: repeating,
//                accuracy: accuracy,
//                backgroundQueue: backgroundQueue,
//                uiHandler: uiHandler,
//                backgroundHandler: backgroundHandler)
//        default:
//            break
//        }
//    }
    
    // MARK: --计时器创建方法(具体)-----------
    
    /// 创建并启动【TimingMode: fixedDuration】类型计时器
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
        
        if fixedDurationTimer == nil {
            fixedDurationTimer = FixedDurationTimer()
        }
        fixedDurationTimer?.startFixedDurationTimer(
            from: startTime,
            duration: duration,
            repeating: repeating,
            accuracy: accuracy,
            backgroundQueue: backgroundQueue,
            uiHandler: uiHandler,
            backgroundHandler: backgroundHandler)
        fixedDurationTimer?.resume()
    }
    
    
    public func startStoppingSignalTimer(
        from startTime: Int = 0,
        repeating: Int,
        accuracy: Poppin.Accuracy = .microseconds,
        backgroundQueue: DispatchQueue? = nil,
        uiHandler: ((TimerStatus) -> Void)? = nil,
        backgroundHandler: ((TimerStatus) -> Void)? = nil)
    {
        if stoppingSignalTimer == nil {
            stoppingSignalTimer = StoppingSignalTimer()
        }
        stoppingSignalTimer?.startStoppingSignalTimer(
            from: startTime,
            repeating: repeating,
            accuracy: accuracy,
            backgroundQueue: backgroundQueue,
            uiHandler: uiHandler,
            backgroundHandler: backgroundHandler)
        stoppingSignalTimer?.resume()
    }
    
    
    // MARK: --计时器通用操作方法-----------
    
    /// 恢复计时器
    public func resume() {
        switch timingMode {
        case .fixedDuration:
            fixedDurationTimer?.resume()
        case .stoppingSignal:
            stoppingSignalTimer?.resume()
        default:
            break
        }
    }
    
    /// 暂停计时器
    public func suspend() {
        switch timingMode {
        case .fixedDuration:
            fixedDurationTimer?.suspend()
        case .stoppingSignal:
            stoppingSignalTimer?.suspend()
        default:
            break
        }
    }
    
    /// 取消计时器
    public func cancel() {
        switch timingMode {
        case .fixedDuration:
            fixedDurationTimer?.cancel()
            fixedDurationTimer = nil
        case .stoppingSignal:
            stoppingSignalTimer?.cancel()
            stoppingSignalTimer = nil
        default:
            break
        }
    }
}

// MARK: --便利扩展-----------

extension Int {
    /// 将指定精度的时间数转换为纳秒
    public func getNanoseconds(_ accuracy: Poppin.Accuracy) -> Int {
        var result: Int
        switch accuracy {
        case .seconds:
            result = self * 1000_000_000
        case .milliseconds:
            result = self * 1000_000
        case .microseconds:
            result = self * 1000
        case .nanoseconds:
            result = self
        }
        return result
    }
    
    /// 将纳秒计数的时间戳转换为指定精度时间戳
    public func toTimeStamp(_ accuracy: Poppin.Accuracy) -> Int {
        var result: Int
        switch accuracy {
        case .seconds:
            result = self / 1000_000_000
        case .milliseconds:
            result = self / 1000_000
        case .microseconds:
            result = self / 1000
        case .nanoseconds:
            result = self
        }
        return result
    }
}

extension Date {
    
    /// 获取指定精度的时间戳(以 1970-1-1 为基准时间线)
    public static func getTimeStamp(_ accuracy: Poppin.Accuracy) -> Int {
        var result: Int
        switch accuracy {
        case .seconds:
            result = Int(Date().timeIntervalSince1970)
        case .milliseconds:
            result = Int(Date().timeIntervalSince1970 * 1000)
        case .microseconds:
            result = Int(Date().timeIntervalSince1970 * 1000_000)
        case .nanoseconds:
            result = Int(Date().timeIntervalSince1970 * 1000_000_000)
        }
        return result
    }
    
    
}
