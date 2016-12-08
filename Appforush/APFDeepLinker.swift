//
//  APFDeepLinker.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 20/4/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

@objc class APFDeepLinker: NSObject {
    @objc static let sharedInstance = APFDeepLinker()
    
    var url: NSURL!
    var _enteredTheApp: Bool = false
    
    var enteredTheApp: Bool {
        get {
            return self._enteredTheApp
        }
        
        set(isEntered) {
            self._enteredTheApp = isEntered
            
            if isEntered && self.url != nil {
                self.handleUrl(self.url)
                self.url = nil
            }
        }
    }
    
    var topMostController: UIViewController {
        get {
            let root = UIApplication.sharedApplication().keyWindow?.rootViewController
            return self.topViewController(root!)
        }
    }
    
    func topViewController(root: UIViewController) -> UIViewController {
        if root.isKindOfClass(UINavigationController.self) == true {
            return self.topViewController((root as! UINavigationController).visibleViewController!)
        }
        else if root.isKindOfClass(UITabBarController.self) == true {
            return self.topViewController((root as! UITabBarController).selectedViewController!)
        }
        else if root.presentedViewController != nil {
            return self.topViewController(root.presentedViewController!)
        }
        else {
            return root
        }
    }
    
    func handleUrl(url: NSURL) {
        if !enteredTheApp {
            self.url = url
            return
            // to be handled later
        }
        
        let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        let query = urlComponents?.query
        var parameters = [String: String]()
        
        if let params = query?.componentsSeparatedByString("&") {
            for param: String in params {
                let parts = query?.componentsSeparatedByString("=")
                
                if parts?.count > 1 {
                    let key = parts?.first!.stringByRemovingPercentEncoding
                    let value = parts?.last!.stringByRemovingPercentEncoding
                    
                    if key != nil && value != nil {
                        parameters[key!] = value
                    }
                }
                
            }
        }
        
        if url.host == "apps" {
            if url.path?.hasPrefix("/view/") == true {
                let pth = url.path
                let iTunesId = (pth as NSString?)!.lastPathComponent
                let app = APFAppEntry(fromDictionary: ["id": iTunesId])
                
                let destination = UIApplication.sharedApplication().keyWindow?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("AppDescription") as! APFAppDescriptionViewController
                destination.title = ""
                destination.appEntry = app
                destination.appDescription = app.applicationDescription
                
                destination.isAppBuy = true
                
                if isPhone {
                    self.topMostController.navigationController?.pushViewController(destination, animated: true)
                }
                else {
                    destination.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                    destination.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                    
                    self.topMostController.presentViewController(destination, animated: true, completion: nil)
                }
            }
            else if url.path?.hasPrefix("/collection/") == true {
                let pth = url.path
                let collectionName = (pth as NSString?)!.lastPathComponent
                let collectionTitle = parameters["title"]
                
                let destination = UIApplication.sharedApplication().keyWindow?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("AppCollection") as! APFPadAppCollectionViewController
                
                if collectionTitle != nil {
                    destination.title = collectionTitle!
                }
                else {
                    destination.title = ""
                }
                
                destination.collectionType = .AppList
                destination.getAppEntries[0] = { (page: NSInteger) -> [AnyObject]! in
                    if (page == 1){
                        return APFPROJECTAPI.currentInstance().getCollectionApps(collectionName, page: page)
                    }
                    else{
                        return []
                    }
                }
                
                self.topMostController.navigationController?.pushViewController(destination, animated: true)
            }
        }
    }
}
