//
//  LinkList.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2018/11/19.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation


public class SingleLinkedNode<T: Equatable> {
    var value: T
    var next: SingleLinkedNode<T>?
    //    weak var previous: Node<T>?
    
    init(_ value: T) {
        self.value = value
    }
}

extension SingleLinkedNode: Equatable {
    public static func == (lhs: SingleLinkedNode, rhs: SingleLinkedNode) -> Bool {
        return lhs.value == rhs.value
    }
    
}

public class SingleLinkedList<T: Equatable> {
    var head: SingleLinkedNode<T>?
    var tail: SingleLinkedNode<T>?
    
    init(_ values: [T]) {
        guard !values.isEmpty else { return }
        let dummy = SingleLinkedNode<T>(values[0])
        var pointer: SingleLinkedNode<T>? = dummy
        head = pointer
        for value in values {
            pointer?.next = SingleLinkedNode<T>(value)
            pointer = pointer?.next
        }
        tail = pointer
        head = head?.next
    }
    
    init() {
        head = nil
        tail = nil
    }
    
    var isListEmpty: Bool {
        if head == nil || tail == nil {
            return true
        } else {
            return false
        }
    }
    
    func addToTail(_ value: T) -> SingleLinkedNode<T> {
        let newNode = SingleLinkedNode<T>(value)
        if isListEmpty {
            tail = newNode
            head = tail
        } else {
            tail?.next = newNode
            tail = tail?.next
        }
        return newNode
    }
    
    func addToHead(_ value: T) -> SingleLinkedNode<T> {
        let newNode = SingleLinkedNode<T>(value)
        if isListEmpty {
            head = newNode
            tail = head
        } else {
            newNode.next = head
            head = newNode
        }
        return newNode
    }
    
    func inset(_ newNode: SingleLinkedNode<T>, after node: SingleLinkedNode<T>) {
        if node.next == nil {
            node.next = newNode
            newNode.next = nil
        } else {
            newNode.next = node.next
            node.next = newNode
        }
    }

    func reverse() -> SingleLinkedList<T> {
        let reversedList = SingleLinkedList<T>()
        var pointer = self.head
        while(pointer != nil) {
            _ = reversedList.addToHead(pointer!.value)
            pointer = pointer?.next
        }
        return reversedList
    }
    
    
}

extension SingleLinkedList: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        var des = ""
        var pointer = self.head
        while pointer != nil {
            if pointer?.next != nil {
                des = des + pointer!.value.description + ", "
            } else {
                des = des + pointer!.value.description
            }
            pointer = pointer?.next
        }
        return des
    }
}

/// This method changed the structure of the link, need to be fixed.
public func isWordPalindrome(_ word: SingleLinkedList<Character>) -> Bool {
    if word.isListEmpty {
        return false
    }
    if word.head?.next == nil {
        return false
    }
    var fastPointer = word.head!.next
    var slowPointer = word.head
    let prevReversedList = SingleLinkedList<Character>()
    var isWordHasOddLength = true
    
    while(fastPointer != nil) {
        _ = prevReversedList.addToHead(slowPointer!.value)
        word.head = word.head?.next
        slowPointer = word.head
        if fastPointer?.next == nil {
            isWordHasOddLength = false
        }
        fastPointer = fastPointer?.next?.next
    }
    if isWordHasOddLength {
        word.head = word.head?.next
        slowPointer = word.head
    }
    var reversedListPointer = prevReversedList.head
    var twoListCompareResult = true
    while(slowPointer?.next != nil) {
        if slowPointer?.value != reversedListPointer?.value {
            twoListCompareResult = false
            break
        } else {
            slowPointer = slowPointer?.next
            reversedListPointer = reversedListPointer?.next
        }
    }
    
    return twoListCompareResult
}

public func linkListLoopCheck<T>(_ linkList: SingleLinkedList<T>) -> Bool {
    var checkResult = false
    // 待完善
    
    
    return checkResult
}


// MARK:-

public class DoubleLinkedNode<T: Equatable> {
    var value: T
    var previous: DoubleLinkedNode<T>?
    var next: DoubleLinkedNode<T>?
    //    weak var previous: Node<T>?
    
    init(_ value: T) {
        self.value = value
    }
}

extension DoubleLinkedNode: Equatable {
    public static func == (lhs: DoubleLinkedNode, rhs: DoubleLinkedNode) -> Bool {
        return lhs.value == rhs.value
    }
    
}
