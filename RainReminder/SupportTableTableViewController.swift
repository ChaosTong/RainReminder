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
    func supportTableViewController(controller: SupportTableViewController)
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
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        //let userDefaults = NSUserDefaults.standardUserDefaults()
        labelOfremind.text = dataModel.dueString
        notifySwitch.on = dataModel.shouldRemind
    }
    
    deinit{
        if requestPay{
            request.delegate = nil
        }
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    func shoudldNotification(should: Bool){
        if should{
            dataModel.shouldRemind = true
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            labelOfremind.text = dataModel.dueString
        }else{
            self.dataModel.dueString = "08:00"
            self.dataModel.shouldRemind = false
            labelOfremind.text = ""
        }
        dataModel.saveData()
    }
    
    //MARK: - 内购
    
    func requestProducts(pid: String){
        let set: Set<String> = [pid]
        request = SKProductsRequest(productIdentifiers: set)
        request.delegate = self
        request.start()
        requestPay = true
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
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
    
    func buyProduct(product: SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        print("请求线程购买")
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            print("队列状态变化 \(transaction.payment.productIdentifier)==\(transaction.transactionState.rawValue))")
            switch transaction.transactionState {
            case .Purchasing:
                print("商品添加进列表 \(transaction.payment.productIdentifier)")
            case .Purchased:
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
            case .Failed:
                if transaction.error?.code == 0{
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
            case .Restored:
                print("已经购买过商品")
                self.finishTransaction(transaction)
            case .Deferred:
                print("Allow the user to continue using your app.")
                break
            }
        }
    }
    
    
    func finishTransaction(transaction:SKPaymentTransaction) {
        // 将交易从交易队列中删除
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tableview
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.section,indexPath.row){
            
        case(0,1):
            let timepickerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("timePickerViewController") as! TimePickerViewController
            self.presentViewController(timepickerViewController, animated: true) { () -> Void in
                timepickerViewController.delegate = self
            }
        case (1,0):
            loadingAnimation(loadingImageView)
            
            self.hiddenLoadingImageView(self.loadingImageView)
            self.showAlert("加载商店页面出现错误,请稍后重试")
            
            let storeViewController = SKStoreProductViewController()
            storeViewController.delegate = self
            storeViewController.loadProductWithParameters([SKStoreProductParameterITunesItemIdentifier : 1102738128], completionBlock: { (result, error) -> Void in
                if result{
//                    self.presentViewController(storeViewController, animated: true, completion: { () -> Void in
//                        self.hiddenLoadingImageView(self.loadingImageView)
//                        
//                    })
                    self.hiddenLoadingImageView(self.loadingImageView)
                    self.showAlert("加载商店页面出现错误,请稍后重试")
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
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let firstTime = userDefaults.boolForKey("FirstTime")
            if !firstTime{
                userDefaults.setBool(true, forKey: "FirstTime")
                userDefaults.synchronize()
                
                let loginedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("viewController") as! ViewController
                self.presentViewController(loginedViewController, animated: true) { () -> Void in
                    
                }
                
            }
        default:
            return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func hiddenLoadingImageView(imageView: UIImageView){
        imageView.layer.removeAllAnimations()
        imageView.hidden = true
    }
    
    func showAlert(message: String){
        
        let alert = UIAlertController(title: "加载错误", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "好的", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: - Time picker
    func timePickerViewControllerDidSelect(controller: TimePickerViewController, didSelectTime time: String) {
        dataModel.dueString = time
        shoudldNotification(true)
        notifySwitch.on = dataModel.shouldRemind
        dataModel.saveData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func timePickerViewControllerDidCancel(controller: TimePickerViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func notifyOn(sender: UISwitch) {
        
        shoudldNotification(sender.on)
        
    }
    
    //MARK: - dissmiss view to main
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offSety = scrollView.contentOffset.y
        
        if offSety < -50 && decelerate{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //MARK: - 获取总代理
    func appCloud() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
}
