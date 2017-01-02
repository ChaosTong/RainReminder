//
//  ParserXML.swift
//  RainReminder
//
//  Created by 童超 on 16/4/8.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation

class ParserXML: NSObject,XMLParserDelegate{
    
    var elementName = ""
    var cities = [City]()
    
    override init(){
        super.init()
        parseXMLResource()
    }
    
    func parseXMLResource(){
        let parser = XMLParser(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Citys", ofType: "xml")!))
        if let parser = parser{
            parser.delegate = self
            parser.parse()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let str = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if elementName == "city"{
            let city = City()
            city.cityCN = str
            cities.append(city)
        }
    }
}
