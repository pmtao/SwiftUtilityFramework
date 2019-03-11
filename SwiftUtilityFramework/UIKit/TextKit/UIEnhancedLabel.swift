//
//  UIEnhancedLabel.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-5-22.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import UIKit

/// 加强版 UILabel，支持特性：
/// - 设置垂直对齐：上、中、下
public class UIEnhancedLabel: UILabel {
    /// 垂直对齐方向
    public var verticalAlignment: VerticalDirections = .middle {
        didSet {
            if oldValue != verticalAlignment {
                self.setNeedsDisplay()
            }
        }
    }
    
    /// 垂直对齐方向
    public enum VerticalDirections {
        case top
        case middle
        case bottom
    }
    
    /// 调整文本绘制的位置
    override public func textRect(forBounds bounds: CGRect,
                                  limitedToNumberOfLines numberOfLines: Int) -> CGRect
    {
        var textRect = super.textRect(forBounds: bounds,
                                      limitedToNumberOfLines: numberOfLines)
        switch verticalAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .bottom:
            textRect.origin.y =
                bounds.origin.y + bounds.size.height - textRect.size.height
        case .middle:
            textRect.origin.y =
                bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0
        }
        
        return textRect
    }
    
    /// 按照文本设置的位置进行绘制
    override public func drawText(in rect: CGRect) {
        let textRect = self.textRect(forBounds: rect,
                                     limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: textRect)
    }
}
