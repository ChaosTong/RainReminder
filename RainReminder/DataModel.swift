//
//  DataModel.swift
//  RainReminder
//
//  Created by 童超 on 16/4/8.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

class DataModel{
    var currentCity = ""
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
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-ddHH:mm"
            
            for dailyResult in dailyResults{
                
                let dateString = dailyResult.dailyDate
                let pop = dailyResult.dailyPop
                var max = dailyResult.dailyTmpMax
                max = max.substringToIndex(max.endIndex.predecessor())
                var min = dailyResult.dailyTmpMin
                min = min.substringToIndex(min.endIndex.predecessor())
                
                let stringFormTime = dateString + dueString
                
                guard let notificationTime = formatter.dateFromString(stringFormTime) else{ return }
                
                if pop >= 10 && notificationTime.compare(NSDate()) != .OrderedAscending{
                    
                    let localNotification = UILocalNotification()
                    localNotification.timeZone = NSTimeZone.defaultTimeZone()
                    //localNotification.soundName = "WaterSound.wav"
                    let alertBody = "\(dateString) \(dailyResult.dailyState) 今天下雨几率为 \(pop) 记得带伞☂"
                    localNotification.fireDate = notificationTime
                    localNotification.alertBody = alertBody
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
                if Int(max) >= 30 && notificationTime.compare(NSDate()) != .OrderedAscending{
                    
                    let localNotification = UILocalNotification()
                    localNotification.timeZone = NSTimeZone.defaultTimeZone()
                    //localNotification.soundName = "WaterSound.wav"
                    let alertBody = "\(dateString) \(dailyResult.dailyState) 今天最高气温为 \(max)˚ 记得防晒"
                    localNotification.fireDate = notificationTime
                    localNotification.alertBody = alertBody
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
                if Int(min) <= 10 && notificationTime.compare(NSDate()) != .OrderedAscending{
                    
                    let localNotification = UILocalNotification()
                    localNotification.timeZone = NSTimeZone.defaultTimeZone()
                    //localNotification.soundName = "WaterSound.wav"
                    let alertBody = "\(dateString) \(dailyResult.dailyState) 今天最低气温为 \(min)˚ 记得防寒"
                    localNotification.fireDate = notificationTime
                    localNotification.alertBody = alertBody
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
                
            }
            guard let dataString = dailyResults.last?.dailyDate else{
                return
            }
            let localNotification = UILocalNotification()
            let dueTime = formatter.dateFromString(dataString + dueString)
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            //localNotification.soundName = "WaterSound.wav"
            localNotification.fireDate = dueTime!.dateByAddingTimeInterval(30)
            localNotification.alertBody = "你已经一周没有打开过软件,提醒通知将取消"
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
    
    private func removeLocalNotification(){
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if let allNotifications = allNotifications where !allNotifications.isEmpty{
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    func appendCity(city:City){
        for thisCity in cities{
            if thisCity.cityCN == city.cityCN{
                return
            }
        }
        cities.append(city)
    }
    
    
    private func documentsDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    private func dataFilePath() -> String{
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("DataModel.plist")
    }
    
    func saveData(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(currentCity, forKey: "CurrentCity")
        archiver.encodeObject(dueString, forKey: "DueString")
        archiver.encodeBool(shouldRemind, forKey: "ShouldRemind")
        archiver.encodeObject(cities, forKey: "Cities")
        archiver.encodeObject(dailyResults, forKey: "DailyResults")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
        scheduleNotification()
    }
    
    func loadData(){
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            if let data = NSData(contentsOfFile: path){
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                currentCity = unarchiver.decodeObjectForKey("CurrentCity") as! String
                dueString = unarchiver.decodeObjectForKey("DueString") as! String
                shouldRemind = unarchiver.decodeBoolForKey("ShouldRemind")
                cities = unarchiver.decodeObjectForKey("Cities") as! [City]
                dailyResults = unarchiver.decodeObjectForKey("DailyResults") as! [DailyResult]
                unarchiver.finishDecoding()
            }
        }
    }
    
    //
    func handleFirstTime(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.registerDefaults(["FirstTime":true])
        userDefaults.registerDefaults(["IsOldData":true])
        userDefaults.registerDefaults(["Notify":false])
        
        userDefaults.setBool(false, forKey: "Notify")
        userDefaults.synchronize()
        
        let isOldData = userDefaults.boolForKey("IsOldData")
        if isOldData{
            let fileMager = NSFileManager()
            do{
                try fileMager.removeItemAtPath(dataFilePath())
            }catch{
                print("FirstTime")
            }
            userDefaults.setBool(false, forKey: "IsOldData")
            userDefaults.synchronize()
        }
    }
    
}
