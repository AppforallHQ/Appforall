//
//  APFAppBuyData.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 30/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

let APPBUY_INFO_URL = "\(API_ROOT)shop/info/?id=%@&aid=%@&userid=%@&appid=%@"

class APFAppBuyData: NSObject {
    
    var status: String!
    var errorCode: String!
    
    var iTunesID: String!
    var iTunesURL: String!
    var appName: String!
    var appOriginalPrice: Float! = 0.0
    var appPrice: Int! = 0
    var appIconURL: String!
    var appIcon: UIImage!
    var userAppleID: String!
    
    var paymentUrl: String!
    var successUrl: String!
    var errorUrl: String!
    var helpUrl: String!
    
    class func getAppBuyDataURL(iTunesID: String) -> String {
        let userpi = APFPROJECTAPI.currentInstance()
        return String(format: APPBUY_INFO_URL, userpi.dID, userpi.idfv, userpi.apfUserInfo.userId, iTunesID)
    }
    
    class func getAppBuyData(iTunesID: String) -> APFAppBuyData! {
        let res = APFAppBuyData()
        let dataUrl = getAppBuyDataURL(iTunesID as String)
        let dl = APFDownloader(downloadURLString: dataUrl, withLifeTime: 0)
        let data = dl.downloadImmediate()
        
        if data == nil {
            res.status = "error"
            res.errorCode = "iTunesError"
            return res
        }
        
        var json = JSON(data: data)
        
        if let status = json["status"].string {
            res.status = json["status"].stringValue
        }
        else {
            res.status = "error"
        }
        
        if res.status == "error" {
            res.errorCode = json["code"].string
            return res
        }
        else if res.status != "ok" {
            return nil
        }
        
        if let appData = json["app"].dictionary {
            res.iTunesID = iTunesID
            res.iTunesURL = appData["appstore_url"]?.string
            res.appName = appData["name"]?.stringValue
            res.appIconURL = appData["icon_url"]?.string
            res.appOriginalPrice = appData["original_price"]?.float
            res.appPrice = appData["price"]?.int
            res.paymentUrl = appData["payment_url"]?.string
            res.successUrl = appData["success_url"]?.string
            res.errorUrl = appData["error_url"]?.string
            res.helpUrl = appData["help_url"]?.string
        }
        
        if let userData = json["user"].dictionary {
            res.userAppleID = userData["apple_id"]?.string
        }
        
        return res
    }
    
    func getPaymentUrl() {
        
    }
   
}
