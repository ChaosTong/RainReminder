//
//  ViewController.swift
//  RainReminder
//
//  Created by 童超 on 16/4/6.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Social
import UIKit
import FloatingActionSheetController

class HomeController: UIViewController, CLLocationManagerDelegate,UICollectionViewDelegateFlowLayout,CityListViewControllerDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var buttonOfCity: UIButton!
    @IBOutlet weak var labelOfDate: UILabel!
    @IBOutlet weak var labelOfIcon: UILabel!
    @IBOutlet weak var labelOfState: UILabel!
    @IBOutlet weak var butttonOfshare: UIButton!
    @IBOutlet weak var TmpMax: UILabel!
    @IBOutlet weak var TmpMin: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var rainPercentLabel: UILabel!
    @IBOutlet weak var TmpNow: UILabel!

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var collectionView: WeekWeatherCollectionView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    var updatingLocation = false
    var timer: Timer?
    var location: CLLocation?
    var lastLocationError: NSError?
    var performingReversseGeoCoding = false
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var lastGeocodingError: NSError?
    var NONetWork = false
    
    var dateString: String!
    var parserXML:ParserXML!
    var dataModel: DataModel!
    var firstView: UIView!
    var weiboAlertView: UIView!
    var tap = UITapGestureRecognizer()
    var textView = UITextView()
    var windowImage = UIImage()
    
    var weatherResult = WeatherResult()
    var serviceResult = ServerResult()
    
    //var serial:dispatch_queue_t = dispatch_queue_create("serialQueue1", DISPATCH_QUEUE_SERIAL)
    
    var country = ""
    var country_code = ""
    var province = ""
    var city = ""
    var cityName = ""
    var district = ""
    var street = ""
    var postalCode = ""
    var name = ""
    var state = ""
    var max = ""
    var min = ""
    var hum: Float?
    var date = ""
    var convertedDate = ""
    var suggestion = ""
    var raintxt = ""
    var pop = "0"
    var update = Date().description
    
    //MARK: - key sth.
    let BaseURL = "https://free-api.heweather.com/v5/weather"
    let key = "04f6c6c770d94aee8f738758a829d826"
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        returnDir()
        dataModel = appCloud().dataModel
        
        if appCloud().firstDisplay {
            launchView()
            appCloud().firstDisplay = false
        }
        
        self.handleFirstTime()
        
        headerView.backgroundColor = UIColor.clear
        mainView.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor.clear
        dateView.backgroundColor = UIColor.clear
        
        // for the today widget
        NotificationCenter.default
            .addObserver(self, selector: #selector(HomeController.applicationWillResignActive),name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        fetch { self.saveDefaults() }
    }

    // MARK: - 判断当前网络情况
    
//    func whatNetwork() {
//        let reachability: Reachability
//        do {
//            reachability = try Reachability.NetworkReachable
//        } catch {
//            print("网络连接：不可用")
//            return
//        }
        
        //判断连接状态
//        if reachability.isReachable{
//           print("网络连接：可用")
//        }else{
//            print("网络连接：不可用")
//        }
        
        //判断连接类型
//        if reachability.isReachableViaWiFi {
//            print("连接类型：WiFi")
//        }else if reachability.isReachableViaWWAN {
//            print("连接类型：移动网络")
//        }else {
//            print("连接类型：没有网络连接")
//            NONetWork = true
//        }
//    }
    
    //MARK: - Fetch Background
    func fetch(_ completion: () -> Void) {
        completion()
    }
    
    @objc fileprivate func applicationWillResignActive() { 
        saveDefaults()
    }
    
    func saveDefaults() {
        var message = ""
        let userDefault = UserDefaults(suiteName: "group.rainreminderShareDefault")
        if dataModel.dailyResults.count > 0 {
        
            
            let state  = dataModel.dailyResults[0].dailyState
            let max = dataModel.dailyResults[0].dailyTmpMax
            let min = dataModel.dailyResults[0].dailyTmpMin
            let tmp = "\(max)/\(min)"
            let location = dataModel.currentCity
            let time = update
            let now = dataModel.currentTmp
            let icon = WeatherIcon(condition: Int(dataModel.currentCode)!, iconString: "day").iconText
            
            userDefault?.set(icon, forKey: "com.easyulife.rainreminder.icon")
            userDefault?.set(location, forKey: "com.easyulife.rainreminder.location")
            userDefault?.set(time, forKey: "com.easyulife.rainreminder.time")
            userDefault?.set(state, forKey: "com.easyulife.rainreminder.state")
            userDefault?.set(now, forKey: "com.easyulife.rainreminder.now")
            userDefault?.set(tmp, forKey: "com.easyulife.rainreminder.tmp")
            message = "have data"
        } else {
            message = "您现在还没有添加城市,请点击进入RainReminder进行定位或搜索."
        }
        
        userDefault?.set(message, forKey: "com.easyulife.rainreminder.message")
        
        userDefault!.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Launch View
    
    func launchView() {
        //生成第二启动页背景
        let launchView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        launchView.alpha = 0.99
        
        //得到第二启动页控制器并设置为子控制器
        let launchViewController = storyboard?.instantiateViewController(withIdentifier: "launchViewController")
        self.addChildViewController(launchViewController!)
        
        //将第二启动页放到背景上
        launchView.addSubview(launchViewController!.view)
        
        //展示第二启动页并隐藏NavbarTitleView
        self.view.addSubview(launchView)
        //        self.navigationController?.
        //        self.tabBarController?.tabBar.
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        UINavigationBar.appearance().barTintColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().tintColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 0.6)
        
        
        UIView.animate(withDuration: 2.5, animations: { () -> Void in
            launchView.alpha = 1
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    launchView.alpha = 0
                    self.navigationController?.isNavigationBarHidden = false
                    self.tabBarController?.tabBar.isHidden = false
                })
        }) 
    }
    
    //MARK: - firstView
    
    //设置第一次启动引导
    func handleFirstTime(){
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        if firstTime{
            showViewWithFirstTime()
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }else{
            initLocation()
        }
    }
    
    func showViewWithFirstTime(){
        firstView = FirstView()
        firstView.frame = view.bounds
        let button = UIButton()
        button.bounds.size = CGSize(width: 100, height: 50)
        button.center = view.center
        button.setTitle("开始吧!", for: UIControlState())
        button.backgroundColor = view.tintColor
        firstView.addSubview(button)
        button.addTarget(self, action: #selector(HomeController.touchBegin(_:)), for: UIControlEvents.touchUpInside)
        
        view.addSubview(firstView)
    }
    
    func touchBegin(_ sender: UIButton){
        firstView.removeFromSuperview()
        handleFirstTime()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    //MARK: - Return the sandbox url
    func returnDir() {
        //Print the directory
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        print(DocumentsDirectory)
    }
    
    //MARK: - Request network data
    func performNetWork() {
        
        let hudView = MBProgressHUD.showAdded(to: self.view, animated: true)
        hudView?.mode = MBProgressHUDModeIndeterminate
        hudView?.labelText = "Loading"
        let param = ["city": cityName, "key": key]
        
        NetworkTools.requestData(.get, URLString: BaseURL,
                                 parameters: param) { (result) in
            let json = JSON(result)
            self.weatherResult = WeatherResult()
            let data = json["HeWeather5"][0]
            let status = data["status"].stringValue
            //print(json)
            if status == "ok" {
                let tmpsNow = data["now"]["tmp"].stringValue
                self.dataModel.currentTmp = tmpsNow + "˚"
                let nowCode = data["now"]["cond"]["code"].intValue
                self.dataModel.currentCode = "\(nowCode)"
                let nowTxt = data["now"]["cond"]["txt"].stringValue
                let tmpsMax = data["daily_forecast"][0]["tmp"]["max"].stringValue
                let tmpsMin = data["daily_forecast"][0]["tmp"]["min"].stringValue
                let pop = data["daily_forecast"][0]["pop"].stringValue
                let suggest_brf = data["suggestion"]["comf"]["brf"].stringValue
                let suggest_txt = data["suggestion"]["comf"]["txt"].stringValue
                let raintxt = data["suggestion"]["cw"]["txt"].stringValue
                self.suggestion = suggest_brf + ",\n" + suggest_txt
                self.raintxt = raintxt
                self.pop = pop

                if let ServiceState = data["status"].string{
                    self.weatherResult.ServiceStatus = ServiceState
                }

                if let jsonCity = data["basic"]["city"].string{
                    self.weatherResult.city = jsonCity
                }
                if let state = data["now"]["cond"]["txt"].string{
                    self.weatherResult.state = state
                }
                if let stateCode = data["now"]["cond"]["code"].string{
                    self.weatherResult.stateCode = Int(stateCode)!
                }

                let dailyArrays = data["daily_forecast"]
                let dailyDayTmp = dailyArrays[0]["tmp"]
                if let pop = dailyArrays[0]["pop"].string{
                    self.weatherResult.dayRain = pop
                }
                if let dayTemMax = dailyDayTmp["max"].string{
                    self.weatherResult.dayTemMax = dayTemMax + "˚"
                }
                if let dayTmpMin = dailyDayTmp["min"].string{
                    self.weatherResult.dayTmpMin = dayTmpMin + "˚"
                }

                for (_,subJson):(String, JSON) in data["daily_forecast"]{
                    let dailyResult = DailyResult()

                    if let dates = subJson["date"].string{
                        dailyResult.dailyDate = dates
                    }
                    if let pop = subJson["pop"].string{
                        dailyResult.dailyPop = Int(pop)!
                    }
                    if let tmpsMax = subJson["tmp"]["max"].string{
                        dailyResult.dailyTmpMax = tmpsMax + "˚"
                    }
                    if let tmpsMin = subJson["tmp"]["min"].string{
                        dailyResult.dailyTmpMin = tmpsMin + "˚"
                    }
                    if let conds = subJson["cond"]["txt_d"].string{
                        dailyResult.dailyState = conds
                    }
                    if let stateCode = subJson["cond"]["code_d"].string{
                        dailyResult.dailyStateCode = Int(stateCode)!
                    }
                    self.weatherResult.dailyResults.append(dailyResult)
                    self.collectionView .reloadData()
                }
                
                let weatherIcon = WeatherIcon(condition: nowCode, iconString: "day").iconText
                self.TmpMax.text = tmpsMax + "˚"
                self.TmpMin.text = tmpsMin + "˚"
                self.TmpNow.text = tmpsNow + "˚"
                self.labelOfState.text = nowTxt
                self.labelOfIcon.text = weatherIcon
                
                if let FloatRain = Float(pop){
                    let value = FloatRain / 100
                    self.progress.setProgress(value, animated: true)
                }
                
                self.rainPercentLabel.text = pop + "%"
                self.mainView.reloadInputViews()
                
                self.dataModel.dailyResults = self.weatherResult.dailyResults
                self.dataModel.currentCity = self.cityName
                self.dataModel.saveData()
                
                hudView?.hide(true)
                
                iToast.makeText("更新成功").show()
                self.update = NSDate().description
                self.saveDefaults()
            } else {
                hudView?.hide(true)
                iToast.makeText("获取失败").show()
            }
        }
    }
    
    //MARK: - make city name 规范 '上海市' to '上海'
    func rangeOfCities(_ placemark: String) -> String{
        if !placemark.isEmpty {
            parserXML = ParserXML()
            let cities = parserXML.cities
            for (_ , value) in cities.enumerated(){
                if placemark.range(of: value.cityCN) != nil{
                    return  value.cityCN
                }
            }
        }
        return placemark
    }
    
    //MARK: - init 
    func initLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
    }
    
    func initUI() {
        
        cityName = appCloud().cityName
        dateUpdate()
        if !cityName.isEmpty {
            buttonOfCity.setTitle(cityName, for: UIControlState())
        } else {
            initLocation()
            buttonOfCity.setTitle(cityName, for: UIControlState())
        }
    }
    
    //MARK: - update the week day
    func dateUpdate() {
        let currentdate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let  convertedDate = dateFormatter.string(from: currentdate)
        labelOfDate.text = convertedDate
        dateString = convertedDate
    }
    
    //MARK: - location button func
    @IBAction func locationButton(_ sender: UIButton) {
        initLocation()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//        if !cityName.isEmpty {
//            performNetWork()
//        }
    }
    //MARK: - share to Weibo
    @IBAction func shareToWeibo(_ sender: UIButton) {
        let window: UIWindow! = UIApplication.shared.keyWindow
        windowImage = window.capture()
        
        let action1 = FloatingAction(title: "分享到新浪微博") { action in
            if WeiboSDK.isWeiboAppInstalled() {
                self.showViewWithAlert()
            } else {
                let vc = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
        
                if !self.cityName.isEmpty && (self.weatherResult.dailyResults.count > 0) {
        
                let pretext = "\(self.cityName),\(self.weatherResult.dailyResults[0].dailyDate) \(self.weatherResult.dailyResults[0].dailyState) \n"
                var lasttext = ""
                if self.raintxt.range(of: "雨") != nil {
                    lasttext = "\n今天下雨几率为 \(self.pop)% 记得带伞☂"
                }
        
                if !self.suggestion.isEmpty {
                    vc?.setInitialText(pretext + self.suggestion + lasttext)
                } else {
                    vc?.setInitialText("快来使用Rain Reminder吧#RainReminder#")
                }
                let window: UIWindow! = UIApplication.shared.keyWindow
                self.windowImage = window.capture()
                vc?.add(self.windowImage)
                vc?.add(NSURL(string: "https://www.easyulife.com") as URL!)
                self.present(vc!, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "暂时无法分享", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "好的", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        // share action sheet
        let action2 = FloatingAction(title: "取消", handleImmediately: true) { action in
            self.dismiss(animated: true, completion: nil)
        }
        
        let group1 = FloatingActionGroup(action: action1, action2)
        FloatingActionSheetController(actionGroup: group1).present(in: self)
        
    }
    
    func showViewWithAlert(){
        weiboAlertView = WeiboAlert()
        weiboAlertView.frame = view.bounds
        
        let button = UIButton()
        
        let label = UILabel()
        
        button.frame = CGRect(x: 232, y: 385, width: 87, height: 29)
        button.setBackgroundImage(UIImage(named: "ButtonShareSubmit"), for: UIControlState())
        weiboAlertView.addSubview(button)
        button.addTarget(self, action: #selector(HomeController.submit(_:)), for: UIControlEvents.touchUpInside)
        
        textView.frame = CGRect(x: 54,y: 281,width: 265,height: 94)
        textView.backgroundColor = UIColor.black
        textView.textColor = UIColor.white
        textView.text = "\(cityName) @ \(weatherResult.dailyResults[0].dailyDate) - "
        weiboAlertView.addSubview(textView)
        textView.becomeFirstResponder()
        //make the keyboard won't cover the view
        self.weiboAlertView.frame.origin.y -= 40
        
        let count = textView.text.characters.count
        
        label.frame = CGRect(x: 297, y: 345, width: 50, height: 50)
        label.textColor = UIColor.black
        label.text = "\(150 - count)"
        label.font = label.font.withSize(12)
        weiboAlertView.addSubview(label)
        
        weiboAlertView.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(HomeController.WeibotouchBegin(_:)))
        
        view.addSubview(weiboAlertView)
    }
    
    func submit(_ sender: UIButton){
        
        shareSinaWeibo(textView.text)
        weiboAlertView.removeFromSuperview()
    }
    
    func WeibotouchBegin(_ sender: UIButton){
        weiboAlertView.removeFromSuperview()
    }
    
    // 发送分享请求
    func shareSinaWeibo(_ text: String) {
        let pretext = "\(text)\(weatherResult.dailyResults[0].dailyState) \n"
        var lasttext = ""
        if raintxt.range(of: "雨") != nil {
            lasttext = "\n今天下雨几率为 \(pop)% 记得带伞☂"
        }

        
        lasttext = pretext + suggestion + lasttext + "\n 快来使用Rain Reminder吧 http://app.weibo.com/t/feed/XELSG #RainReminder#"
       
        
        let request = WBSendMessageToWeiboRequest()
        request.message = messageToShare(lasttext, image: windowImage)
        WeiboSDK.send(request)
    }
    
    // 分享内容
    func messageToShare(_ text: String, image: UIImage) -> WBMessageObject {
        
        // 文字内容
        let message = WBMessageObject.message() as! WBMessageObject
        message.text = text
        
        // 图片内容
        let imageObject = WBImageObject()
        imageObject.imageData = UIImagePNGRepresentation(image)
        message.imageObject = imageObject
        return message
    }
    
    //MARK: - show Alert
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "定位服务被禁用", message: "请在设置中打开", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default,handler: nil))
        //let  okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(UIAlertAction(title: "前往设置", style: .default, handler: { (action: UIAlertAction!) in
            if let url = URL(string: "prefs:root") {
                UIApplication.shared.openURL(url)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showNoGeoInfoAlert() {
        let alert = UIAlertController(title: "无法定位", message: "请稍后再使用本服务", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default,handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: CLLocationManager Method
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(HomeController.didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            if let timer = timer {
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            print("*** stopLocationManager")
            if ((geoInfo?.city.isEmpty) != nil) {
                cityName = geoInfo!.city
                initUI()
            }
            
        }
    }
    
    func didTimeOut() {
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "RainReminderErrorDomain", code: 1, userInfo: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print("didUpdateLocations\(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                
                if distance > 0 {
                    performingReversseGeoCoding = false
                }
            }
            
            if !performingReversseGeoCoding {
                print("*** Going to geocode")
                
                performingReversseGeoCoding = true
                
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    placemarks, error in
                    
                    //print("*** Found placemarks: \(placemarks), error: \(error)")
                    
                    self.lastGeocodingError = error as NSError?
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                        
                        if self.placemark?.country != nil {self.country = (self.placemark?.country)!}
                        if self.placemark?.isoCountryCode != nil {self.country_code = (self.placemark?.isoCountryCode)!}
                        if self.placemark?.administrativeArea != nil {self.province = (self.placemark?.administrativeArea)!}
                        if self.placemark?.locality != nil {
                            self.city = self.rangeOfCities(self.placemark!.locality!)
                            self.appCloud().cityName = self.city
                            self.cityName = self.city
                            self.dataModel.currentCity = self.cityName
                            self.dataModel.saveData()
                        }
                        if self.placemark?.subLocality != nil {self.district = (self.placemark?.subLocality)!}
                        if self.placemark?.thoroughfare != nil {self.street = (self.placemark?.thoroughfare)!}
                        if self.placemark?.name != nil {self.name = (self.placemark?.name)!}
                        
                        
                        //self.postalCode = (self.placemark?.postalCode)!
                        
                        geoInfo = GeoinfoModel(country: self.country, country_code: self.country_code, province: self.province, city: self.city, district: self.district, street: self.street, name: self.name)
                        GeoinfoModel.encode(geoInfo!)
                        
                        if !self.cityName.isEmpty {
                            self.performNetWork()
                            //print("*** in gps")
                        }
                        
                        self.buttonOfCity.setTitle(self.cityName, for: UIControlState())
                        
                        //print("*** the only thing i need is \(geoInfo?.city)")
                        //print("my country is \(self.country),the province maybe is \(self.province),the district is \(self.district), the street is \(self.street),the name is \(self.name)")
                    } else {
                        self.placemark = nil
                        self.showNoGeoInfoAlert()
                    }
                    
                    self.performingReversseGeoCoding = false
                    
                })
            }
        } else if distance < 100.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 6 {
                print("*** Force done!")
                stopLocationManager()
            }
        }
    }
    
    //MARK: - 获取总代理
    func appCloud() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //MARK: -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CityList"{
            let controller = segue.destination as! CityListViewController
            controller.delegate = self
            controller.cities = dataModel.cities
        }
    }
    
    func cityListViewControolerDidSelectCity(_ controller: CityListViewController, didSelectCity city: City) {
        
        //减少网络请求次数,相同城市只有动画效果不重新加载网络请求
        if cityName == city.cityCN{
            
            cityName = city.cityCN
            performNetWork()
            buttonOfCity.setTitle(cityName, for: UIControlState())
            
//            let hudView = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//            hudView.mode = MBProgressHUDModeIndeterminate
//            hudView.labelText = "Loading"
//            sleep(1)
//            hudView.hide(true)
//            iToast.makeText("加载成功").show()
//            buttonOfCity.setTitle(cityName, forState: .Normal)
            
        }else{
            cityName = city.cityCN
            performNetWork()
            //print("*** return from citylist view")
            buttonOfCity.setTitle(cityName, for: UIControlState())
        }
        
        dataModel.appendCity(city)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        dismiss(animated: true, completion: nil)
    }
    
    func cityListViewControllerDeleteCity(_ controller: CityListViewController, currentCities cities: [City]){
        dataModel.cities = cities
    }
    
    func cityListViewControllerCancel(_ controller: CityListViewController) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        //self.performSelector("performNetWork", withObject: nil, afterDelay: 0.3)
        //print("*** in cityListViewController")
        dismiss(animated: true, completion: nil)
    }
}

extension HomeController: UIScrollViewDelegate{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offSety = scrollView.contentOffset.y
        if decelerate{
            if offSety <= -100{
                performSegue(withIdentifier: "CityList", sender: scrollView)
            }
        }
    }
}

extension HomeController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherResult.dailyResults.count
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekWeatherCell", for: indexPath) as! WeekWeatherCell
        
        let dailyResult = weatherResult.dailyResults[indexPath.item]
        
        cell.configureForDailyResult(dailyResult)
        
        return cell
    }
}

public extension UIWindow {
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
