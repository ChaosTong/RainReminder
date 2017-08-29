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
        
        if UserDefaults.standard.object(forKey: launchTextKey) != nil {
            launchTextLabel.text = UserDefaults.standard.object(forKey: launchTextKey) as? String
        }
        
        //下载下一次所需的启动页数据
        //http://news-at.zhihu.com/api/4/start-image/1080*1776
//            Alamofire.request(.GET, "http://www.easyulife.com/json/launchpic.json").responseJSON { response in
//                switch response.result {
//                case .Success(let data):
//                    let json = JSON(data)
//                    
//                    let text = json["text"].stringValue
//                    self.launchTextLabel.text = text
//                    NSUserDefaults.standardUserDefaults().setObject(text, forKey: self.launchTextKey)
//                    
//                    //let imagestring = "https://pic1.zhimg.com/d81d32da9ca5bff70171ed2c1893ad6c.jpg"
//                    let launchImageURL = json["img"].stringValue
//                    //let launchImageURL = imagestring
//                    Alamofire.request(.GET, launchImageURL).responseData { response in
//                        if let data = response.data {
//                            NSUserDefaults.standardUserDefaults().setObject(data, forKey: self.launchImgKey)
//                            self.launchImageView.sd_setImageWithURL(NSURL(string: launchImageURL))
//                        }
//                    }
//                case .Failure(let error):
//                    print("下载login图片出错了:\(error)")
//                }
//            }
        
        Alamofire.request("http://www.easyulife.com/json/launchpic.json", method: .get, parameters: nil, encoding: JSONEncoding.default)
            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { request, response, data in
                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                guard response.result.error == nil, let data = response.result.value else {
                    print(response.result)
                    let launchImageURL = "https://pic1.zhimg.com/d81d32da9ca5bff70171ed2c1893ad6c.jpg"
                    Alamofire.request(launchImageURL, method: .get, parameters: nil, encoding: JSONEncoding.default)
                        .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                            print("Progress: \(progress.fractionCompleted)")
                        }
                        .validate { request, response, data in
                            // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                            return .success
                        }
                        .responseJSON { response in
                            if let data = response.data {
                                UserDefaults.standard.set(data, forKey: self.launchImgKey)
                                self.launchImageView.sd_setImage(with: NSURL(string: launchImageURL) as URL!)
                            }
                    }
                    return
                }
                let json = JSON(data)
                let error = json["error"].intValue
                
                let text = json["text"].stringValue
                self.launchTextLabel.text = text
                UserDefaults.standard.set(text, forKey: self.launchTextKey)
                
                //let imagestring = "https://pic1.zhimg.com/d81d32da9ca5bff70171ed2c1893ad6c.jpg"
                let launchImageURL = json["img"].stringValue
                //let launchImageURL = imagestring
                
                
                Alamofire.request(launchImageURL, method: .get, parameters: nil, encoding: JSONEncoding.default)
                    .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                        print("Progress: \(progress.fractionCompleted)")
                    }
                    .validate { request, response, data in
                        // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                        return .success
                    }
                    .responseJSON { response in
                        if let data = response.data {
                        UserDefaults.standard.set(data, forKey: self.launchImgKey)
                        self.launchImageView.sd_setImage(with: NSURL(string: launchImageURL) as URL!)
                    }
                }
//                Alamofire.request(.GET, launchImageURL).responseData { response in
//                    if let data = response.data {
//                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: self.launchImgKey)
//                        self.launchImageView.sd_setImageWithURL(NSURL(string: launchImageURL))
//                    }
//                }
                
        }
        
        
        
        }
        
    }
    

