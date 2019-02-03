//
//  ExceptionLog.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/1/19.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

// https://www.jianshu.com/p/09b6084bcd01
public class CrashReport {

    static var logFileDirectory = ""
    
    public static func catchCrashLogs() {
        NSSetUncaughtExceptionHandler { (exception) in
            let callStackSymbols = exception.callStackSymbols
            let reason = exception.reason ?? ""
            let name = exception.name.rawValue
            let exceptionReport = [
                "appException":
                    ["exceptioncallStachSymbols": callStackSymbols,
                     "exceptionreason": reason,
                     "exceptionname": name]
            ]
            _ = CrashReport.writeCrashFileOnDocumentsException(exceptionReport)
        }
    }
    
    public static func getCachesPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    
    public static func writeCrashFileOnDocumentsException(_ exception: [String: Any]) -> Bool {
        let time = getFormatedDateString()
        var isSuccess = false
        let infoDictionary = Bundle.main.infoDictionary!
        let crashFileName = time + "_" + (infoDictionary["CFBundleName"] as! String) + "Crashlog.plist"
        let crashFilePath = (getCachesPath() as NSString).appendingPathComponent(logFileDirectory)
        let fileManager = FileManager.default
        var deviceInfo = [String:Any]()
        deviceInfo["PlatformVersion"] = infoDictionary["DTPlatformVersion"]
        deviceInfo["CFBundleShortVersionString"] = infoDictionary["CFBundleShortVersionString"]
        deviceInfo["UIRequiredDeviceCapabilities"] = infoDictionary["UIRequiredDeviceCapabilities"]
        
        do {
            try fileManager.createDirectory(atPath: crashFilePath, withIntermediateDirectories: true, attributes: nil)
            isSuccess = true
        } catch {
            print("failed to createDirectory:\(error)")
        }
        if isSuccess {
            let filepath = (crashFilePath as NSString).appendingPathComponent(crashFileName)
            let infos: NSDictionary = ["Exception":exception,
                         "DeviceInfo":deviceInfo]
            let logs = (NSMutableDictionary(contentsOfFile: filepath) ?? NSMutableDictionary())
            logs.setObject(infos, forKey: "\(infoDictionary["CFBundleName"] as! String)_crashLogs" as NSString)
            let writeOK = logs.write(toFile: filepath, atomically: true)
            return writeOK
        } else {
            return false
        }
    }
    
    
    public static func getFormatedDateString() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        format.locale = Locale.current
        return format.string(from: Date())
    }
    
}
