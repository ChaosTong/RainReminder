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

class ViewController: UIViewController ,CLLocationManagerDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var buttonOfCity: UIButton!
    @IBOutlet weak var labelOfDate: UILabel!
    @IBOutlet weak var labelOfIcon: UILabel!
    @IBOutlet weak var labelOfState: UILabel!
    @IBOutlet weak var TmpMax: UILabel!
    @IBOutlet weak var TmpMin: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var rainPercentLabel: UILabel!

    @IBOutlet weak var mainView: UIView!
    
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
    
    let BaseURL = "https://api.heweather.com/x3/weather"
    let key = "04f6c6c770d94aee8f738758a829d826"
    
    override func viewDidLoad() {
        
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        print(DocumentsDirectory)
        
        super.viewDidLoad()
        
        if !(appCloud().cityName.isEmpty) {
            cityName = appCloud().cityName
            buttonOfCity.setTitle("\(cityName)", forState: .Normal)
            perforRequest()
            print("之前存储过地理位置信息，更新label of city")
        } else {
            initLocation()
            perforRequest()
            print("之前没有存储过地理位置信息，获取地理位置信息")
        }
        
        dateUpdate()
        if !state.isEmpty {
            
            labelOfState.text = state
            TmpMax.text = max
            TmpMin.text = min
            mainView.reloadInputViews()
        }
        
        weatherResult.loadData()
        if !(weatherResult.dayRain.isEmpty) {
            if let FloatRain = Float(weatherResult.dayRain) {
                let value = FloatRain / 100
                progress.setProgress(value, animated: true)
            }
            rainPercentLabel.text = "\(weatherResult.dayRain)%"
            mainView.reloadInputViews()
        }
        
        labelOfIcon.text = "\u{f002}"
        perforRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - request network data
    func perforRequest(){
        //载入天气数据
        dataModel.loadData()
        
//        if !(dataModel.currentCity.isEmpty) {
//            print("之前存储过天气信息")
//            
//            date = dataModel.dailyResults[0].dailyDate
//            
//            state = dataModel.dailyResults[0].dailyState
//            max = dataModel.dailyResults[0].dailyTmpMax
//            min = dataModel.dailyResults[0].dailyTmpMin
//            mainView.reloadInputViews()
//            
//            let currentdate = NSDate()
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "YYYY-MM-dd"
//            convertedDate = dateFormatter.stringFromDate(currentdate)
//    
//        }
//        if date == convertedDate && cityName == geoInfo?.city {
//            labelOfState.text = state
//            TmpMax.text = max
//            TmpMin.text = min
//            mainView.reloadInputViews()
//            print("同一天不更新数据")
//        }
        
            
            let params:[String: AnyObject] = ["city": self.city,"key": self.key]
            
            Alamofire.request(.GET, self.BaseURL, parameters: params).responseJSON {
                response in
                switch response.result {
                case .Success(let dat):
                    let json = JSON(dat)
                    let data = json["HeWeather data service 3.0"][0]
                    
                    let status = data["status"].stringValue
                    let city = data["basic"]["city"].stringValue
                    
                        
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
                            self.TmpMax.text = dayTemMax + "˚"
                        }
                        if let dayTmpMin = dailyDayTmp["min"].string{
                            self.weatherResult.dayTmpMin = dayTmpMin + "˚"
                            self.TmpMin.text = dayTmpMin + "˚"
                        }
                        
                        if !(self.weatherResult.dayRain.isEmpty) {
                            if let FloatRain = Float(self.weatherResult.dayRain) {
                                let value = FloatRain / 100
                                self.progress.setProgress(value, animated: true)
                            }
                            self.rainPercentLabel.text = "\(self.weatherResult.dayRain)%"
                            self.mainView.reloadInputViews()
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
                        if status == "ok" {
                            self.updateUI()
                            print("already")
                        }
                        
                        self.buttonOfCity.setTitle("\(self.weatherResult.city)", forState: .Normal)
                        
                        let dataModel = DataModel()
                        
                        dataModel.dailyResults = self.weatherResult.dailyResults
                        dataModel.currentCity = city
                        
                        self.state = dataModel.dailyResults[0].dailyState
                        self.max = dataModel.dailyResults[0].dailyTmpMax
                        self.min = dataModel.dailyResults[0].dailyTmpMin
                        self.hum = Float(self.weatherResult.dayRain)!
                        self.city = dataModel.currentCity
                        
                        dataModel.saveData()
                        self.weatherResult.saveData()
                        self.updateUI()
                        self.mainView.reloadInputViews()
                    }
                    self.updateUI()
                    
                case .Failure(let error):
                    print(error)
                }
            }
            self.updateUI()
            print("更新天气信息")
        
        
        
    }
    
    
    //MARK: - make city name 规范
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
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
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
    
    func updateUI() {
        
        labelOfIcon.text = "\u{f002}"
        
        if !state.isEmpty {
            
            labelOfState.text = state
            TmpMax.text = max
            TmpMin.text = min
            buttonOfCity.setTitle("\(city)", forState: .Normal)
            //print("hum is \(hum)")
            
            if let FloatRain = Float(weatherResult.dayRain) {
                let value = FloatRain / 100
                progress.setProgress(value, animated: true)
            }
            rainPercentLabel.text = "\(weatherResult.dayRain)%"
            mainView.reloadInputViews()
        } else {
            
        }
        
    }
    
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
        perforRequest()
        updateUI()
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
            
            if !city.isEmpty {
                buttonOfCity.setTitle("\(city)", forState: .Normal)
                print("获取地理位置信息，更新label")
            } else {
                print("没有获取到地理位置信息，无法更新label")
            }
            
            updatingLocation = false
            print("i stopped")
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
                            self.city = self.rangeOfCities(self.placemark!.locality!)}
                        if self.placemark?.subLocality != nil {self.district = (self.placemark?.subLocality)!}
                        if self.placemark?.thoroughfare != nil {self.street = (self.placemark?.thoroughfare)!}
                        if self.placemark?.name != nil {self.name = (self.placemark?.name)!}
                        
                        
                        //self.postalCode = (self.placemark?.postalCode)!
                        
                        geoInfo = GeoinfoModel(country: self.country, country_code: self.country_code, province: self.province, city: self.city, district: self.district, street: self.street, name: self.name)
                        GeoinfoModel.encode(geoInfo!)
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
    
    //获取总代理
    func appCloud() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}

