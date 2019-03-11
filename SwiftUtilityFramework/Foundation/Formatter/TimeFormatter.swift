//
//  TimeFormatter.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-10-17.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import Foundation

public enum DateFormatType: String {
    case YYYYMd = "YYYY-M-d"
}

extension Date {
    public func getDateWithFormat(_ formatType: DateFormatType) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatType.rawValue
        let formattedDate = dateformatter.string(from: self)
        return formattedDate
    }
}
