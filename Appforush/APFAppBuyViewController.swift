//
//  APFAppBuyViewController.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 20/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

enum PaymentStatus {
    case NotStarted
    case Started
    case Cancelled
    case FinishedSuccessfully
    case Failed
}

protocol APFPaymentDelegateProtocol {
    func setPaymentStatus(_: PaymentStatus)
    func setPaymentOrderId(_: String!)
    func setPaymentErrorMessage(_: String!)
}

@objc class APFAppBuyViewController: UIViewController, UITextFieldDelegate, APFPaymentDelegateProtocol, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    var iTunesID: String!
    var appBuyData: APFAppBuyData!
    var paymentStatus: PaymentStatus = PaymentStatus.NotStarted
    var paymentOrderIdentifier: String!
    var paymentMessage: String!
    
    var tapBehindRecognizer: UITapGestureRecognizer!
    
    var navigationBarOriginalTint: UIColor!
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var appOriginalPrice: UILabel!
    @IBOutlet weak var appPrice: UILabel!
    
    @IBOutlet weak var appInfoView: UIView!
    
    @IBOutlet weak var userAppleID: UITextField!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var moreInfoButton: UIButton!

    @IBOutlet weak var appDataScrollView: UIScrollView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var hruleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var hrule2HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var paymentBoxBackground: UIImageView!
    
    @IBOutlet weak var appDataContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createAppleIdButton: UIButton!
    
    @IBAction func createAppleIdButtonClicked(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://id.PROJECT.ir/")!)
    }
    
    @IBAction func closeAppBuyModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showInAppStoreButtonClicked(sender: AnyObject) {
        let url = String(format:"http://itunes.apple.com/app/id%@", self.iTunesID)
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    @IBAction func helpButtonClicked(sender: AnyObject) {
        if let helpUrl = self.appBuyData.helpUrl {
            UIApplication.sharedApplication().openURL(NSURL(string: helpUrl)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            
        }
        else {
            self.widthConstraint.constant = UIScreen.mainScreen().bounds.width
        }
        
        //self.paymentBoxBackground.image = UIImage(named: "AppBg")
        
        if iTunesID == nil {
            return
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.hruleHeightConstraint.constant = 0.5
        self.hrule2HeightConstraint.constant = 0.5
        
        self.loadingView.hidden = false
        self.appDataScrollView.hidden = true
        
        self.appIcon.layer.cornerRadius = 12.0
        self.appIcon.clipsToBounds = true
        
        self.payButton.layer.cornerRadius = 3.0
        self.createAppleIdButton.layer.cornerRadius = 4.0
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.appBuyData = APFAppBuyData.getAppBuyData(self.iTunesID)
            
            if self.appBuyData == nil {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                if(self.appBuyData.status == "error") {
                    //NSLog("%@ > %@", self.appBuyData.status, self.appBuyData.errorCode)
                    
                    let dismissHandler = {(index: Int) -> (Void) in
                        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        else {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        
                        return
                    }
                    
                    switch(self.appBuyData.errorCode) {
                    case "BadRequest", "iTunesError":
                        let alert = SDCAlertView(title: "خطا در اتصال", message: "در حال حاضر امکان دریافت اطلاعات این اپ وجود ندارد. لطفاً مجدداً تلاش کنید.", delegate: nil, cancelButtonTitle: "بازگشت")
                        
                        alert.showWithDismissHandler(dismissHandler)
                        
                    case "iTunesAppNotFound":
                        let alert = SDCAlertView(title: "اپ ناموجود", message: "این اپ در اپ‌استور وجود ندارد.", delegate: nil, cancelButtonTitle: "بازگشت")
                        
                        alert.showWithDismissHandler(dismissHandler)
                        
                    case "FreeApp":
                        UIApplication.sharedApplication().openURL(NSURL(string: String(format: "itms-apps://itunes.apple.com/us/app/apple-store/id%@?mt=8",self.iTunesID))!);
                        dismissHandler(0);
                        return;
                        /*let alert = SDCAlertView(title: "اپ رایگان", message: "در حال حاضر این اپ رایگان می‌باشد و می‌توانید آن را از اپ‌استور مستقیماً دریافت کنید.", delegate: nil, cancelButtonTitle: "بازگشت")
                        
                        alert.addButtonWithTitle("مشاهده")
                        
                        alert.showWithDismissHandler({(index: Int) -> (Void) in
                            if index == 0 {
                                
                            }
                            else {
                                
                            }
                            
                            dismissHandler(0)
                            return
                        })
                        */
                    default:
                        let alert = SDCAlertView(title: "خطا در اتصال", message: "در حال حاضر امکان دریافت اطلاعات این اپ وجود ندارد. لطفاً مجدداً تلاش کنید.", delegate: nil, cancelButtonTitle: "بازگشت")
                        
                        alert.showWithDismissHandler(dismissHandler)
                    }
                }
                else if(self.appBuyData.status != "ok") {
                    
                }
                else {
                    self.appName.text  = self.appBuyData.appName
                    self.appOriginalPrice.text = String(format: "%.2f دلار", self.appBuyData.appOriginalPrice)
                    
                    let nf = NSNumberFormatter()
                    nf.groupingSeparator = ","
                    nf.groupingSize = 3
                    nf.usesGroupingSeparator = true
                    
                    self.appPrice.text = String(format: "%@ ریال", nf.stringFromNumber(self.appBuyData.appPrice)!)
                    self.userAppleID.text = self.appBuyData.userAppleID
                    
                    let iconDl = APFDownloader(downloadURLString: self.appBuyData.appIconURL, withLifeTime: 3600, useAppStoreUserAgent: true)
                    
                    iconDl.didFinishDownload = {(NSData data) -> Void in
                        if data == nil {
                            return
                        }
                        
                        self.appBuyData.appIcon = UIImage(data: data)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.appIcon.image = self.appBuyData.appIcon
                        }
                    }
                    
                    iconDl.start()
                    
                    self.loadingView.hidden = true
                    self.appDataScrollView.hidden = false
                    
                    if NSUserDefaults.standardUserDefaults().boolForKey("create-apple-id-message") == false {
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "create-apple-id-message")
                        
                        // Create Your Apple ID
                        let popTip = AMPopTip()
                        
                        popTip.shouldDismissOnTap = true
                        popTip.shouldDismissOnTapOutside = true
                        
                        popTip.font = UIFont(name: "IRANSans-Bold", size: 11.0)
                        popTip.popoverColor = UIColor.userBlue()
                        popTip.textColor = UIColor.whiteColor()
                        popTip.edgeMargin = 16.0
                        popTip.offset = 14.0
                        popTip.arrowSize = CGSizeMake(8.0, 5.0)
                        popTip.actionAnimation = AMPopTipActionAnimation.Float
                        popTip.showText("اپل آی‌دی ندارید؟ از این طریق می‌توانید به راحتی اپل آی‌دی خود را بسازید!", direction: AMPopTipDirection.Up, maxWidth: 200, inView: self.view, fromFrame: self.createAppleIdButton.superview!.convertRect(self.createAppleIdButton.bounds, toView: self.view))
                    }
                    
                    self.userAppleID.delegate = self
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHid:"), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    private func unregisterForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func keyboardWasHid(aNotification: NSNotification) {
        self.appDataScrollView.contentInset = UIEdgeInsetsZero
        self.appDataScrollView.scrollIndicatorInsets = UIEdgeInsetsZero
        self.appDataScrollView.setContentOffset(CGPointMake(0,0), animated: true)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        var info = aNotification.userInfo
        
        if info == nil || info![UIKeyboardFrameEndUserInfoKey] == nil {
            return;
        }
        
        var kbdSize = CGFloat(0.0)
        var scrollPoint = CGPointZero
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            kbdSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.height
            scrollPoint = CGPointMake(0.0, self.userAppleID.frame.origin.y - kbdSize - 15)
        }
        else {
            var bottom = CGFloat(0.0)
            
            if isOS8 {
                bottom = self.view.convertPoint(self.view.center, toView: nil).y + self.view.bounds.height / 2.0
                kbdSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.height - (768.0 - bottom)
            }
            else {
                bottom = self.view.convertPoint(self.view.center, toView: nil).x + self.view.bounds.height / 2.0
                kbdSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.width - (768.0 - bottom)
            }
            
            if kbdSize <= 1.0 {
                kbdSize = 0
                return
            }
            
            scrollPoint = CGPointMake(0.0, self.userAppleID.frame.origin.y - kbdSize - 15)
        }
        
        let contentInset = UIEdgeInsetsMake(0.0, 0.0, kbdSize, 0.0)
        self.appDataScrollView.contentInset = contentInset
        self.appDataScrollView.scrollIndicatorInsets = contentInset
        
        if self.userAppleID.isFirstResponder() {
            var aRect = self.view.frame
            aRect.size.height -= kbdSize
            
            if !CGRectContainsPoint(aRect, self.userAppleID.superview!.convertPoint(self.userAppleID.frame.origin, toView: self.appDataScrollView)) {
                self.appDataScrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.registerForKeyboardNotifications()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            /*self.tapBehindRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapBehind:"))
            self.tapBehindRecognizer.numberOfTapsRequired = 1
            self.tapBehindRecognizer.cancelsTouchesInView = false
            self.view.window?.addGestureRecognizer(self.tapBehindRecognizer)*/
        }
        
        let returnDismissHandler = {(index: Int) -> (Void) in
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            return
        }
        
        switch(self.paymentStatus) {
        case .NotStarted:
            break
            
        case .Failed:
            let alert = SDCAlertView(title: "خطا در پرداخت", message: "پرداخت شما با خطا همراه بود، لطفا دوباره سعی کنید یا با پشتیبانی تماس بگیرید.", delegate: nil, cancelButtonTitle: "تایید.")
            
            alert.show()
            
        case .FinishedSuccessfully:
            let alert = SDCAlertView(title: "خرید موفق", message: "خرید شما با موفقیت انجام شد. به زودی اطلاعات لازم را از طریق ایمیلی که وارد کرده‌اید دریافت خواهید نمود.", delegate: nil, cancelButtonTitle: "تایید")
            
            alert.showWithDismissHandler(returnDismissHandler)
            
        default:
            break
        }
    }
    
    func tapBehind(sender: UITapGestureRecognizer?) {
        if sender?.state == UIGestureRecognizerState.Ended {
            let location = sender?.locationInView(nil)
            if !self.view.pointInside(self.view.convertPoint(location!, fromView: self.view.window), withEvent: nil) {
                self.view.window?.removeGestureRecognizer(sender!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        self.unregisterForKeyboardNotifications()
        
        if self.tapBehindRecognizer != nil {
            self.view.window?.removeGestureRecognizer(self.tapBehindRecognizer)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.userAppleID.endEditing(true)
    }
    
    
    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "Payment" {
            if !APFAppBuyViewController.isValidEmail(self.userAppleID.text!) {
                let alert = SDCAlertView(title: "خطا", message: "لطفا یک آدرس ایمیل معتبر وارد کنید.", delegate: nil, cancelButtonTitle: "تایید")
                alert.show()
                
                return false
            }
        }
        
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Payment" {
            let userpi = APFPROJECTAPI.currentInstance()
            let destination = (segue.destinationViewController as! UINavigationController).topViewController as! APFAppBuyPaymentViewController
            destination.paymentUrl = String(format: self.appBuyData.paymentUrl, userpi.apfUserInfo.userId, self.userAppleID.text!.urlencode())
            destination.successUrl = self.appBuyData.successUrl
            destination.errorUrl = self.appBuyData.errorUrl
            destination.delegate = self
            
            self.paymentStatus = PaymentStatus.Started
        }
    }
    
    // MARK: - Payment Delegate
    func setPaymentStatus(status: PaymentStatus) {
        self.paymentStatus = status
    }
    
    func setPaymentOrderId(orderId: String!) {
        self.paymentOrderIdentifier = orderId
    }
    
    func setPaymentErrorMessage(errorMessage: String!) {
        self.paymentMessage = errorMessage
    }
}
