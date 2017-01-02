//
//  SupportTableTableViewController.swift
//  RainReminder
//
//  Created by 童超 on 16/4/12.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit
import StoreKit

protocol SupportTableViewControllerDelegate: class{
    func supportTableViewController(_ controller: SupportTableViewController)
}


class SupportTableViewController: UITableViewController,SKStoreProductViewControllerDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate, TimePickerViewControllerDelegate {
    
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var row1ImageView: UIImageView!
    @IBOutlet weak var row2ImageView: UIImageView!
    @IBOutlet weak var row3ImageView: UIImageView!
    @IBOutlet weak var row1WidthCon: NSLayoutConstraint!
    @IBOutlet weak var row2WidthCon: NSLayoutConstraint!
    @IBOutlet weak var row3WidthCon: NSLayoutConstraint!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var labelOfremind: UILabel!
    
    weak var delegate:SupportTableViewControllerDelegate?
    var request: SKProductsRequest!
    var requestPay = false
    var dataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel = appCloud().dataModel
        SKPaymentQueue.default().add(self)
        
        //let userDefaults = NSUserDefaults.standardUserDefaults()
        labelOfremind.text = dataModel.dueString
        notifySwitch.isOn = dataModel.shouldRemind
    }
    
    deinit{
        if requestPay{
            request.delegate = nil
        }
        SKPaymentQueue.default().remove(self)
    }
    
    func shoudldNotification(_ should: Bool){
        if should{
            dataModel.shouldRemind = true
            let notificationSettings = UIUserNotificationSettings(types: [.alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            labelOfremind.text = dataModel.dueString
        }else{
            self.dataModel.dueString = "08:00"
            self.dataModel.shouldRemind = false
            labelOfremind.text = ""
        }
        dataModel.saveData()
    }
    
    //MARK: - 内购
    
    func requestProducts(_ pid: String){
        let set: Set<String> = [pid]
        request = SKProductsRequest(productIdentifiers: set)
        request.delegate = self
        request.start()
        requestPay = true
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            buyProduct(response.products[0])
        } else {
            showAlert("感谢你的支持,暂时无法购买,请稍后重试")
            row1WidthCon.constant = 0
            hiddenLoadingImageView(row1ImageView)
            row2WidthCon.constant = 0
            hiddenLoadingImageView(row2ImageView)
            row3WidthCon.constant = 0
            hiddenLoadingImageView(row3ImageView)

        }
    }
    
    func buyProduct(_ product: SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        print("请求线程购买")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            print("队列状态变化 \(transaction.payment.productIdentifier)==\(transaction.transactionState.rawValue))")
            switch transaction.transactionState {
            case .purchasing:
                print("商品添加进列表 \(transaction.payment.productIdentifier)")
            case .purchased:
                switch transaction.payment.productIdentifier{
                case "rainreminder1":
                    row1WidthCon.constant = 0
                    hiddenLoadingImageView(row1ImageView)
                case "rainreminder6":
                    row2WidthCon.constant = 0
                    hiddenLoadingImageView(row2ImageView)
                case "rainreminder18":
                    row3WidthCon.constant = 0
                    hiddenLoadingImageView(row3ImageView)
                default:
                    break
                }
                self.finishTransaction(transaction)
            case .failed:
                if transaction.error?._code == 0{
                    showAlert("感谢你的支持,无法连接到 iTunes Store,请稍后重试")
                }
                switch transaction.payment.productIdentifier{
                case "rainreminder1":
                    row1WidthCon.constant = 0
                    hiddenLoadingImageView(row1ImageView)
                case "rainreminder6":
                    row2WidthCon.constant = 0
                    hiddenLoadingImageView(row2ImageView)
                case "rainreminder18":
                    row3WidthCon.constant = 0
                    hiddenLoadingImageView(row3ImageView)
                default:
                    break
                }
                print("交易失败error==\(transaction.error)")
                self.finishTransaction(transaction)
            case .restored:
                print("已经购买过商品")
                self.finishTransaction(transaction)
            case .deferred:
                print("Allow the user to continue using your app.")
                break
            }
        }
    }
    
    
    func finishTransaction(_ transaction:SKPaymentTransaction) {
        // 将交易从交易队列中删除
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tableview
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section,indexPath.row){
            
        case(0,1):
            let timepickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "timePickerViewController") as! TimePickerViewController
            self.present(timepickerViewController, animated: true) { () -> Void in
                timepickerViewController.delegate = self
            }
        case (1,0):
            loadingAnimation(loadingImageView)
            
            //self.hiddenLoadingImageView(self.loadingImageView)
            //self.showAlert("加载商店页面出现错误,请稍后重试")
            
            let storeViewController = SKStoreProductViewController()
            storeViewController.delegate = self
            storeViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : 1102738128], completionBlock: { (result, error) -> Void in
                if result{
                    self.present(storeViewController, animated: true, completion: { () -> Void in
                        self.hiddenLoadingImageView(self.loadingImageView)
                        
                    })
                    //self.hiddenLoadingImageView(self.loadingImageView)
                    //self.showAlert("加载商店页面出现错误,请稍后重试")
                }else{
                    self.hiddenLoadingImageView(self.loadingImageView)
                    self.showAlert("加载商店页面出现错误,请稍后重试")
                }
            })
        case (2,0):
            requestProducts("rainreminder1")
            row1WidthCon.constant = row1ImageView.bounds.height
            loadingAnimation(row1ImageView)
        case (2,1):
            requestProducts("rainreminder6")
            row2WidthCon.constant = row2ImageView.bounds.height
            loadingAnimation(row2ImageView)
        case (2,2):
            requestProducts("rainreminder18")
            row3WidthCon.constant = row3ImageView.bounds.height
            loadingAnimation(row3ImageView)
        case (2,3):
            let userDefaults = UserDefaults.standard
            let firstTime = userDefaults.bool(forKey: "FirstTime")
            if !firstTime{
                userDefaults.set(true, forKey: "FirstTime")
                userDefaults.synchronize()
                
                let loginedViewController = self.storyboard?.instantiateViewController(withIdentifier: "viewController") as! HomeController
                self.present(loginedViewController, animated: true) { () -> Void in
                    
                }
            }
        case (2,4):
            let request = WBAuthorizeRequest()
            request.redirectURI = "https://api.weibo.com/oauth2/default.html"
            request.scope = "all"
            request.userInfo = [
                "SSO_From": "ViewController"
            ]
            WeiboSDK.send(request)
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func hiddenLoadingImageView(_ imageView: UIImageView){
        imageView.layer.removeAllAnimations()
        imageView.isHidden = true
    }
    
    func showAlert(_ message: String){
        
        let alert = UIAlertController(title: "加载错误", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "好的", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Time picker
    func timePickerViewControllerDidSelect(_ controller: TimePickerViewController, didSelectTime time: String) {
        dataModel.dueString = time
        shoudldNotification(true)
        notifySwitch.isOn = dataModel.shouldRemind
        dataModel.saveData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func timePickerViewControllerDidCancel(_ controller: TimePickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func notifyOn(_ sender: UISwitch) {
        
        shoudldNotification(sender.isOn)
        
    }
    
    //MARK: - dissmiss view to main
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offSety = scrollView.contentOffset.y
        
        if offSety < -50 && decelerate{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - 获取总代理
    func appCloud() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}
