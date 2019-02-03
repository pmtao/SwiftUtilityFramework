//
//  UIScrollView+Polyfill.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-10-25.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    public var contentInset_Polyfill: UIEdgeInsets {
        get {
            if #available(iOS 11, *) {
                return adjustedContentInset
            } else {
                return contentInset
            }
        }
    }
}
