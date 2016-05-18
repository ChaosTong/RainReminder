//
//  RRouter.swift
//  RainReminder
//
//  Created by 童超 on 16/5/3.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation
import Alamofire

enum RRouter: URLRequestConvertible {
    static let baseURLString = "https://api.heweather.com/x3/weather"
    static let key = "04f6c6c770d94aee8f738758a829d826"
    //城市名称、支持中英文,不区分大小写和空格,城市和国家之间用英文逗号分割
    case FetchWeather(city: String, key: String)
    
    // MARK: URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String: AnyObject], method: String) = {
            switch self {
            case .FetchWeather(let city, let key):
                return ("", ["city": city, "key": key], "GET")
            }
            
        }()
        
        let URL = NSURL(string: RRouter.baseURLString)!
        let URLRequest = NSURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        let encoding = Alamofire.ParameterEncoding.URL
        let request = encoding.encode(URLRequest, parameters: result.parameters).0
        request.HTTPMethod = result.method
        return request
    }
}