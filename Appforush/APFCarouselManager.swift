//
//  APFCarouselManager.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 14/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFCarouselManager: NSObject, iCarouselDataSource, iCarouselDelegate {
    
    var items: NSArray!
    var viewController: UIViewController!
    
    init(items: NSArray, viewController: UIViewController) {
        self.items = items
        self.viewController = viewController
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        if self.items != nil {
            return self.items.count
        }
        else {
            return 0
        }
    }
    
    @objc func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView: UIView?) -> UIView {
        var view = reusingView
        if self.items != nil {
            if view == nil {
                let itemData = items.objectAtIndex(index) as! NSDictionary
                let itemImageData = itemData.objectForKey("image") as! NSDictionary
                var imageUrl: String!
                
                let ratio: CGFloat = 2.22
                
                if(isPhone) {
                    imageUrl = itemImageData.objectForKey("iphone-\(Int(UIScreen.mainScreen().bounds.width))w@\(Int(UIScreen.mainScreen().scale))x") as? String
                    view = UIImageView(frame: CGRectMake(0, 0, self.viewController.view.bounds.width, CGFloat(floor(self.viewController.view.bounds.width / ratio))))
                    (view as! UIImageView!).image = UIImage(named: "DefaultBanner")
                }
                else {
                    imageUrl = itemImageData.objectForKey("ipad@2x") as? String
                    view = UIImageView(frame: CGRectMake(0, 0, 500, 225))
                    (view as! UIImageView!).image = UIImage(named: "DefaultBanner-iPad")
                    
                    view!.layer.cornerRadius = 16.0
                    view!.layer.masksToBounds = true
                }
                
                view!.contentMode = UIViewContentMode.ScaleAspectFill
                
                if imageUrl == nil {
                    return view!
                }
                
                let dl = APFDownloader(downloadURLString: imageUrl, withLifeTime: 24 * 60 * 60)

                dl.didFinishDownload = { (data: NSData!) -> Void in
                    var image = UIImage(data: data)
                    image = UIImage(CGImage: (image?.CGImage)!, scale: UIScreen.mainScreen().scale, orientation: UIImageOrientation.Up)
                    (view as! UIImageView!).image = image
                }
                
                dl.didFailDownload = { (error: NSError!) -> Void in
                    
                }
                
                dl.start()
            }
        }
        
        return view!
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch(option) {
        case iCarouselOption.Spacing:
            return 1.02
        case iCarouselOption.Wrap:
            return 1
        default:
            return value
        }
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        let itemData = items.objectAtIndex(index) as! NSDictionary
        //NSLog("SELECTED INDEX %d", index);
        if isPhone {
            if let appData = itemData["app"] as? NSDictionary {
                let appEntry = APFAppEntry(fromDictionary: appData as! [String : AnyObject])
                let destination = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("AppDescription") as! APFAppDescriptionViewController
                destination.title = ""
                destination.appEntry = appEntry
                destination.appDescription = appEntry.applicationDescription
                destination.isAppBuy = !appEntry.availableInPROJECT
                self.viewController.navigationController?.pushViewController(destination, animated: true)
            }
            else if let appList = itemData["collection"] as? String {
                let destination = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("AppCollection") as! APFPadAppCollectionViewController
                
                if let title = itemData["alt"] as? String {
                    destination.title = title
                }
                else {
                    destination.title = ""
                }
                
                destination.getAppEntries[0] = { (page: NSInteger) -> [AnyObject]! in
                    return APFPROJECTAPI.currentInstance().getAppListByURL(appList, page: page)
                }
                
                destination.collectionType = .AppList
                
                self.viewController.navigationController?.pushViewController(destination, animated: true)
            }
        }
        else {
            if let appData = itemData["app"] as? NSDictionary {
                let appEntry = APFAppEntry(fromDictionary: appData as! [String : AnyObject])
                let destination = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("AppDescription") as! APFAppDescriptionViewController
                
                destination.title = ""
                destination.appEntry = appEntry
                destination.appDescription = appEntry.applicationDescription
                destination.isAppBuy = !appEntry.availableInPROJECT
                
                destination.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                destination.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                
                self.viewController.viewDidDisappear(true) // TODO to stop carousel, should be revisited
                self.viewController.presentViewController(destination, animated: true, completion: nil)
            }
            else if let appList = itemData["collection"] as? String {
                let destination = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("AppCollection") as! APFPadAppCollectionViewController
                
                if let title = itemData["alt"] as? String {
                    destination.title = title
                }
                else {
                    destination.title = ""
                }
                
                destination.getAppEntries[0] = { (page: NSInteger) -> [AnyObject]! in
                    return APFPROJECTAPI.currentInstance().getAppListByURL(appList, page: page)
                }
                
                destination.collectionType = .AppList
                
                self.viewController.navigationController?.pushViewController(destination, animated: true)
            }
        }
    }
}
