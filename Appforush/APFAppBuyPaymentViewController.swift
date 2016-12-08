//
//  APFAppBuyPaymentViewController.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 7/2/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFAppBuyPaymentViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    var paymentUrl: String!
    var successUrl: String!
    var errorUrl: String!
    
    var delegate: APFPaymentDelegateProtocol!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: paymentUrl)!))
        
        self.cancelButton.enabled = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        //NSLog("Thanks URL: %@", successUrl)
        
        if let urlStr = webView.request?.URL!.absoluteString {
            //NSLog("Current URL: %@", urlStr)
        
            if urlStr == self.successUrl {
                let status = webView.stringByEvaluatingJavaScriptFromString("userPaymentStatus();")
                
                if status == nil || status == "" {
                    // some kind of error happened.
                }
                else if status?.hasPrefix("OK,") == true {
                    let orderId = status?.componentsSeparatedByString(", ").last
                    
                    if self.delegate != nil {
                        self.delegate.setPaymentOrderId(orderId)
                        self.delegate.setPaymentStatus(PaymentStatus.FinishedSuccessfully)
                    }
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    if self.delegate != nil {
                        self.delegate.setPaymentStatus(PaymentStatus.Failed)
                    }
                }
            }
            else if urlStr == self.errorUrl {
                let status = webView.stringByEvaluatingJavaScriptFromString("userPaymentStatus();")
                var error: String! = nil
                
                if status == nil || status == "" {
                    
                }
                else {
                    error = status?.componentsSeparatedByString(", ").last
                }
                
                if self.delegate != nil {
                    self.delegate.setPaymentStatus(PaymentStatus.Failed)
                    self.delegate.setPaymentErrorMessage(error)
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.cancelButton.enabled = true
            }
        }
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if self.delegate != nil {
            self.delegate.setPaymentStatus(PaymentStatus.Cancelled)
        }
    }
}
