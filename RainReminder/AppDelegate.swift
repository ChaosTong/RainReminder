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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if let geoInfo = GeoinfoModel.decode() {
            cityName = geoInfo.city
            print("之前存储过地理位置信息")
        } else {
            print("之前没有存储过地理位置信息")
        }
        
        let controller = self.window?.rootViewController as! ViewController
        controller.dataModel = dataModel
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(NSTimeInterval(3600 * 12))
        
        var isLaunchedFromQuickAction = false
        
        //add WeiboSDK info
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp("599717178")
        
        // Check if it's launched from Quick Action
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            
            isLaunchedFromQuickAction = true
            // Handle the sortcutItem
            handleQuickAction(shortcutItem)
        } else {
            self.window?.backgroundColor = UIColor.blackColor()
        }
        
        // Return false if the app was launched from a shortcut, so performAction... will not be called.
        return !isLaunchedFromQuickAction
        
        //return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        saveData()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        completionHandler(handleQuickAction(shortcutItem))
        
    }
    
    //MARK: - Weibo
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        if let authorizeResponse = response as? WBAuthorizeResponse {
            if authorizeResponse.statusCode == WeiboSDKResponseStatusCode.Success {
                
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
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.componentsSeparatedByString(".").last!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = UIViewController()
        
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .nowWeather:
                self.window?.backgroundColor = UIColor(red: 151.0/255.0, green: 187.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                vc = storyboard.instantiateViewControllerWithIdentifier("viewController") as! ViewController
                quickActionHandled = true
            case .search:
                
                vc = storyboard.instantiateViewControllerWithIdentifier("cityListViewController") as! CityListViewController
                quickActionHandled = true
            }
        }
        window!.rootViewController?.presentViewController(vc, animated: true, completion: nil)
        return quickActionHandled
    }
    
    func applicationWillTerminate(application: UIApplication) {
        saveData()
    }

    func saveData(){
        dataModel.saveData()
    }

}

