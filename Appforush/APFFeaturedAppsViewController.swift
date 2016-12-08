//
//  APFFeaturedAppsViewController.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 4/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

let isOS8 = !(UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending)

let isPhone = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone)

let carouselHeight = isPhone ? 144 : 240
let hSpacing = isPhone ? 15 : 15
let vSpacing = isPhone ? 15 : 15

func UIColorFromHex(hexString: NSString) -> UIColor {
    var cleanString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
    cleanString = cleanString.stringByAppendingString("ff")
    
    var baseValue: UInt32 = 0
    NSScanner(string: cleanString).scanHexInt(&baseValue)
    
    let red = CGFloat((baseValue >> 24) & 0xff) / 255.0
    let green = CGFloat((baseValue >> 16) & 0xff) / 255.0
    let blue = CGFloat((baseValue >> 8) & 0xff) / 255.0
    let alpha = CGFloat((baseValue >> 0) & 0xff) / 255.0
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

class APFFeaturedAppsViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var loadingView: UIActivityIndicatorView!
    var appListManagers: [APFHorizontalAppListManager] = []
    var bundleListManagers: [APFHorizontalBundleListManager] = []
    var carouselManagers: [APFCarouselManager] = []
    var controlsDict: [String: UIView] = [:]
    var controlsList: [String] = []
    var carouselIndexes: [Int] = []
    var carouselTimer: NSTimer!
    
    func scrollCarousels() {
        for index in carouselIndexes {
            let item  = controlsDict[controlsList[index]] as! iCarousel
            item.scrollByNumberOfItems(1, duration: 0.5)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBarController?.edgesForExtendedLayout = UIRectEdge.None
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "AFALogo.png"))
        self.title = "خانه"
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        self.view.insertSubview(self.scrollView, atIndex: 0)
        
        self.scrollView.hidden = true
        self.view.backgroundColor = UIColor.whiteColor()
        //self.edgesForExtendedLayout = UIRectEdge.All
        
        self.loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        var frame = self.loadingView.frame
        
        if(isOS8 || UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2
            frame.origin.y = self.view.frame.size.height / 2 - frame.size.height / 2
        }
        else {
            frame.origin.y = self.view.frame.size.width / 2 - frame.size.width / 2
            frame.origin.x = self.view.frame.size.height / 2 - frame.size.height / 2
        }
        
        self.loadingView.frame = frame
        self.view.addSubview(self.loadingView)
        self.loadingView.hidesWhenStopped = true
        self.view.bringSubviewToFront(self.loadingView)
        self.loadingView.startAnimating()
        
        self.parentViewController?.automaticallyAdjustsScrollViewInsets = false
        self.automaticallyAdjustsScrollViewInsets = true
        
        createFeaturedPage()
    }
    
    func createFeaturedPage() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let data = APFPROJECTAPI.currentInstance().getFeaturedPageData()
            //var json = JSON(data: data)
            
            if data == nil {
                // TODO handle this case
                return
            }
            
            var error: NSError?
            var json: AnyObject!
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            } catch let error1 as NSError {
                error = error1
                json = nil
            } catch {
                fatalError()
            }
            dispatch_async(dispatch_get_main_queue()) {
                var controlIndex = 0
                var controlName: String = ""
                var controlsLayout: String = "V:|"
                
                let sectionsCount = ((json as? NSDictionary)?.objectForKey("sections") as! NSArray).count
                
                for sectionObj in ((json as? NSDictionary)?.objectForKey("sections") as! NSArray) {
                    let section = sectionObj as! NSDictionary
                    let type = section.objectForKey("type") as! NSString
                    
                    controlName = "\(type)_\(controlIndex)"
                    
                    switch(type) {
                    case "carousel":
                        self.controlsList.append(controlName)
                        self.controlsDict[controlName] = iCarousel()
                        
                        let carouselItems = section.objectForKey("items") as! NSArray
                        self.carouselManagers.append(APFCarouselManager(items: carouselItems, viewController: self))
                        
                        let control = self.controlsDict[controlName] as! iCarousel
                        control.translatesAutoresizingMaskIntoConstraints = false
                        if(isPhone) {
                            control.type = iCarouselType.Linear
                        }
                        else {
                            control.type = iCarouselType.Linear
                        }
                        control.pagingEnabled = true
                        control.delegate = self.carouselManagers.last
                        control.dataSource = self.carouselManagers.last
                        
                        self.carouselIndexes.append(self.controlsList.count - 1)
                        
                        self.scrollView.addSubview(control)
                        
                        //var constraint_H = NSLayoutConstraint(item: control, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0)
                        
                        let constraint_H2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[control]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control])
                        
                        var cHeight = CGFloat(carouselHeight)
                        
                        if isPhone {
                            cHeight = UIScreen.mainScreen().bounds.width / 2.22
                        }
                        
                        let constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[control(\(cHeight))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control])
                        
                        control.addConstraints(constraint_V)
                        //self.view.addConstraint(constraint_H)
                        self.view.addConstraints(constraint_H2)
                        
                        controlsLayout += "[\(controlName)]-0-"
                        
                    case "applist_horizontal":
                        var subControlName = "\(controlName)_header"
                        
                        // First, we create the header
                        let colorStr = section.objectForKey("color") as! String
                        let headerColor = UIColorFromHex(colorStr)
                        let headerText = section.objectForKey("title") as! String
                        
                        self.controlsList.append(subControlName)
                        if let linkTarget: AnyObject = section.objectForKey("link") {
                            self.controlsDict[subControlName] = APFSectionHeader(text: headerText, color: headerColor, link: linkTarget as? String, viewController: self)
                        }
                        else {
                            self.controlsDict[subControlName] = APFSectionHeader(text: headerText, color: headerColor, link: nil, viewController: self)
                        }
                        
                        let control = self.controlsDict[subControlName] as! APFSectionHeader
                        
                        control.translatesAutoresizingMaskIntoConstraints = false
                        self.scrollView.addSubview(control)
                        
                        //var constraint_H = NSLayoutConstraint(item: control, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0)
                        
                        let constraint_H2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[control]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control])
                        
                        var constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[control(43)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control])
                        
                        control.addConstraints(constraint_V)
                        //self.view.addConstraint(constraint_H)
                        self.view.addConstraints(constraint_H2)
                        
                        if controlIndex > 0 {
                            controlsLayout += "[\(subControlName)]-10-"
                        }
                        else {
                            controlsLayout += "-0-[\(subControlName)]-10-"
                        }
                        
                        // Second, we create the app list
                        subControlName = "\(controlName)_cv"
                        self.controlsList.append(subControlName)
                        
                        let layout = APFHorizontalAppListLayout()
                        self.controlsDict[subControlName] = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
                        
                        let control2 = self.controlsDict[subControlName] as! UICollectionView
                        
                        let appsList = APFPROJECTAPI.currentInstance().processAppsArray(section.objectForKey("items") as! [AnyObject])
                        self.appListManagers.append(APFHorizontalAppListManager(data: appsList, viewController: self, collectionView: control2))
                        
                        control2.registerClass(APFHorizontalAppListCell.self, forCellWithReuseIdentifier: appListCellIdentifier)
                        control2.translatesAutoresizingMaskIntoConstraints = false
                        control2.showsHorizontalScrollIndicator = false
                        control2.backgroundColor = UIColor.clearColor()
                        control2.delegate = self.appListManagers.last
                        control2.dataSource = self.appListManagers.last
                        
                        self.scrollView.addSubview(control2)
                        
                        constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[control(130)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control2])
                        
                        control2.addConstraints(constraint_V)
                        
                        self.view.addConstraint(NSLayoutConstraint(item: control2, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0))
                        self.view.addConstraint(NSLayoutConstraint(item: control2, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
                        
                        controlsLayout += "[\(subControlName)]-10-"
                        
                        if controlIndex != sectionsCount - 1 { // Third, we draw the line
                            subControlName = "\(controlName)_hr"
                            self.controlsList.append(subControlName)
                            self.controlsDict[subControlName] = UIView()
                            let control3 = self.controlsDict[subControlName]
                            
                            control3?.translatesAutoresizingMaskIntoConstraints = false
                            control3?.backgroundColor = UIColor(white: 245.0/255, alpha: 1.0)
                            control3?.layer.borderWidth = 0.5
                            control3?.layer.borderColor = UIColor(white:224.0/255, alpha: 1.0).CGColor
                            
                            self.scrollView.addSubview(control3!)
                            
                            let constraint_H = NSLayoutConstraint(item: control3!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)
                            
                            let constraint_H2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[control]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control3!, "view": self.view])
                            
                            constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[control(4.5)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control3!])
                            
                            control3?.addConstraints(constraint_V)
                            self.view.addConstraint(constraint_H)
                            self.view.addConstraints(constraint_H2)
                            
                            controlsLayout += "[\(subControlName)]-0-"
                        }
                        
                    case "bundlelist_horizontal":
                        self.controlsList.append(controlName)
                        self.controlsDict[controlName] = UICollectionView(frame: CGRectZero, collectionViewLayout: APFHorizontalBundleListLayout())
                        
                        let bundles = section.objectForKey("bundles") as! NSArray
                        self.bundleListManagers.append(APFHorizontalBundleListManager(data: bundles, viewController: self, collectionView: self.controlsDict[controlName] as! UICollectionView))
                        
                        let control = self.controlsDict[controlName] as! UICollectionView
                        
                        control.registerClass(APFHorizontalBundleListCell.self, forCellWithReuseIdentifier: bundleListCellIdentifier)
                        control.translatesAutoresizingMaskIntoConstraints = false
                        control.showsHorizontalScrollIndicator = false
                        control.backgroundColor = UIColor.clearColor()
                        control.delegate = self.bundleListManagers.last
                        control.dataSource = self.bundleListManagers.last
                        
                        self.scrollView.addSubview(control)
                        
                        var constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[control(110)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control])
                        
                        control.addConstraints(constraint_V)
                        
                        self.view.addConstraint(NSLayoutConstraint(item: control, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0))
                        self.view.addConstraint(NSLayoutConstraint(item: control, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
                        
                        controlsLayout += "[\(controlName)]-0-"
                        
                        if controlIndex != sectionsCount - 1 { // This code is very similar to the line under the horizontal app list. Please consider refactoring.
                            let subControlName = "\(controlName)_hr"
                            self.controlsList.append(subControlName)
                            self.controlsDict[subControlName] = UIView()
                            let control3 = self.controlsDict[subControlName]
                            
                            control3?.translatesAutoresizingMaskIntoConstraints = false
                            control3?.backgroundColor = UIColor(white: 245.0/255, alpha: 1.0)
                            
                            self.scrollView.addSubview(control3!)
                            
                            let constraint_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[control]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control3!, "view": self.view])
                            
                            constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[control(1.0)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["control": control3!])
                            
                            control3?.addConstraints(constraint_V)
                            self.view.addConstraints(constraint_H)
                            
                            controlsLayout += "[\(subControlName)]-0-"
                        }
                        
                    default:
                        NSLog("Not a known type: %@", type)
                    }
                    
                    controlIndex++
                }
                
                self.scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("\(controlsLayout)|", options: NSLayoutFormatOptions(), metrics: nil, views: self.controlsDict))
                
                self.loadingView.stopAnimating()
                //self.loadingView.removeFromSuperview()
                self.scrollView.hidden = false;
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if carouselTimer == nil {
            carouselTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("scrollCarousels"), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if carouselTimer == nil {
            return
        }
        
        carouselTimer.invalidate()
        carouselTimer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
