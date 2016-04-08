//
//  WeatherResult.swift
//  RainReminder
//
//  Created by 童超 on 16/4/7.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation

class WeatherResult {
    var city = ""
    var state = ""
    var dayRain = ""
    var dayTemMax = ""
    var dayTmpMin = ""
    var stateCode = 0
    var dailyResults = [DailyResult]()
    var ServiceStatus = ""
    
    private func documentsDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    private func dataFilePath() -> String{
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("WeatherModel.plist")
    }
    
    func saveData(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(city, forKey: "city")
        archiver.encodeObject(state, forKey: "state")
        archiver.encodeObject(dayRain, forKey: "dayRain")
        archiver.encodeObject(dayTemMax, forKey: "dayTemMax")
        archiver.encodeObject(dayTmpMin, forKey: "dayTmpMin")
        archiver.encodeObject(dailyResults, forKey: "DailyResults")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadData(){
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            if let data = NSData(contentsOfFile: path){
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                city = unarchiver.decodeObjectForKey("city") as! String
                state = unarchiver.decodeObjectForKey("state") as! String
                dayRain = unarchiver.decodeObjectForKey("dayRain") as! String
                dayTemMax = unarchiver.decodeObjectForKey("dayTemMax") as! String
                dayTmpMin = unarchiver.decodeObjectForKey("dayTmpMin") as! String
                dailyResults = unarchiver.decodeObjectForKey("DailyResults") as! [DailyResult]
                unarchiver.finishDecoding()
            }
        }
    }
}

