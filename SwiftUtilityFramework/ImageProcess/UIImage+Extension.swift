//
//  UIImage+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-12-25.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit


extension UIImage {
    
    /// 根据指定颜色的 hex 值，生成对应图片
    ///
    /// - Parameters:
    ///   - rgb: hex 类型代表的颜色值（0x000000~0xffffff）
    ///   - a: alpha 值（0x00~0xff）
    /// - Returns: 生成的 UIImage 对象
    static public func SUF_makeColorImage(rgb: Int, a: Int = 0xFF) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor(rgb: rgb, a: a).cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 生成纯色图片
    /// - Parameters:
    ///   - fromColor: 图片颜色
    ///   - size: 图片尺寸
    public convenience init?(fromColor color: UIColor, size: CGSize) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
    
    /// 将 UIView 转换为图片.
    /// 修改自代码：https://github.com/melvitax/ImageHelper
    public convenience init?(fromView view: UIView) {
        // 原代码为 UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        // scale 参数为 0，会带来一个问题，图片像素会再叠加设备的缩放比例，因此改为 1，保持原图片像素。
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 1)
        //view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
    
    /// 裁剪图片.
    /// 修改自代码：https://github.com/melvitax/ImageHelper
    public func crop(bounds: CGRect) -> UIImage? {
        return UIImage(cgImage: (self.cgImage?.cropping(to: bounds)!)!,
                       scale: 0.0, orientation: self.imageOrientation)
    }
    
    /// 生成包含透明边距的新图片.
    /// 修改自代码：https://github.com/melvitax/ImageHelper
    public func apply(padding: CGFloat) -> UIImage? {
        // If the image does not have an alpha layer, add one
        let image = self.applyAlpha()
        if image == nil {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: size.width + padding * 2, height: size.height + padding * 2)
        
        // Build a context that's the same dimensions as the new size
        let colorSpace = self.cgImage?.colorSpace
        let bitmapInfo = self.cgImage?.bitmapInfo
        let bitsPerComponent = self.cgImage?.bitsPerComponent
        let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: bitsPerComponent!, bytesPerRow: 0, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        
        // Draw the image in the center of the context, leaving a gap around the edges
        let imageLocation = CGRect(x: padding, y: padding, width: image!.size.width, height: image!.size.height)
        context?.draw(self.cgImage!, in: imageLocation)
        
        // Create a mask to make the border transparent, and combine it with the image
        let transparentImage = UIImage(cgImage: (context?.makeImage()?.masking(imageRef(withPadding: padding, size: rect.size))!)!)
        return transparentImage
    }
    
    /// 给图片附加 alpha 值（如果已有则不变）.
    /// 修改自代码：https://github.com/melvitax/ImageHelper
    public func applyAlpha() -> UIImage? {
        if hasAlpha {
            return self
        }
        
        let imageRef = self.cgImage;
        let width = imageRef?.width;
        let height = imageRef?.height;
        let colorSpace = imageRef?.colorSpace
        
        // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let offscreenContext = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
        
        // Draw the image into the context and retrieve the new image, which will now have an alpha layer
        let rect: CGRect = CGRect(x: 0, y: 0, width: CGFloat(width!), height: CGFloat(height!))
        offscreenContext?.draw(imageRef!, in: rect)
        let imageWithAlpha = UIImage(cgImage: (offscreenContext?.makeImage()!)!)
        return imageWithAlpha
    }
    
    /// 测试图片是否包含 alpha 图层.
    /// 修改自代码：https://github.com/melvitax/ImageHelper
    public var hasAlpha: Bool {
        let alpha: CGImageAlphaInfo = self.cgImage!.alphaInfo
        switch alpha {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        default:
            return false
        }
    }
    
    /**
     Creates a mask that makes the outer edges transparent and everything else opaque. The size must include the entire mask (opaque part + transparent border).
     
     - Parameter padding: The padding amount.
     - Parameter size: The size of the image.
     
     - Returns A Core Graphics Image Ref
     */
    /// 源代码：https://github.com/melvitax/ImageHelper
    fileprivate func imageRef(withPadding padding: CGFloat, size: CGSize) -> CGImage {
        // Build a context that's the same dimensions as the new size
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        // Start with a mask that's entirely transparent
        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Make the inner part (within the border) opaque
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(x: padding, y: padding, width: size.width - padding * 2, height: size.height - padding * 2))
        
        // Get an image of the context
        let maskImageRef = context?.makeImage()
        return maskImageRef!
    }
    
    /// 平面 4 个方向枚举
    public enum FlatDirection: String {
        case left
        case right
        case top
        case bottom
    }
    
    /// 合并两张图片
    ///
    /// - Parameters:
    ///   - image: 待合并的另一张图片
    ///   - direction: 另一张图片相对于当前图片的位置
    /// - Returns: 合并后的图片
    public func combine(with image: UIImage, at direction: FlatDirection) -> UIImage? {
        switch direction {
        case .left, .right:
            if self.size.height == image.size.height {
                let size = CGSize(width: self.size.width + image.size.width,
                                  height: self.size.height)
                UIGraphicsBeginImageContext(size)
                if direction == .left {
                    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                    self.draw(in: CGRect(x: image.size.width, y: 0, width: self.size.width, height: self.size.height))
                } else {
                    self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                    image.draw(in: CGRect(x: self.size.width, y: 0, width: image.size.width, height: image.size.height))
                }
                let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return combinedImage
            } else {
                return nil
            }
        case .top, .bottom:
            if self.size.width == image.size.width {
                let size = CGSize(width: self.size.width,
                                  height: self.size.height + image.size.height)
                UIGraphicsBeginImageContext(size)
                if direction == .top {
                    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                    self.draw(in: CGRect(x: 0, y: image.size.height, width: self.size.width, height: self.size.height))
                } else {
                    self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                    image.draw(in: CGRect(x: 0, y: self.size.height, width: image.size.width, height: image.size.height))
                }
                let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return combinedImage
            } else {
                return nil
            }
        }
    }
}
