//
//  LaunchViewController.swift
//  RainReminder
//
//  Created by 童超 on 16/4/11.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var launchImageView: UIImageView!
    @IBOutlet weak var launchTextLabel: UILabel!
    
    let launchImgKey = "launchImgKey"
    let launchTextKey = "launchTextKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().objectForKey(launchTextKey) != nil {
            launchTextLabel.text = NSUserDefaults.standardUserDefaults().objectForKey(launchTextKey) as? String
        }
        
        //下载下一次所需的启动页数据
        //http://news-at.zhihu.com/api/4/start-image/1080*1776
            Alamofire.request(.GET, "http://www.easyulife.com/json/launchpic.json").responseJSON { response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    
                    let text = json["text"].stringValue
                    self.launchTextLabel.text = text
                    NSUserDefaults.standardUserDefaults().setObject(text, forKey: self.launchTextKey)
                    
                    //let imagestring = "https://pic1.zhimg.com/d81d32da9ca5bff70171ed2c1893ad6c.jpg"
                    let launchImageURL = json["img"].stringValue
                    //let launchImageURL = imagestring
                    Alamofire.request(.GET, launchImageURL).responseData { response in
                        if let data = response.data {
                            NSUserDefaults.standardUserDefaults().setObject(data, forKey: self.launchImgKey)
                            self.launchImageView.sd_setImageWithURL(NSURL(string: launchImageURL))
                        }
                    }
                case .Failure(let error):
                    print("下载login图片出错了:\(error)")
                }
            }
        }
        
    }
    

