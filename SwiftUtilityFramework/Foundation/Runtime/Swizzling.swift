//
//  Swizzling.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-11-6.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import UIKit

// 正常情况不要启用这段代码，仅做示例。
/*
extension UIApplication {

    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }

    private static let runOnce: Void = {
        SwizzlingHelper.SwizzleAllNeededMethod()
    }()
}
*/

public protocol Swizzlable: class {
    static func awake()
}

public class SwizzlingHelper {
    
    public static func SwizzleAllNeededMethod() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let  types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleaseintTypes, Int32(typeCount)) //获取所有的类
        for index in 0 ..< typeCount {
            // 如果该类实现了 Swizzlable 协议，那么就调用 awake 方法
            if let classObject = types[index] as? Swizzlable.Type {
                classObject.awake()
                print("Swizzlable type: \(classObject)")
            }
        }
        types.deallocate()
    }
}

/// 辅助方法，用于交换指定类的方法名对应实现。
public let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    guard
        let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        else { return }
    let originalIMP1 = method_getImplementation(originalMethod)
    let didAddMethod = class_addMethod(forClass,
                                       originalSelector,
                                       method_getImplementation(swizzledMethod),
                                       method_getTypeEncoding(swizzledMethod))
    let originalIMP2 = method_getImplementation(originalMethod)
    if didAddMethod {
        class_replaceMethod(forClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

/// 第二种实现
/*
let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)!
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)!
    

    let originalIMP = method_getImplementation(originalMethod)
    let swizzledIMP = method_getImplementation(swizzledMethod)
    let originalType = method_getTypeEncoding(originalMethod)!
    let swizzledType = method_getTypeEncoding(swizzledMethod)!

    class_replaceMethod(forClass,originalSelector,swizzledIMP,swizzledType)
    class_replaceMethod(forClass,swizzledSelector,originalIMP,originalType)
}
*/

// 使用样例：重写 UIViewController 的 viewDidLoad 方法
/*
extension UIViewController: Swizzlable {

    public static func awake() {
        swizzleMethodOnce
    }

    private static let swizzleMethodOnce: Void = {
        let originalSelector = #selector(viewDidLoad)
        let swizzledSelector = #selector(swizzled_viewDidLoad)
        swizzling(UIViewController.self, originalSelector, swizzledSelector)
    }()
    
    
    @objc func swizzled_viewDidLoad() {
        self.swizzled_viewDidLoad()
        print("ViewDidLoad: \(self).")
    }

}
*/
