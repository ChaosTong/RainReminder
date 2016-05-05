//
//  NSDate+WeatherDate.swift
//  RainReminder
//
//  Created by 童超 on 16/5/5.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation

extension NSDate {
    /// 从微博服务端字符串获取日期
    class func dateFromeWeiboDateStr(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = NSLocale(localeIdentifier: "en")
        return dateFormatter.dateFromString(dateString)!
    }
    /// 返回日期的描述文字，1分钟内：刚刚，1小时内：xx分钟前，1天内：HH:mm，昨天：昨天 HH:mm，1年内：MM-dd HH:mm，更早时间：yyyy-MM-dd HH:mm
    func weiboDescriptionDate() -> String {
        let calendar = NSCalendar.currentCalendar()
        var dateFormat = "HH:mm"
        // 如果是一天之内
        if calendar.isDateInToday(self) {
            let since = NSDate().timeIntervalSinceDate(self)
            //一分钟内
            if since < 60.0 {
                return "刚刚"
            }
            if since < 3600.0 {
                return "\(Int(since/60))分钟前"
            }
            return "\(Int(since/3600.0))小时前"
        }
        // 如果是昨天
        if calendar.isDateInYesterday(self) {
            dateFormat = "昨天 " + dateFormat
        } else {
            dateFormat = "MM-dd " + dateFormat
            let component = calendar.components([NSCalendarUnit.Year], fromDate: self, toDate: NSDate(), options: [])
            if component.year > 1 {
                dateFormat = "yyyy-" + dateFormat
            }
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = NSLocale(localeIdentifier: "en")
        return dateFormatter.stringFromDate(self)
    }
}

