//
//  KeyBoardNotification.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/2/27.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

public enum KeyBoardNotificationType {
    case frameWillChange
    case frameDidChange
    case keyBoardWillShow
    case keyBoardDidShow
    case keyBoardWillHide
    case keyBoardDidHid
}

/// 监听键盘通知与处理的便利类。
/// - 通知处理的 block 中无需再判断键盘事件是否由当前 App 产生（已内置判断），但仍需判断是由哪个视图激活键盘事件的，否则会被错误调用。
/// - 使用方法：
/// ```
/// // 初始化
/// let keyBoardNotifier = KeyBoardNotifier()
/// keyBoardNotifier.listen(frameWillChange: { keyBoardInfo in
///     // 通知处理
///     // ...
/// })
/// ```
public class KeyBoardNotifier {
    var token: [KeyBoardNotificationType: NotificationToken?] = [:]
    
    public init() {
        
    }
    
    @discardableResult
    public func listen(frameWillChange: @escaping (_ info: KeyBoardInfo) -> Void) -> KeyBoardNotifier {
        token[.frameWillChange] = addObserver(UIResponder.keyboardWillChangeFrameNotification, block: frameWillChange)
        return self
    }
    
    @discardableResult
    public func listen(frameDidChange: @escaping (_ info: KeyBoardInfo) -> Void) -> KeyBoardNotifier {
        token[.frameDidChange] = addObserver(UIResponder.keyboardDidChangeFrameNotification, block: frameDidChange)
        return self
    }
    
    @discardableResult
    public func listen(keyBoardWillShow: @escaping (_ info: KeyBoardInfo) -> Void) -> KeyBoardNotifier {
        token[.keyBoardWillShow] = addObserver(UIResponder.keyboardWillShowNotification, block: keyBoardWillShow)
        return self
    }
    
    @discardableResult
    public func listen(keyBoardDidShow: @escaping (_ info: KeyBoardInfo) -> Void) -> KeyBoardNotifier {
        token[.keyBoardDidShow] = addObserver(UIResponder.keyboardDidShowNotification, block: keyBoardDidShow)
        return self
    }
    
    @discardableResult
    public func listen(keyBoardWillHide: @escaping (_ info: KeyBoardInfo) -> Void) -> KeyBoardNotifier {
        token[.keyBoardWillHide] = addObserver(UIResponder.keyboardWillHideNotification, block: keyBoardWillHide)
        return self
    }
    
    @discardableResult
    public func listen(keyBoardDidHid: @escaping (_ info: KeyBoardInfo) -> Void) -> KeyBoardNotifier {
        token[.keyBoardDidHid] = addObserver(UIResponder.keyboardDidHideNotification, block: keyBoardDidHid)
        return self
    }

    /// 添加键盘事件监听通知。
    /// - 通知处理的 block 中无需再判断键盘事件是否由当前 App 产生（已内置判断），但仍需判断是由哪个视图激活键盘事件的，否则会被错误调用。
    ///
    /// - Parameters:
    ///   - name: 键盘监听通知名称
    ///   - block: 收到通知后执行的操作
    ///   - info: KeyBoardInfo 对象
    /// - Returns: 监听 token
    private func addObserver(_ name: NSNotification.Name,
                            block: @escaping (_ info: KeyBoardInfo) -> Void)
        -> NotificationToken
    {
        let notificationDescriptor = NotificationDescriptor<KeyBoardInfo>(name: name, convert: KeyBoardInfo.init)
        let optimizedBlock = { (info: KeyBoardInfo?) in
            if let keyBoardInfo = info, keyBoardInfo.isLocal {
                block(keyBoardInfo)
            }
        }
        let token = NotificationCenter.default.addObserver(descriptor: notificationDescriptor,
                                                           using: optimizedBlock)
        return token
    }
}

/// 键盘通知信息结构体，可明确获取通知的各个属性。
/// - 用法示例：
///
/// ```swift
/// /// 创建通知，并制定通知处理 block。
/// keyboardWillShowNotificationToken = KeyBoardInfo.addObserver(UIResponder.keyboardWillShowNotification) {
///     keyboardInfo in
/// }
/// /// 传统收到通知时的处理方法，keyboardInfo 对象包含了解析后的信息。
/// func keyboardNotify(notification: Notification) {
///     guard let keyboardInfo = KeyBoardInfo(notification) else { return }
///     let keyboardScreenFrame = keyboardInfo.frameEnd
/// }
/// ```
public struct KeyBoardInfo {
    public var animationCurve: UIView.AnimationCurve
    public var animationDuration: Double
    public var isLocal: Bool
    public var frameBegin: CGRect
    public var frameEnd: CGRect
    
    public init?(_ notification: Notification) {
        let name = notification.name
        var userInfo: [AnyHashable : Any]
        switch name {
        case UIResponder.keyboardWillChangeFrameNotification,
             UIResponder.keyboardDidChangeFrameNotification,
             UIResponder.keyboardWillHideNotification,
             UIResponder.keyboardDidHideNotification,
             UIResponder.keyboardWillShowNotification,
             UIResponder.keyboardDidShowNotification:
            if notification.userInfo != nil {
                userInfo = notification.userInfo!
            } else {
                return nil
            }
        default:
            return nil
        }
        
        animationCurve = UIView.AnimationCurve(rawValue: userInfo[UIWindow.keyboardAnimationCurveUserInfoKey] as! Int)!
        animationDuration = userInfo[UIWindow.keyboardAnimationDurationUserInfoKey] as! Double
        isLocal = userInfo[UIWindow.keyboardIsLocalUserInfoKey] as! Bool
        frameBegin = userInfo[UIWindow.keyboardFrameBeginUserInfoKey] as! CGRect
        frameEnd = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as! CGRect
    }
    
}


