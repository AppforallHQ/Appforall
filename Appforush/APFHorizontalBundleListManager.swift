//
//  APFHorizontalAppListManager.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 5/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFHorizontalBundleListManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var data: NSArray!
    var images: [Int: UIImage] = [:]
    var viewController: UIViewController!
    var collectionView: UICollectionView!
    
    init(data: NSArray, viewController: UIViewController, collectionView: UICollectionView) {
        self.data = data
        self.viewController = viewController
        self.collectionView = collectionView
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let itemData = self.data[indexPath.item] as! NSDictionary
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bundleListCellIdentifier, forIndexPath: indexPath) as! APFHorizontalBundleListCell
        
        if let image = self.images[indexPath.item]  {
            cell.icon = image
        }
        else {
            cell.icon = UIImage(named: "DefaultBundle")
            
            let iconKey = String(format: "@%.0fx", arguments: [UIScreen.mainScreen().scale])
            
            if let imageUrls = itemData["image"] as? [String: String] {
                if let imageUrl = imageUrls[iconKey] {
                    let dl = APFDownloader(downloadURLString: imageUrl, withLifeTime: 3600)
                    cell.tag = indexPath.item
                    
                    dl.didFinishDownload = { (data: NSData!) -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            if cell.tag == indexPath.row {
                                if data == nil {
                                    return
                                }
                                
                                self.images[indexPath.item] = UIImage(data: data!)
                                cell.icon = self.images[indexPath.item]
                            }
                        }
                    }
                    
                    dl.start()
                }
            }
            
            /**/
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = self.data[indexPath.item] as! NSDictionary
        if let url = item.objectForKey("link") as? String {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
}
