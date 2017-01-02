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
    var tempNow = ""
    
    fileprivate func documentsDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    fileprivate func dataFilePath() -> String{
        return (documentsDirectory() as NSString).appendingPathComponent("WeatherModel.plist")
    }
    
    func saveData(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(city, forKey: "city")
        archiver.encode(state, forKey: "state")
        archiver.encode(dayRain, forKey: "dayRain")
        archiver.encode(dayTemMax, forKey: "dayTemMax")
        archiver.encode(dayTmpMin, forKey: "dayTmpMin")
        archiver.encode(dailyResults, forKey: "DailyResults")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    func loadData(){
        let path = dataFilePath()
        if FileManager.default.fileExists(atPath: path){
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                city = unarchiver.decodeObject(forKey: "city") as! String
                state = unarchiver.decodeObject(forKey: "state") as! String
                dayRain = unarchiver.decodeObject(forKey: "dayRain") as! String
                dayTemMax = unarchiver.decodeObject(forKey: "dayTemMax") as! String
                dayTmpMin = unarchiver.decodeObject(forKey: "dayTmpMin") as! String
                dailyResults = unarchiver.decodeObject(forKey: "DailyResults") as! [DailyResult]
                unarchiver.finishDecoding()
            }
        }
    }
}

