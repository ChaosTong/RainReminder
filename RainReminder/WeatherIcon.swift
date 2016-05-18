//
//  WeatherIcon.swift
//  EasyulifeWeather
//
//  Created by 童超 on 16/1/19.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation

struct WeatherIcon {
    let iconText: String
    
    enum IconType : String, CustomStringConvertible {
        case day100 = "100"
        case day101 = "101"
        case day102 = "102"
        case day103 = "103"
        case day104 = "104"
        case day200 = "200"
        case day201 = "201"
        case day202 = "202"
        case day203 = "203"
        case day204 = "204"
        case day205 = "205"
        case day206 = "206"
        case day207 = "207"
        case day208 = "208"
        case day209 = "209"
        case day210 = "210"
        case day211 = "211"
        case day212 = "212"
        case day213 = "213"
        case day300 = "300"
        case day301 = "301"
        case day302 = "302"
        case day303 = "303"
        case day304 = "304"
        case day305 = "305"
        case day306 = "306"
        case day307 = "307"
        case day308 = "308"
        case day309 = "309"
        case day310 = "310"
        case day311 = "311"
        case day312 = "312"
        case day313 = "313"
        case day400 = "400"
        case day401 = "401"
        case day402 = "402"
        case day403 = "403"
        case day404 = "404"
        case day405 = "405"
        case day406 = "406"
        case day407 = "407"
        case day500 = "500"
        case day501 = "501"
        case day502 = "502"
        case day503 = "503"
        case day504 = "504"
        case day506 = "506"
        case day507 = "507"
        case day508 = "508"
        case day900 = "900"
        case day901 = "901"
        case day999 = "999"
        
        var description: String {
            switch self {
                case .day100: return "\u{f00d}"
                case .day101: return "\u{f013}"
                case .day102: return "\u{f041}"
                case .day103: return "\u{f002}"
                case .day104: return "\u{f00c}"
                case .day200: return "\u{f0b7}"
                case .day201: return "\u{f0b8}"
                case .day202: return "\u{f0b9}"
                case .day203: return "\u{f0ba}"
                case .day204: return "\u{f0bb}"
                case .day205: return "\u{f0bc}"
                case .day206: return "\u{f0bd}"
                case .day207: return "\u{f0be}"
                case .day208: return "\u{f0bf}"
                case .day209: return "\u{f0c0}"
                case .day210: return "\u{f0c1}"
                case .day211: return "\u{f073}"
                case .day212: return "\u{f056}"
                case .day213: return "\u{f0ce}"
                case .day300: return "\u{f01a}"
                case .day301: return "\u{f01a}"
                case .day302: return "\u{f01d}"
                case .day303: return "\u{f01e}"
                case .day304: return "\u{f06c}"
                case .day305: return "\u{f015}"
                case .day306: return "\u{f019}"
                case .day307: return "\u{f017}"
                case .day308: return "\u{f018}"
                case .day309: return "\u{f009}"
                case .day310: return "\u{f026}"
                case .day311: return "\u{f026}"
                case .day312: return "\u{f028}"
                case .day313: return "\u{f038}"
                case .day400: return "\u{f01b}"
                case .day401: return "\u{f01b}"
                case .day402: return "\u{f064}"
                case .day403: return "\u{f01b}"
                case .day404: return "\u{f065}"
                case .day405: return "\u{f065}"
                case .day406: return "\u{f065}"
                case .day407: return "\u{f065}"
                case .day500: return "\u{f014}"
                case .day501: return "\u{f014}"
                case .day502: return "\u{f014}"
                case .day503: return "\u{f082}"
                case .day504: return "\u{f082}"
                case .day506: return "\u{f082}"
                case .day507: return "\u{f082}"
                case .day508: return "\u{f082}"
                case .day900: return "\u{f055}"
                case .day901: return "\u{f053}"
                case .day999: return "\u{f07b}"
            }
        }
    }
    
    init(condition: Int, iconString: String) {
        var rawValue: String
        
        //rawValue = "day" + String(condition)
        rawValue = String(condition)
        //print("rawValue is \(rawValue)")
        
        guard let iconType = IconType(rawValue: rawValue) else {
            iconText = ""
            //print("i'm dead in here")
            return
        }
        iconText = iconType.description
        //print("i'm not dead in here")
    }
}