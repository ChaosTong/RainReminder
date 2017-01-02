//
//  DataModel.swift
//  RainReminder
//
//  Created by 童超 on 16/4/8.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class DataModel{
    var currentCity = ""
    var currentCode = ""
    var currentTmp = ""
    var dueString = "__ : __"
    var shouldRemind = false
    var cities = [City]()
    var dailyResults = [DailyResult]()
    
    init(){
        handleFirstTime()
        loadData()
    }
    
    func scheduleNotification(){
        
        removeLocalNotification()
        
        if shouldRemind && currentCity != ""{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-ddHH:mm"
            
            for dailyResult in dailyResults{
                
                let dateString = dailyResult.dailyDate
                let pop = dailyResult.dailyPop
                var max = dailyResult.dailyTmpMax
                max = max.substring(to: max.characters.index(before: max.endIndex))
                var min = dailyResult.dailyTmpMin
                min = min.substring(to: min.characters.index(before: min.endIndex))
                
                let stringFormTime = dateString + dueString
                
                guard let notificationTime = formatter.date(from: stringFormTime) else{ return }
                
                if pop >= 10 && notificationTime.compare(Date()) != .orderedAscending{
                    
                    let localNotification = UILocalNotification()
                    localNotification.timeZone = TimeZone.current
                    //localNotification.soundName = "WaterSound.wav"
                    let alertBody = "\(dateString) \(dailyResult.dailyState) 今天下雨几率为 \(pop) 记得带伞☂"
                    localNotification.fireDate = notificationTime
                    localNotification.alertBody = alertBody
                    UIApplication.shared.scheduleLocalNotification(localNotification)
                }
                if Int(max) >= 30 && notificationTime.compare(Date()) != .orderedAscending{
                    
                    let localNotification = UILocalNotification()
                    localNotification.timeZone = TimeZone.current
                    //localNotification.soundName = "WaterSound.wav"
                    let alertBody = "\(dateString) \(dailyResult.dailyState) 今天最高气温为 \(max)˚ 记得防晒"
                    localNotification.fireDate = notificationTime
                    localNotification.alertBody = alertBody
                    UIApplication.shared.scheduleLocalNotification(localNotification)
                }
                if Int(min) <= 10 && notificationTime.compare(Date()) != .orderedAscending{
                    
                    let localNotification = UILocalNotification()
                    localNotification.timeZone = TimeZone.current
                    //localNotification.soundName = "WaterSound.wav"
                    let alertBody = "\(dateString) \(dailyResult.dailyState) 今天最低气温为 \(min)˚ 记得防寒"
                    localNotification.fireDate = notificationTime
                    localNotification.alertBody = alertBody
                    UIApplication.shared.scheduleLocalNotification(localNotification)
                }
                
            }
            guard let dataString = dailyResults.last?.dailyDate else{
                return
            }
            let localNotification = UILocalNotification()
            let dueTime = formatter.date(from: dataString + dueString)
            localNotification.timeZone = TimeZone.current
            //localNotification.soundName = "WaterSound.wav"
            localNotification.fireDate = dueTime!.addingTimeInterval(30)
            localNotification.alertBody = "你已经一周没有打开过软件,提醒通知将取消"
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    
    fileprivate func removeLocalNotification(){
        let allNotifications = UIApplication.shared.scheduledLocalNotifications
        if let allNotifications = allNotifications, !allNotifications.isEmpty{
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
    func appendCity(_ city:City){
        for thisCity in cities{
            if thisCity.cityCN == city.cityCN{
                return
            }
        }
        cities.append(city)
    }
    
    
    fileprivate func documentsDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    fileprivate func dataFilePath() -> String{
        return (documentsDirectory() as NSString).appendingPathComponent("DataModel.plist")
    }
    
    func saveData(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(currentTmp, forKey: "CurrentTmp")
        archiver.encode(currentCode, forKey: "CurrentCode")
        archiver.encode(currentCity, forKey: "CurrentCity")
        archiver.encode(dueString, forKey: "DueString")
        archiver.encode(shouldRemind, forKey: "ShouldRemind")
        archiver.encode(cities, forKey: "Cities")
        archiver.encode(dailyResults, forKey: "DailyResults")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
        scheduleNotification()
    }
    
    func loadData(){
        let path = dataFilePath()
        if FileManager.default.fileExists(atPath: path){
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                currentTmp = unarchiver.decodeObject(forKey: "CurrentTmp") as! String
                currentCode = unarchiver.decodeObject(forKey: "CurrentCode") as! String
                currentCity = unarchiver.decodeObject(forKey: "CurrentCity") as! String
                dueString = unarchiver.decodeObject(forKey: "DueString") as! String
                shouldRemind = unarchiver.decodeBool(forKey: "ShouldRemind")
                cities = unarchiver.decodeObject(forKey: "Cities") as! [City]
                dailyResults = unarchiver.decodeObject(forKey: "DailyResults") as! [DailyResult]
                unarchiver.finishDecoding()
            }
        }
    }
    
    //
    func handleFirstTime(){
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: ["FirstTime":true])
        userDefaults.register(defaults: ["IsOldData":true])
        userDefaults.register(defaults: ["Notify":false])
        
        userDefaults.set(false, forKey: "Notify")
        userDefaults.synchronize()
        
        let isOldData = userDefaults.bool(forKey: "IsOldData")
        if isOldData{
            let fileMager = FileManager()
            do{
                try fileMager.removeItem(atPath: dataFilePath())
            }catch{
                print("FirstTime")
            }
            userDefaults.set(false, forKey: "IsOldData")
            userDefaults.synchronize()
        }
    }
    
}
