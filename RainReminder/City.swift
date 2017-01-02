//
//  Citys.swift
//  UmberellaWeather
//
//  Created by ZeroJianMBP on 15/12/25.
//  Copyright © 2015年 ZeroJian. All rights reserved.
//

import Foundation

class City: NSObject,NSCoding{
  var cityCN = ""

  override init(){
    super.init()
  }

  
  required init?(coder aDecoder: NSCoder) {
    cityCN = aDecoder.decodeObject(forKey: "CityCN") as! String
    super.init()
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(cityCN, forKey: "CityCN")
  }
  
}
