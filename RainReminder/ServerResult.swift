//
//  ServerResult.swift
//  RainReminder
//
//  Created by 童超 on 16/4/7.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation
import Alamofire

class ServerResult {
    
    //https://api.heweather.com/x3/weather?cityid=CN101020100&key=04f6c6c770d94aee8f738758a829d826
    let BaseURL = "https://api.heweather.com/x3/weather"
    let key = "04f6c6c770d94aee8f738758a829d826"
    var weatherResult = WeatherResult()
    
    func performResult() {
        parseWeatherData()
    }
    
    fileprivate func parseWeatherData() -> WeatherResult {
 
        let params:[String: AnyObject] = ["cityid": "CN101020100" as AnyObject,"key": key as AnyObject]
        
//        Alamofire.request(.GET, BaseURL, parameters: params).responseJSON {
        Alamofire.request(BaseURL, method: .get, parameters: params, encoding: JSONEncoding.default).responseJSON {
            response in

            guard response.result.error == nil, let dat = response.result.value else {
                print(response.result)
                return
            }

                let json = JSON(dat)
                let data = json["HeWeather data service 3.0"][0]
                let status = data["status"].stringValue
                let city = data["basic"]["city"].stringValue
                if status == "ok" {
                
                if let ServiceState = data["status"].string{
                    self.weatherResult.ServiceStatus = ServiceState
                }
                
                if let jsonCity = data["basic"]["city"].string{
                    self.weatherResult.city = jsonCity
                }
                if let state = data["now"]["cond"]["txt"].string{
                    self.weatherResult.state = state
                }
                if let stateCode = data["now"]["cond"]["code"].string{
                    self.weatherResult.stateCode = Int(stateCode)!
                }
                
                let dailyArrays = data["daily_forecast"]
                let dailyDayTmp = dailyArrays[0]["tmp"]
                if let pop = dailyArrays[0]["pop"].string{
                    self.weatherResult.dayRain = pop
                }
                if let dayTemMax = dailyDayTmp["max"].string{
                    self.weatherResult.dayTemMax = dayTemMax + "˚"
                }
                if let dayTmpMin = dailyDayTmp["min"].string{
                    self.weatherResult.dayTmpMin = dayTmpMin + "˚"
                }

                for (_,subJson):(String, JSON) in data["daily_forecast"]{
                    let dailyResult = DailyResult()
                    
                    if let dates = subJson["date"].string{
                        dailyResult.dailyDate = dates
                    }
                    if let pop = subJson["pop"].string{
                        dailyResult.dailyPop = Int(pop)!
                    }
                    if let tmpsMax = subJson["tmp"]["max"].string{
                        dailyResult.dailyTmpMax = tmpsMax + "˚"
                    }
                    if let tmpsMin = subJson["tmp"]["min"].string{
                        dailyResult.dailyTmpMin = tmpsMin + "˚"
                    }
                    if let conds = subJson["cond"]["txt_d"].string{
                        dailyResult.dailyState = conds
                    }
                    if let stateCode = subJson["cond"]["code_d"].string{
                        dailyResult.dailyStateCode = Int(stateCode)!
                    }
                    self.weatherResult.dailyResults.append(dailyResult)
                }
                    let dataModel = DataModel()
                    dataModel.dailyResults = self.weatherResult.dailyResults
                    dataModel.currentCity = city
                    dataModel.saveData()
                }
            
        }
        return self.weatherResult
    }
}
