//
//  TypedNotification.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/2/27.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

/// 指定通知信息类型的通知监听与处理
/// 用法示例
/*
 // 创建一个结构体 KeyBoardInfo，用于解析键盘通知的具体信息。
 let keyBoardNotification = NotificationDescriptor<KeyBoardInfo>(name: UIResponder.keyboardWillShowNotification, convert: KeyBoardInfo.init)
 
 // 创建监听，并提供收到通知时执行的操作，监听和处理放在一起便于管理，在合适处保存 token 即可，当观察者消失时，监听会自动移除。
 var token: NotificationToken? = center.addObserver(descriptor: keyBoardNotification) {
     (info: KeyBoardInfo?) in
     // 处理键盘事件 ...
 }
 */

private let center = NotificationCenter.default

public struct NotificationDescriptor<A> {
    public let name: Notification.Name
    public let convert: (Notification) -> A?
    
    public init(name: Notification.Name,
                convert: @escaping (Notification) -> A?) {
        self.name = name
        self.convert = convert
    }
}

public class NotificationToken {
    let token: NSObjectProtocol
    let center: NotificationCenter
    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}

extension NotificationCenter {
    public func addObserver<A>(descriptor: NotificationDescriptor<A>,
                               using block: @escaping (A?) -> ()) -> NotificationToken {
        let token = addObserver(forName: descriptor.name, object: nil, queue: nil, using: { note in
            block(descriptor.convert(note))
        })
        return NotificationToken(token: token, center: self)
    }
}


