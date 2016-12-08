//
//  APFHorizontalAppListManager.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 5/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFHorizontalAppListManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var data: NSArray!
    var viewController: UIViewController!
    var collectionView: UICollectionView!
    
    init(data: NSArray, viewController: UIViewController, collectionView: UICollectionView) {
        self.data = data
        self.viewController = viewController
        self.collectionView = collectionView
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let itemData = self.data[indexPath.item] as! APFAppEntry
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(appListCellIdentifier, forIndexPath: indexPath) as! APFHorizontalAppListCell

        cell.title = itemData.applicationName
        cell.size = itemData.applicationSize
        
        if let appIcon = itemData.applicationLargeIcon {
            cell.icon = itemData.applicationLargeIcon
        }
        else {
            cell.icon = UIImage(named: "noIconForApps")
                
            itemData.iconDownloadedHandler = { () -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    //cell.icon = itemData.applicationLargeIcon
                    self.collectionView.reloadData()
                }
            }
            
            itemData.startDownloadIconWithSize(IconSize.LargeIcon)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let app = self.data[indexPath.item] as! APFAppEntry
        
        if(UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            let appDescriptionViewController = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("AppDescription") as! APFAppDescriptionViewController
            appDescriptionViewController.title = ""
            appDescriptionViewController.appEntry = app
            appDescriptionViewController.appDescription = app.applicationDescription
            appDescriptionViewController.parent = self.viewController;
            appDescriptionViewController.isAppBuy = !app.availableInPROJECT
            self.viewController.navigationController?.pushViewController(appDescriptionViewController, animated: true)
        }
        else {
            let appDescriptionViewController = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("AppDescription") as! APFAppDescriptionViewController
            
            appDescriptionViewController.title = ""
            appDescriptionViewController.appEntry = app
            appDescriptionViewController.appDescription = app.applicationDescription
            appDescriptionViewController.parent = self.viewController
            appDescriptionViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            appDescriptionViewController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            appDescriptionViewController.isAppBuy = !app.availableInPROJECT
            
            self.viewController.viewDidDisappear(true) // TODO to stop carousel, should be revisited
            self.viewController.presentViewController(appDescriptionViewController, animated: true, completion: nil)
            
        }
    }
}
