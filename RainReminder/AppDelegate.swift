//
//  AppDelegate.swift
//  RainReminder
//
//  Created by 童超 on 16/4/6.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WeiboSDKDelegate {

    var window: UIWindow?
    var dataModel = DataModel()
    var cityName = ""
    var firstDisplay = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let geoInfo = GeoinfoModel.decode() {
            cityName = geoInfo.city
            print("之前存储过地理位置信息")
        } else {
            print("之前没有存储过地理位置信息")
        }
        
        let controller = self.window?.rootViewController as! HomeController
        controller.dataModel = dataModel
        
        //设置最小Fetch时间 3h
        //UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(NSTimeInterval(3600 * 12))
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        var isLaunchedFromQuickAction = false
        
        //add WeiboSDK info
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp("599717178")
        
        // Check if it's launched from Quick Action
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            isLaunchedFromQuickAction = true
            // Handle the sortcutItem
            handleQuickAction(shortcutItem)
        } else {
            self.window?.backgroundColor = UIColor.black
        }
        
        // Return false if the app was launched from a shortcut, so performAction... will not be called.
        return !isLaunchedFromQuickAction
        
        //return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        completionHandler(handleQuickAction(shortcutItem))
        
    }
    
    //MARK: - Fetch Background
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("*** fetch start")
        if let fetchViewController = window?.rootViewController as? HomeController {
            fetchViewController.fetch {
                fetchViewController.performNetWork()
                completionHandler(.newData)
                print("*** fetch")
            }
        }
    
    }
    
    //MARK: - Weibo
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if let authorizeResponse = response as? WBAuthorizeResponse {
            if authorizeResponse.statusCode == WeiboSDKResponseStatusCode.success {
                
                //let authorizeResponse : WBAuthorizeResponse = response as! WBAuthorizeResponse
                let userID = authorizeResponse.userID
                let accessToken = authorizeResponse.accessToken
                
                print("userID:\(userID)\naccessToken:\(accessToken)")
                
                print(authorizeResponse.userInfo)
            }
        }
    }
    
    
    enum Shortcut: String {
        case nowWeather = "nowWeather"
        case search = "search"
    }
    
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = UIViewController()
        
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .nowWeather:
                self.window?.backgroundColor = UIColor(red: 151.0/255.0, green: 187.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                vc = storyboard.instantiateViewController(withIdentifier: "viewController") as! HomeController
                quickActionHandled = true
            case .search:
                
                vc = storyboard.instantiateViewController(withIdentifier: "cityListViewController") as! CityListViewController
                quickActionHandled = true
            }
        }
        window!.rootViewController?.present(vc, animated: true, completion: nil)
        return quickActionHandled
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveData()
    }

    func saveData(){
        dataModel.saveData()
    }

}

