//
//  GeoInfoModel.swift
//  RainReminder
//
//  Created by 童超 on 16/4/7.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation

struct GeoinfoModel {

    var country = ""
    var country_code = ""
    var province = ""
    var city = ""
    var district = ""
    var street = ""
    //var postalCode = ""
    var name = ""
    
    init(country: String, country_code: String, province: String, city: String, district: String, street: String, name: String) {
        self.country = country
        self.country_code = country_code
        self.province = province
        self.city = city
        self.district = district
        self.street = street
        //self.postalCode = postalCode
        self.name = name
    }
    
    static func encode(geoinfo: GeoinfoModel) {
        let geoinfomodelClassObject = HelperClass(geoinfo: geoinfo)
        NSKeyedArchiver.archiveRootObject(geoinfomodelClassObject, toFile: HelperClass.path())
    }
    
    static func decode() -> GeoinfoModel? {
        let geoinfomodelClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(HelperClass.path()) as? HelperClass
        return geoinfomodelClassObject?.geoinfo
    }
    
}

extension GeoinfoModel {
    class HelperClass: NSObject, NSCoding {
        
        var geoinfo: GeoinfoModel?
        
        init(geoinfo: GeoinfoModel) {
            self.geoinfo = geoinfo
            super.init()
        }
        
        class func path() -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
            let path = documentsPath?.stringByAppendingString("/GeoInfo.plist")
            return path!
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let country = aDecoder.decodeObjectForKey("country") as? String else { geoinfo = nil; super.init(); return nil }
            guard let country_code = aDecoder.decodeObjectForKey("country_code") as? String else { geoinfo = nil; super.init(); return nil }
            guard let province = aDecoder.decodeObjectForKey("province") as? String else { geoinfo = nil; super.init(); return nil }
            guard let city = aDecoder.decodeObjectForKey("city") as? String else { geoinfo = nil; super.init(); return nil }
            guard let district = aDecoder.decodeObjectForKey("district") as? String else { geoinfo = nil; super.init(); return nil }
            guard let street = aDecoder.decodeObjectForKey("street") as? String else { geoinfo = nil; super.init(); return nil }
            //guard let postalCode = aDecoder.decodeObjectForKey("postalCode") as? String else { geoinfo = nil; super.init(); return nil }
            guard let name = aDecoder.decodeObjectForKey("name") as? String else { geoinfo = nil; super.init(); return nil }
            
            geoinfo = GeoinfoModel(country: country, country_code: country_code, province: province, city: city, district: district, street: street, name: name)
            
            super.init()
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(geoinfo!.country, forKey: "country")
            aCoder.encodeObject(geoinfo!.country_code, forKey: "country_code")
            aCoder.encodeObject(geoinfo!.province, forKey: "province")
            aCoder.encodeObject(geoinfo!.city, forKey: "city")
            aCoder.encodeObject(geoinfo!.district, forKey: "district")
            aCoder.encodeObject(geoinfo!.street, forKey: "street")
            //aCoder.encodeObject(geoinfo!.postalCode, forKey: "postalCode")
            aCoder.encodeObject(geoinfo!.name, forKey: "name")
        }
    }
}

//创建全局数据
var geoInfo:GeoinfoModel?