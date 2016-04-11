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

class ViewController: UIViewController, CLLocationManagerDelegate,UICollectionViewDelegateFlowLayout,CityListViewControllerDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var buttonOfCity: UIButton!
    @IBOutlet weak var labelOfDate: UILabel!
    @IBOutlet weak var labelOfIcon: UILabel!
    @IBOutlet weak var labelOfState: UILabel!
    @IBOutlet weak var TmpMax: UILabel!
    @IBOutlet weak var TmpMin: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var rainPercentLabel: UILabel!
    @IBOutlet weak var TmpNow: UILabel!

    @IBOutlet weak var collectionView: WeekWeatherCollectionView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    var updatingLocation = false
    var timer: NSTimer?
    var location: CLLocation?
    var lastLocationError: NSError?
    var performingReversseGeoCoding = false
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var lastGeocodingError: NSError?
    
    var dateString: String!
    var parserXML:ParserXML!
    var dataModel: DataModel!
    
    var weatherResult = WeatherResult()
    var serviceResult = ServerResult()
    
    var serial:dispatch_queue_t = dispatch_queue_create("serialQueue1", DISPATCH_QUEUE_SERIAL)
    
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
    
    //MARK: - key sth.
    let BaseURL = "https://api.heweather.com/x3/weather"
    let key = "04f6c6c770d94aee8f738758a829d826"
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        returnDir()
        
        if !cityName.isEmpty {
            performNetWork()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        //performNetWork()
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        // make the status bar hide
//        return true
//    }
    
    //MARK: - return the sandbox url
    func returnDir() {
        //Print the directory
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        print(DocumentsDirectory)
    }
    
    //MARK: - request network data
    func performNetWork() {
        
        let hudView = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hudView.mode = MBProgressHUDModeIndeterminate
        hudView.labelText = "Loading"
        
        let params:[String: AnyObject] = ["city": cityName,"key": key]
        Alamofire.request(.GET, BaseURL, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success(let dat):
                let json = JSON(dat)
                let data = json["HeWeather data service 3.0"][0]
                let status = data["status"].stringValue
                
                if status == "ok" {
                    let tmpsNow = data["now"]["tmp"].stringValue
                    let nowCode = data["now"]["cond"]["code"].intValue
                    let nowTxt = data["now"]["cond"]["txt"].stringValue
                    let tmpsMax = data["daily_forecast"][0]["tmp"]["max"].stringValue
                    let tmpsMin = data["daily_forecast"][0]["tmp"]["min"].stringValue
                    let pop = data["daily_forecast"][0]["pop"].stringValue
                    //let txt_d = data["daily_forecast"][0]["cond"]["txt_d"].stringValue
                    //let code_d = data["daily_forecast"][0]["cond"]["code_d"].stringValue
                    //let txt_n = data["daily_forecast"][0]["cond"]["txt_n"].stringValue
                    //let code_n = data["daily_forecast"][0]["cond"]["code_n"].stringValue
                    
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
                    
                    
                    
                    hudView.hide(true)
                    iToast.makeText("更新成功").show()
                } else {
                    hudView.hide(true)
                    iToast.makeText("获取失败").show()
                }
                
            case .Failure(let error):
                hudView.hide(true)
                iToast.makeText("获取失败").show()
                print("*** network error is \(error)")
            }
        }
    }
    
    
    //MARK: - make city name 规范 '上海市' to '上海'
    func rangeOfCities(placemark: String) -> String{
        if !placemark.isEmpty {
            parserXML = ParserXML()
            let cities = parserXML.cities
            for (_ , value) in cities.enumerate(){
                if placemark.rangeOfString(value.cityCN) != nil{
                    return  value.cityCN
                }
            }
        }
        return placemark
    }
    
    //MARK: - init 
    func initLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
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
            buttonOfCity.setTitle(cityName, forState: .Normal)
        } else {
            initLocation()
            buttonOfCity.setTitle(cityName, forState: .Normal)
        }
    }
    
    //MARK: - update the week day
    func dateUpdate() {
        let currentdate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let  convertedDate = dateFormatter.stringFromDate(currentdate)
        labelOfDate.text = convertedDate
        dateString = convertedDate
    }
    
    //MARK: - location button func
    @IBAction func locationButton(sender: UIButton) {
        initLocation()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//        if !cityName.isEmpty {
//            performNetWork()
//        }
    }
    
    
    //MARK: - show Alert
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "定位服务被禁用", message: "请在设置中打开", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Default,handler: nil))
        //let  okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(UIAlertAction(title: "前往设置", style: .Default, handler: { (action: UIAlertAction!) in
            if let url = NSURL(string: "prefs:root") {
                UIApplication.sharedApplication().openURL(url)
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showNoGeoInfoAlert() {
        let alert = UIAlertController(title: "无法定位", message: "请稍后再使用本服务", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: CLLocationManager Method
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
            distance = newLocation.distanceFromLocation(location)
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
                    
                   // print("*** Found placemarks: \(placemarks), error: \(error)")
                    
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks where !p.isEmpty {
                        self.placemark = p.last!
                        
                        if self.placemark?.country != nil {self.country = (self.placemark?.country)!}
                        if self.placemark?.ISOcountryCode != nil {self.country_code = (self.placemark?.ISOcountryCode)!}
                        if self.placemark?.administrativeArea != nil {self.province = (self.placemark?.administrativeArea)!}
                        if self.placemark?.locality != nil {
                            self.city = self.rangeOfCities(self.placemark!.locality!)
                            self.appCloud().cityName = self.city
                            self.cityName = self.city
                        }
                        if self.placemark?.subLocality != nil {self.district = (self.placemark?.subLocality)!}
                        if self.placemark?.thoroughfare != nil {self.street = (self.placemark?.thoroughfare)!}
                        if self.placemark?.name != nil {self.name = (self.placemark?.name)!}
                        
                        
                        //self.postalCode = (self.placemark?.postalCode)!
                        
                        geoInfo = GeoinfoModel(country: self.country, country_code: self.country_code, province: self.province, city: self.city, district: self.district, street: self.street, name: self.name)
                        GeoinfoModel.encode(geoInfo!)
                        
                        if !self.cityName.isEmpty {
                            self.performNetWork()
                        }
                        
                        self.buttonOfCity.setTitle(self.cityName, forState: .Normal)
                        
                        print("*** the only thing i need is \(geoInfo?.city)")
                        //print("my country is \(self.country),the province maybe is \(self.province),the district is \(self.district), the street is \(self.street),the name is \(self.name)")
                    } else {
                        self.placemark = nil
                        self.showNoGeoInfoAlert()
                    }
                    
                    self.performingReversseGeoCoding = false
                    
                })
            }
        } else if distance < 100.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
            }
        }
    }
    
    //MARK: - 获取总代理
    func appCloud() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    //MARK: -
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CityList"{
            let controller = segue.destinationViewController as! CityListViewController
            controller.delegate = self
            controller.cities = dataModel.cities
        }
    }
    
    func cityListViewControolerDidSelectCity(controller: CityListViewController, didSelectCity city: City) {
        
        //减少网络请求次数,相同城市只有动画效果不重新加载网络请求
        if cityName == city.cityCN{
            
            let hudView = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hudView.mode = MBProgressHUDModeIndeterminate
            hudView.labelText = "Loading"
            sleep(1)
            hudView.hide(true)
            iToast.makeText("加载成功").show()
            buttonOfCity.setTitle(cityName, forState: .Normal)
            
        }else{
            cityName = city.cityCN
            performNetWork()
            buttonOfCity.setTitle(cityName, forState: .Normal)
        }
        dataModel.appendCity(city)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cityListViewControllerDeleteCity(controller: CityListViewController, currentCities cities: [City]){
        dataModel.cities = cities
    }
    
    func cityListViewControllerCancel(controller: CityListViewController) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.performSelector("performNetWork", withObject: nil, afterDelay: 0.3)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ViewController: UIScrollViewDelegate{
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offSety = scrollView.contentOffset.y
        if decelerate{
            if offSety <= -100{
                performSegueWithIdentifier("CityList", sender: scrollView)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherResult.dailyResults.count
    
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("WeekWeatherCell", forIndexPath: indexPath) as! WeekWeatherCell
        
        let dailyResult = weatherResult.dailyResults[indexPath.item]
        
        cell.configureForDailyResult(dailyResult)
        
        return cell
    }
}