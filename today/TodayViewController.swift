//
//  TodayViewController.swift
//  today
//
//  Created by 童超 on 16/5/4.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var labelOflocation = ""
    var labelOftime = ""
    var labelOfstate = ""
    var labelOfnow = ""
    var labelOftmp = ""
    var labelOficon = ""
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var now: UILabel!
    @IBOutlet weak var tmp: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var icon: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize.height = 65
        
        reciveData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reciveData()
        print("view will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
    }
    
    @IBAction func GotoMain(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "RainReminder://")!
        self.extensionContext!.open(url , completionHandler: nil)
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    func setUI() {
        location.text = labelOflocation
        time.text = labelOftime
        state.text = labelOfstate
        now.text = labelOfnow
        tmp.text = labelOftmp
        icon.text = labelOficon
    }
    
    func reciveData() {
        let userDefaults = UserDefaults(suiteName: "group.rainreminderShareDefault")
        let shortcut = userDefaults?.object(forKey: "com.easyulife.rainreminder.message") as! String
        
        if !(shortcut.characters.count > 15) {
            
            let timestamp = userDefaults?.object(forKey: "com.easyulife.rainreminder.time") as! String
            labelOficon = userDefaults?.object(forKey: "com.easyulife.rainreminder.icon") as! String
            labelOflocation = userDefaults?.object(forKey: "com.easyulife.rainreminder.location") as! String
            labelOftime = Date.dateFromeWeiboDateStr(timestamp).weiboDescriptionDate()
            labelOfstate = userDefaults?.object(forKey: "com.easyulife.rainreminder.state") as! String
            labelOfnow = userDefaults?.object(forKey: "com.easyulife.rainreminder.now") as! String
            labelOftmp = userDefaults?.object(forKey: "com.easyulife.rainreminder.tmp") as! String
            
            setUI()
            message.text = ""
        } else {
            setUI()
            message.text = shortcut
        }
    }
}

extension Date {
    /// 从微博服务端字符串获取日期
    static func dateFromeWeiboDateStr(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.date(from: dateString)!
    }
    /// 返回日期的描述文字，1分钟内：刚刚，1小时内：xx分钟前，1天内：HH:mm，昨天：昨天 HH:mm，1年内：MM-dd HH:mm，更早时间：yyyy-MM-dd HH:mm
    func weiboDescriptionDate() -> String {
        let calendar = Calendar.current
        var dateFormat = "HH:mm"
        // 如果是一天之内
        if calendar.isDateInToday(self) {
            let since = Date().timeIntervalSince(self)
            //一分钟内
            if since < 60.0 {
                return "刚刚"
            }
            if since < 3600.0 {
                return "\(Int(since/60))分钟前"
            }
            return "\(Int(since/3600.0))小时前"
        }
        // 如果是昨天
        if calendar.isDateInYesterday(self) {
            dateFormat = "昨天 " + dateFormat
        } else {
            dateFormat = "MM-dd " + dateFormat
            let component = (calendar as NSCalendar).components([NSCalendar.Unit.year], from: self, to: Date(), options: [])
            if component.year! > 1 {
                dateFormat = "yyyy-" + dateFormat
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.string(from: self)
    }
}
