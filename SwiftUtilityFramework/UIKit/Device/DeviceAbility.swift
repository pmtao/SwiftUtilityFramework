//
//  DeviceAbility.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-8-16.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit
import Speech

/// 封装三种物理震动反馈
///
/// - Parameters:
///   - feedBackType: 三种反馈方式: "impact", "select", "notify"
///   - strength: 三种力度: 0, 1, 2
public func SUF_impactFeedBack(feedBackType: String = "impact", strength: Int = 0) {
    //    print("feedBackType: \(feedBackType), strength: \(strength)")
    let modelName = UIDevice.current.SUF_modelName //硬件型号名称
    
    //iPhone 7 专用震动模式
    if modelName == "iPhone 7" || modelName == "iPhone 7 Plus" {
        if #available(iOS 10.0, *) {
            let impactFeedBack: UIImpactFeedbackGenerator
            let selectFeedBack: UISelectionFeedbackGenerator
            let notifyFeedBack: UINotificationFeedbackGenerator
            
            switch feedBackType {
            case "impact":
                if let style = UIImpactFeedbackGenerator.FeedbackStyle(rawValue: strength) {
                    impactFeedBack = UIImpactFeedbackGenerator(style: style)
                    impactFeedBack.impactOccurred()
                }
            case "select":
                selectFeedBack = UISelectionFeedbackGenerator()
                selectFeedBack.selectionChanged()
            case "notify":
                if let style = UINotificationFeedbackGenerator.FeedbackType(rawValue: strength) {
                    notifyFeedBack = UINotificationFeedbackGenerator()
                    notifyFeedBack.notificationOccurred(style)
                }
            default:
                return
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
        
        //iPhone 6s 专用模式
    else if modelName == "iPhone 6s" || modelName == "iPhone 6s Plus" {
        switch strength {
        case 0:
            AudioServicesPlaySystemSound(1519)
        case 1:
            AudioServicesPlaySystemSound(1520)
        case 2:
            AudioServicesPlaySystemSound(1521)
        default:
            AudioServicesPlaySystemSound(1519)
        }
    }
        
    else {
        //iphone 6 以下型号使用普通震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
}



/// 播放指定音频文件
///
/// - Parameter fileNameFromMainBundle: 文件名（默认在 MainBundle 中）
public func SUF_playSound(fileNameFromMainBundle: String) {
    var soundID: SystemSoundID = 0
    //NSBundle来返回音频文件路径
    let soundFilePath = Bundle.main.path(
        forResource: fileNameFromMainBundle,
        ofType: "m4a")
    //建立SystemSoundID对象，但是这里要传地址(加&符号)。 第一个参数需要一个CFURLRef类型的url参数，要新建一个NSString来做桥接转换(bridge)，而这个NSString的值，就是上面的音频文件路径
    let soundFile = NSURL(fileURLWithPath: soundFilePath!)
    AudioServicesCreateSystemSoundID(soundFile, &soundID)
    //播放提示音 带震动
    //    AudioServicesPlayAlertSound(soundID)
    //播放系统声音
    AudioServicesPlaySystemSound(soundID)
}

public extension UIDevice {
    /// UIDevice 属性：获取设备的硬件型号，使用方法：UIDevice.current.SUF_modelName
    var SUF_modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":         return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                    return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                    return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                    return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1":                               return "iPhone 7" //"iPhone 7 (CDMA)"
        case "iPhone9,3":                               return "iPhone 7" //"iPhone 7 (GSM)"
        case "iPhone9,2":                               return "iPhone 7 Plus" //"iPhone 7 Plus (CDMA)"
        case "iPhone9,4":                               return "iPhone 7 Plus" //"iPhone 7 Plus (GSM)"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

