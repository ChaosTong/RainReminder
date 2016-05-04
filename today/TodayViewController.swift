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
    
    override func viewWillAppear(animated: Bool) {
        reciveData()
        print("view will appear")
    }
    
    override func viewDidAppear(animated: Bool) {
        print("view did appear")
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
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
        let userDefaults = NSUserDefaults(suiteName: "group.rainreminderShareDefault")
        let shortcut = userDefaults?.objectForKey("com.easyulife.rainreminder.message") as! String
        
        if !(shortcut.characters.count > 15) {
            labelOficon = userDefaults?.objectForKey("com.easyulife.rainreminder.icon") as! String
            labelOflocation = userDefaults?.objectForKey("com.easyulife.rainreminder.location") as! String
            labelOftime = userDefaults?.objectForKey("com.easyulife.rainreminder.time") as! String
            labelOfstate = userDefaults?.objectForKey("com.easyulife.rainreminder.state") as! String
            labelOfnow = userDefaults?.objectForKey("com.easyulife.rainreminder.now") as! String
            labelOftmp = userDefaults?.objectForKey("com.easyulife.rainreminder.tmp") as! String
            
            setUI()
            message.text = ""
        } else {
            setUI()
            message.text = shortcut
        }
    }
}
