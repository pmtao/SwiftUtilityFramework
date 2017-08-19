//
//  Class.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-8-18.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit


/// 栈对象，可放入任意类型对象，后进栈的永远在栈首，后进先出，通过数组实现。
public class Stack<Element> {
    
    /// 是否为空
    public var isEmpty: Bool { return stack.isEmpty }
    /// 栈的大小
    public var size: Int { return stack.count }
    /// 栈顶元素
    public var peek: Element? {
        return stack.last
    }
    
    private var stack: [Element]
    
    /// 构造函数
    public init() {
        stack = [Element] ()
    }
    
    /// 加入一个新元素
    public func push(_ obj: Element) {
        stack.append(obj)
    }
    
    /// 推出栈顶元素
    public func pop() -> Element? {
        if isEmpty {
            return nil
        } else {
            return stack.removeLast()
        }
    }
    
    /// 如果栈中的元素是字符串，则将栈中的元素打印输出至一个完整字符串
    ///
    /// - Returns: 输出字符串，如果元素不是字符串类型，则为 nil。
    public static func printStack(stack: Stack<String>) -> String? {
        var unit = stack.pop() // 推出元素
        var printString = "Stack top from here:"
        
        if unit == nil {
            return nil
        } else {
            while unit != nil {
                printString += ("  " + unit!)
                unit = stack.pop()
            }
        }
        return printString
    }
}


/// 队列对象，可放入任意类型对象，先进入队列的永远在队首，先进先出，通过数组实现。
public class Queue<Element> {
    
    /// 是否为空
    public var isEmpty: Bool { return queue.isEmpty }
    /// 队列大小
    public var size: Int { return queue.count }
    /// 队列首元素
    public var peek: Element? {
        return queue.first
    }
    
    private var queue: [Element]
    
    /// 构造函数
    public init() {
        queue = [Element]()
    }
    
    /// 加入新元素
    public func enqueue(_ obj: Element) {
        queue.append(obj)
    }
    
    /// 推出队列元素
    public func dequeue() -> Element? {
        if isEmpty {
            return nil
        } else {
            return queue.removeFirst()
        }
    }
    
    
    /// 如果队列中的元素是字符串，则将队列中的元素打印输出至一个完整字符串
    ///
    /// - Returns: 输出字符串，如果元素不是字符串类型，则为 nil。
    public static func printQueue(queue: Queue<String>) -> String? {
        var unit = queue.dequeue() // 推出元素
        var printString = "Queue start from here:"
        
        if unit == nil {
            return nil
        } else {
            while unit != nil {
                printString += ("  " + unit!)
                unit = queue.dequeue()
            }
        }
        return printString
    }
    
}

