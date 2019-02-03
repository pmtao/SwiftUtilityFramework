//
//  UIView+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-7-25.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import UIKit

/// 创建 mask 时可以使用此类创建 layer
public final class ShapeLayerView: UIView {
    public var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }
    
    override public class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
}

/// 本扩展提供 UIView 的基本特效，如圆角、阴影等。
extension UIView {
    
    
    /// 添加圆角效果（需要辅助类 ShapeLayerView），参考自：https://forums.developer.apple.com/thread/80888
    public func setCornerRadius(radius: CGFloat,
                                corner: UIRectCorner,
                                borderWidth: CGFloat = 0,
                                borderColor: UIColor = UIColor.clear)
    {
        let  maskPath: UIBezierPath = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corner,
            cornerRadii: CGSize(width: radius, height: radius))
        
        let maskView = ShapeLayerView(frame: self.bounds)
        maskView.shapeLayer.path = maskPath.cgPath
//        maskView.shapeLayer.fillColor = UIColor.white.cgColor
        
        self.mask = maskView
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
}
