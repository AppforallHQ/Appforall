//
//  APFPadAppCollectionViewController.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 22/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

let reuseIdentifier = "PadAppCollectionCell"
let catReuseIdentifier = "PadAppCollectionCategoryCell"
let searchReuseIdentifier = "PadAppSearchCollectionCell"
let newSearchReuseIdentifier = "PadAppSearchNew"
let loadingReuseIdentifier = "PadAppLoadingCollectionCell"
let typeSwitchReuseIdentifier = "PROJECTTypeSwitchCell"
let similarReuseIdentifier = "PadAppCollectionThreeCell"

let PAD_CELL_ITEM_WIDTH: CGFloat = 316.0
let PAD_CELL_ITEM_HEIGHT: CGFloat = 80.0
let PAD_CELL_CAT_ITEM_HEIGHT: CGFloat = 80.0
let PAD_CELL_ITEM_SPACING: CGFloat = 0.0

let categoriesSpacingConstant: CGFloat = 4.0

@objc enum AppCollectionType: Int {
    case Categories
    case AppSearch
    case AppList
    case AppBuyList
    case SimilarApps
    case CategoriesSelection
}

enum APFAppCollectionItemState: Int {
    case Unknown
    case Exists
    case InQueue
    case AppBuy
}

class APFPadAppCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var collectionType: AppCollectionType = AppCollectionType.Categories
    
    var searchBarView: UISearchBar!
    var searchAPI: APFSearchAPI!
    var searchQuery:  String!
    
    var searchId = 0
    
    var isAppBuy = false
    
    var parent: APFPadAppCollectionViewController! = nil
    
    var selectedCategory: String! = "All"
    var selectedImage: UIImage! = UIImage(named: "CategorySelect")
    
    
    var tabIndex: Int = 0
    
    var appEntries: [[APFAppEntry]] = [[]]
    var page: [Int] = [0]
    var getAppEntries: [((Int) -> ([AnyObject]!))!] = [nil]
    @objc var getAppEntriesObjC: ((Int) -> ([AnyObject]!))! = nil
    var didReachEndOfList: [((UIViewController) -> (Void))!] = [nil]
    var updating = false
    
    var showActionButton = true
    
    var noResultView: UIView! = nil
    
    
    
    static var categories: [[String:AnyObject!]] = [
        ["CellImage": UIImage(named: "CategoryBooks"), "CellText": "کتاب", "CellFeed": "Book"],
        ["CellImage": UIImage(named: "CategoryAll"), "CellText": "همه", "CellFeed": "All"],
        ["CellImage": UIImage(named: "CategoryBusiness"), "CellText": "کسب و کار", "CellFeed": "Business"],
        ["CellImage": UIImage(named: "CategoryEducation"), "CellText": "آموزش", "CellFeed": "Education"],
        ["CellImage": UIImage(named: "CategoryEntertainment"), "CellText": "سرگرمی", "CellFeed": "Entertainment"],
        ["CellImage": UIImage(named: "CategoryFinance"), "CellText": "سرمایه گذاری", "CellFeed": "Finance"],
        ["CellImage": UIImage(named: "CategoryGames"), "CellText": "بازی", "CellFeed": "Games"],
        ["CellImage": UIImage(named: "CategoryLifestyle"), "CellText": "سبک زندگی", "CellFeed": "Lifestyle"],
        ["CellImage": UIImage(named: "CategoryMedical"), "CellText": "پزشکی", "CellFeed": "Medical"],
        ["CellImage": UIImage(named: "CategoryMusic"), "CellText": "موسیقی", "CellFeed": "Music"],
        ["CellImage": UIImage(named: "CategoryNavigation"), "CellText": "راهبری", "CellFeed": "Navigation"],
        ["CellImage": UIImage(named: "CategoryNews"), "CellText": "اخبار", "CellFeed": "News"],
        ["CellImage": UIImage(named: "CategoryPhotoVideo"), "CellText": "عکس و ویدیو", "CellFeed": "Photo & Video"],
        ["CellImage": UIImage(named: "CategoryProductivity"), "CellText": "افزایش کارایی", "CellFeed": "Productivity"],
        ["CellImage": UIImage(named: "CategoryReference"), "CellText": "منابع", "CellFeed": "Reference"],
        ["CellImage": UIImage(named: "CategorySocialNetworking"), "CellText": "شبکه اجتماعی", "CellFeed": "Social Networking"],
        ["CellImage": UIImage(named: "CategorySports"), "CellText": "ورزش", "CellFeed": "Sports"],
        ["CellImage": UIImage(named: "CategoryTravel"), "CellText": "مسافرت", "CellFeed": "Travel"],
        ["CellImage": UIImage(named: "CategoryUtilities"), "CellText": "ابزار", "CellFeed": "Utilities"],
        ["CellImage": UIImage(named: "CategoryWeather"), "CellText": "آب و هوا", "CellFeed": "Weather"]
    ]
    /*var tagCategories: [[String:AnyObject!]] = [
        ["CellImage": UIImage(named: "CategoryPersian"), "CellText": "فارسی", "CellFeed": "Persian"]
    ]*/
    
    let checkImage = UIImage(named: "AppTickBlue")
    let plusImage = UIImage(named: "AppPlusRed")
    let checkGreenImage = UIImage(named: "AppTickGreen")
    let checkColor = UIColor(red: 48.0/255.0, green:144.0/255.0, blue:233.0/255.0, alpha:1.0)
    let plusColor = UIColor(red: 243.0/255.0, green:110.0/255.0, blue:79.0/255.0, alpha:1.0)
    let checkGreenColor = UIColor(red: 27.0/255.0, green:197.0/255.0, blue:27.0/255.0, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.getAppEntriesObjC != nil)
        {
            self.getAppEntries[0] = self.getAppEntriesObjC
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad && (APFPadAppCollectionViewController.categories[1]["CellFeed"] as! String) == "All"
        {
            let tmp = APFPadAppCollectionViewController.categories[1]
            APFPadAppCollectionViewController.categories[1] = APFPadAppCollectionViewController.categories[2]
            APFPadAppCollectionViewController.categories[2] = tmp
        }

        
        
        if self.navigationController?.restorationIdentifier == "SearchNavigationController" && self.collectionType != .SimilarApps {
            self.collectionType = .AppSearch
            self.searchBarView = UISearchBar(frame: CGRectMake(0, 0, 250, 25))
            self.searchBarView.delegate = self
            searchBarView.tintColor = UIColor(red:98.0/255.0, green:98.0/255.0, blue:98.0/255.0, alpha:1.0)
            self.searchBarView.placeholder = "جستجو"
            
            self.searchBarView.setValue("انصراف", forKey:"_cancelButtonText")
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                self.navigationItem.titleView = self.searchBarView
            }
            else {
                let searchBarItem = UIBarButtonItem(customView: self.searchBarView)
                self.navigationItem.rightBarButtonItem = searchBarItem
            }
            
            self.title = "جستجو"
            
            self.getAppEntries[0] = nil
        }
        else {
            self.didReachEndOfList[0] = {(UIViewController) -> (Void) in
                return
            }
            self.collectionView?.reloadData()
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            if self.collectionType == .Categories || self.collectionType == .AppSearch {
                self.collectionView?.contentInset = UIEdgeInsetsMake(10.0, 26.0, 26.0, 26.0)
            }
            else {
                self.collectionView?.contentInset = UIEdgeInsetsMake(26.0, 26.0, 26.0, 26.0)
            }
        }
        else {
            self.collectionView?.contentInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        }
        
        self.collectionView?.alwaysBounceVertical = true;
        
        (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = UICollectionViewScrollDirection.Vertical
        (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(150, 150)
        //self.collectionView!.setCollectionViewLayout(APFPadAppCollectionLayout(isCategory: self.collectionType == .Categories), animated: true)
        self.collectionView!.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        
        
        if self.collectionType == .AppSearch
        {
            self.noResultView = UIView(frame: CGRect(x: 0, y: 0, width: self.parentViewController!.view.bounds.size.width, height: self.parentViewController!.view.bounds.size.height))
            
            self.noResultView.backgroundColor = UIColor.whiteColor();
            
            // add en empty notes image placholder
            // when there is no data to display
            let noResultImageView : UIImageView = UIImageView(frame:CGRect(x: ((self.parentViewController!.view.bounds.size.width - 160) / 2), y: 50, width: 160, height: 160));
            noResultImageView.image = UIImage(named:"NoSearchResult.png");
            
            self.noResultView.addSubview(noResultImageView)
            
            let noResultLabel: UILabel = UILabel(frame: CGRect(x: ((self.parentViewController!.view.bounds.size.width - 250) / 2), y: 250, width: 250, height: 20))
            noResultLabel.text = "برنامه‌ای برای نمایش وجود ندارد"
            noResultLabel.font = UIFont(name: "IRANSans", size: 14.0)
            noResultLabel.textAlignment = .Center
            noResultLabel.textColor = UIColor.lightGrayColor()
            noResultLabel.shadowColor = UIColor.whiteColor()
            noResultLabel.backgroundColor = UIColor.clearColor()
            self.noResultView.addSubview(noResultLabel)
        }
        
        
        if self.collectionType == .Categories{
            tabIndex = 2
            self.page = [0,0,0]
            self.appEntries = [[],[],[]]
            self.didReachEndOfList = [
                {(UIViewController) -> (Void) in
                    if self.updating {
                        return
                    }
                    
                    self.updating = true
                    self.addContentToAppList()
                }
                ,
                {(UIViewController) -> (Void) in
                    if self.updating {
                        return
                    }
                    
                    self.updating = true
                    self.addContentToAppList()
                }
                ,
                {(UIViewController) -> (Void) in
                    if self.updating {
                        return
                    }
                    
                    self.updating = true
                    self.addContentToAppList()
                }
            ]
            
            self.getAppEntries = [
                { (page: NSInteger) -> [AnyObject]! in
                    return APFPROJECTAPI.currentInstance().getTopApps(self.selectedCategory, listPage: Int32(page), forType: "persian")
                },
                { (page: NSInteger) -> [AnyObject]! in
                    return APFPROJECTAPI.currentInstance().getTopApps(self.selectedCategory, listPage: Int32(page), forType: "topfree")
                },
                { (page: NSInteger) -> [AnyObject]! in
                    return APFPROJECTAPI.currentInstance().getTopApps(self.selectedCategory, listPage: Int32(page), forType: "toppaid")
                }
            ]
        }
        
        if self.collectionType == .Categories {
            self.title = "برترین‌ها"
            let anotherButton: UIBarButtonItem = UIBarButtonItem(title: "دسته‌بندی‌ها", style: .Plain, target: self, action: "getCategoryList")
            self.navigationItem.rightBarButtonItem = anotherButton;
        }
            
        if self.collectionType == .CategoriesSelection {
            self.title = "دسته‌بندی"
            let anotherButton: UIBarButtonItem = UIBarButtonItem(title: "انصراف", style: .Plain, target: self, action: "dismissController")
            self.navigationItem.leftBarButtonItem = anotherButton;
        }
        else if self.collectionType == .SimilarApps {
            self.title = "برنامه‌های مرتبط"
            self.didReachEndOfList[0] = {(UIViewController) -> (Void) in
                return
            }
            self.addContentToAppList()
        }
        else if self.collectionType != .AppSearch {
            self.didReachEndOfList[0] = {(UIViewController) -> (Void) in
                if self.updating {
                    return
                }
                
                self.updating = true
                self.addContentToAppList()
            }
            
            self.addContentToAppList()
        }
    }
    
    func getCategoryList()
    {
        let cat: APFPadAppCollectionViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("AppCollection") as! APFPadAppCollectionViewController
        cat.collectionType = .CategoriesSelection
        cat.title = "دسته‌بندی"
        cat.parent = self
        cat.selectedCategory = self.selectedCategory
        self.navigationController?.pushViewController(cat, animated: true)
//        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(cat, animated: true, completion: nil)
    }
    
    func dismissController()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if self.collectionType == .AppBuyList {
            self.navigationController?.navigationBar.barTintColor = UIColor.userGreen()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.collectionType == .AppBuyList {
            self.navigationController?.navigationBar.barTintColor = UIColor.userBlue()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addContentToAppList() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let tabIndex: Int = self.tabIndex
            self.page[tabIndex]++
            
            var appEntries: [APFAppEntry]? = []
            
            let currentSearchId = self.searchId
            
            
            if let f = self.getAppEntries[tabIndex] {
                appEntries = f(self.page[tabIndex]) as? [APFAppEntry]
            }
            
            if self.searchId != currentSearchId {
                return
            }
            
            if self.collectionType != .AppSearch || self.page[tabIndex] >= 2 {
                if appEntries == nil || appEntries?.count == 0 {
                    self.page[tabIndex]--
                    self.didReachEndOfList[tabIndex] = nil
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView?.reloadData()
                    }
                    
                    return
                }
            }
            
            self.appEntries[tabIndex] += appEntries!
            
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView!.reloadData()
            }
            
            self.updating = false
            
            if self.collectionType == .AppSearch {// && self.page == 1 {
                self.didReachEndOfList[tabIndex] = { (UIViewControler) -> (Void) in
                    return
                }
                
                self.addContentToAppList()
                dispatch_async(dispatch_get_main_queue()) {
                    if self.appEntries[tabIndex].count == 0
                    {
                        self.view.addSubview(self.noResultView)
                    }
                    else
                    {
                        self.noResultView.removeFromSuperview()
                    }
                }
                
                return
            }else if (self.page[tabIndex] == 1 && self.collectionType != .SimilarApps)
            {
                self.addContentToAppList()
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.bounds.size.height
        
        if maximumOffset - currentOffset <= scrollView.bounds.size.height / 2 {
            if self.didReachEndOfList[self.tabIndex] != nil {
                self.didReachEndOfList[tabIndex](self)
            }
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        self.collectionView!.collectionViewLayout.invalidateLayout()
        
        if self.collectionType == .Categories{
            return 2
        }
        else {
            return 1
        }
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch(self.collectionType) {
        case .CategoriesSelection:
                return APFPadAppCollectionViewController.categories.count
            
        case .SimilarApps:
                return self.appEntries[self.tabIndex].count
        
        case .Categories:
            switch(section){
            case 0:
                return 1
            default:
                return self.appEntries[self.tabIndex].count + (self.didReachEndOfList[self.tabIndex] != nil ? 1 : 0)
            }
        
        default:
            return self.appEntries[self.tabIndex].count + (self.didReachEndOfList[self.tabIndex] != nil ? 1 : 0)
        }
    }
    
    func apfStateChanged(control: HMSegmentedControl) {
        self.tabIndex = control.selectedSegmentIndex
        dispatch_async(dispatch_get_main_queue()) {
            if(self.appEntries[self.tabIndex].count == 0)
            {
                self.didReachEndOfList[self.tabIndex] = {(UIViewController) -> (Void) in
                    if self.updating {
                        return
                    }
                    
                    self.updating = true
                    self.addContentToAppList()
                }
                self.addContentToAppList()
            }
            self.collectionView!.reloadData()
        }
    }
    
    func setSearchCellState(cell: APFPadAppCollectionViewCell, state: APFAppCollectionItemState) {
        switch(state) {
        case .Exists:
            cell.availabilityIcon.image = self.checkImage
            cell.availabilityLabel.textColor = self.checkColor
            cell.availabilityLabel.text = "موجود در اپفورال"
        case .InQueue:
            cell.availabilityIcon.image = self.plusImage
            cell.availabilityLabel.textColor = self.plusColor
            cell.availabilityLabel.text = "در صف تهیه"
        case .AppBuy:
            cell.availabilityIcon.image = self.checkGreenImage
            cell.availabilityLabel.textColor = self.checkGreenColor
            cell.availabilityLabel.text = "خرید از اپ‌استور"
        default:
            break
        }
        
        if(state == .Unknown) {
            cell.availabilityIcon.hidden = true
            cell.availabilityLabel.hidden = true
            cell.appStatusActivityIndicator.startAnimating()
        }
        else {
            cell.availabilityIcon.hidden = false
            cell.availabilityLabel.hidden = false
            cell.appStatusActivityIndicator.stopAnimating()
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if (self.collectionType == .Categories) && indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(typeSwitchReuseIdentifier, forIndexPath: indexPath) 
            
            let apfSwitch = cell.subviews.first?.subviews.last as! HMSegmentedControl
            apfSwitch.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
            apfSwitch.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
//            apfSwitch.sectionTitles = ["برترین‌ها","جدیدترین‌ها","فارسی‌ها"]
            apfSwitch.sectionTitles = ["ایرانی","رایگان","غیر‌رایگان"]
            apfSwitch.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 174.0/255.0, alpha: 1.0), NSFontAttributeName:UIFont(name: "IRANSans", size: 13.0)!]
            apfSwitch.backgroundColor = UIColor.clearColor()
            apfSwitch.selectionIndicatorHeight = 3.0
            
            
            apfSwitch.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.userBlue()]
            apfSwitch.selectionIndicatorColor = UIColor.userBlue()
            apfSwitch.selectedSegmentIndex = self.tabIndex
            
            apfSwitch.addTarget(self, action: Selector("apfStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            
            return cell
        }
        
        if self.collectionType == .CategoriesSelection {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(catReuseIdentifier, forIndexPath: indexPath) as! APFPadAppCollectionViewCell
            
            
            cell.isCategory = true
            

            cell.category = APFPadAppCollectionViewController.categories[indexPath.item]["CellText"] as! String
            if self.selectedCategory == APFPadAppCollectionViewController.categories[indexPath.item]["CellFeed"] as! String{
                cell.icon = selectedImage
            }
            else {
                cell.icon = APFPadAppCollectionViewController.categories[indexPath.item]["CellImage"] as! UIImage
            }
            
            return cell
        }
        else if self.collectionType == .SimilarApps {
            var cell: APFPadAppCollectionViewCell!
            
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(similarReuseIdentifier, forIndexPath: indexPath) as! APFPadAppCollectionViewCell
            
            
            cell.tag = indexPath.row
            let itemData = self.appEntries[self.tabIndex][indexPath.item]
            
            cell.titleLabel.text = itemData.applicationName
            
            cell.appExtraInfo.text = itemData.applicationSize
            

            
            if let appIcon = itemData.applicationIcon {
                cell.icon = itemData.applicationIcon
            }
            else {
                cell.icon = UIImage(named: "noIconForApps")
                
                if itemData.iconDownloadedHandler == nil {
                    itemData.iconDownloadedHandler = { () -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            if cell.tag == indexPath.row {
                                cell.icon = itemData.applicationIcon
                            }
                        }
                    }
                }
                
                itemData.startDownloadIcon()
            }
            
            return cell
        }
        else {
            if indexPath.item < self.appEntries[self.tabIndex].count {
                var currentReuseId: String!
                
                if self.collectionType == .AppBuyList {
                    currentReuseId = searchReuseIdentifier
                }
                else {
                    currentReuseId = reuseIdentifier
                }
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(currentReuseId, forIndexPath: indexPath) as! APFPadAppCollectionViewCell
                
                cell.tag = indexPath.row
            
                let itemData = self.appEntries[self.tabIndex][indexPath.item]
                
                /*if APFPROJECTAPI.currentInstance().version == APFVersion.Basic {
                    if !itemData.availableInBasic {
                        cell.alpha = 0.5
                    }
                    else {
                        cell.alpha = 1.0
                    }
                }*/
                
                if self.collectionType == .AppList || self.collectionType == .Categories || self.collectionType == .AppSearch {
                    //cell.setData(itemData.applicationName, downloads: itemData.applicationAFDownloads, size: itemData.applicationSize, category: itemData.applicationCategory)

                    cell.actionButton.layer.cornerRadius = 2.0
                    cell.titleLabel.text = itemData.applicationName
                    cell.starRating.starImage = UIImage(named:"Star")
                    cell.starRating.starHighlightedImage = UIImage(named:"StarHighlight");
                    
                    cell.starRating.horizontalMargin = 0.0
                    cell.starRating.maxRating = 5;
                    cell.starRating.editable = true;
                    cell.starRating.displayMode = UInt(EDStarRatingDisplayHalf);
                    cell.starRating.rating = 2.5;
                    
                    cell.setEntryData(itemData)
                    
                    if !self.showActionButton
                    {
                        cell.actionButton.hidden = true
                    }
                    
                    if self.isAppBuy {
                        //cell.infoIcon.image = UIImage(named: "AppPriceIcon")
                        //cell.infoLabel.text = itemData.applicationOriginalPrice
                    }
                    else {
                        //cell.infoIcon.image = UIImage(named: "DownloadCountIcon")
                    }
                }
                else if self.collectionType == .AppBuyList {
                    cell.titleLabel.text = itemData.applicationName
                    cell.appExtraInfo.hidden = false
                    
                    if itemData.userAppleID != nil {
                        cell.appExtraInfo.text = itemData.userAppleID
                    }
                }
                
                if let appIcon = itemData.applicationIcon {
                    cell.icon = itemData.applicationIcon
                }
                else {
                    cell.icon = UIImage(named: "noIconForApps")
                    
                    if itemData.iconDownloadedHandler == nil {
                        itemData.iconDownloadedHandler = { () -> Void in
                            dispatch_async(dispatch_get_main_queue()) {
                                if cell.tag == indexPath.row {
                                    cell.icon = itemData.applicationIcon
                                }
                            }
                        }
                    }
                    
                    itemData.startDownloadIcon()
                }
                
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(loadingReuseIdentifier, forIndexPath: indexPath) as! APFPadAppCollectionViewCell
                
                cell.loadingIndicator.startAnimating()
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.collectionType == .CategoriesSelection
        {
            
            let indexPath = self.collectionView!.indexPathsForSelectedItems()![0]
            
            let category: String! = APFPadAppCollectionViewController.categories[indexPath.item]["CellFeed"] as! String
            self.selectedCategory = category
            self.parent.selectedCategory = category
            self.collectionView!.reloadData()
            self.parent.title = category=="All" ? "برترین‌ها" : APFPadAppCollectionViewController.categories[indexPath.item]["CellText"] as! String
            
            self.parent.tabIndex = 2
            self.parent.page = [0,0,0]
            self.parent.appEntries = [[],[],[]]
            
            
            self.parent.didReachEndOfList = [
                {(UIViewController) -> (Void) in
                    if self.updating {
                        return
                    }
                    
                    self.updating = true
                    self.addContentToAppList()
                }
                ,
                {(UIViewController) -> (Void) in
                    if self.updating {
                        return
                    }
                    
                    self.updating = true
                    self.addContentToAppList()
                }
                ,
                {(UIViewController) -> (Void) in
                    if self.updating {
                        return
                    }
                    
                    self.updating = true
                    self.addContentToAppList()
                }
            ]
            
            self.parent.collectionView!.reloadData()
            
            self.parent.addContentToAppList()
            
            self.navigationController?.popViewControllerAnimated(true)
            
            
        }
        
        if indexPath.item >= self.appEntries[self.tabIndex].count {
            return
        }
        
        
        if self.collectionType != .CategoriesSelection && self.collectionType != .AppBuyList {
            let app = self.appEntries[self.tabIndex][indexPath.item]
            
            if self.collectionType == .AppSearch {
                if app.exists == nil {
                    return
                }
                /*else if app.exists == NSNumber(bool: false) && app.applicationOriginalPrice == "Free" {
                    let alert = SDCAlertView(title: nil, message: "این برنامه در حال حاضر روی سرورهای اپفورال وجود ندارد. آیا مایل هستید هرچه‌ زودتر توسط تیم اپفورال اضافه شود؟", delegate: nil, cancelButtonTitle: "خیر")
                    alert.addButtonWithTitle("بلی")
                    
                    alert.showWithDismissHandler({ (Int) -> Void in
                        if Int == 1
                        {
                            APFPROJECTAPI.currentInstance().proposeAppWithId(self.appEntries[indexPath.item].applicationiTunesIdentification)
                        }
                    })
                    
                    return
                }*/
            }
            
            
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let appDescriptionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AppDescription") as! APFAppDescriptionViewController
                
                appDescriptionViewController.title = ""
                appDescriptionViewController.appEntry = app
                appDescriptionViewController.appDescription = app.applicationDescription
                
                appDescriptionViewController.isAppBuy = !app.availableInPROJECT
                appDescriptionViewController.parent = self;
                appDescriptionViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                appDescriptionViewController.modalPresentationStyle = UIModalPresentationStyle.FormSheet

                
                self.presentViewController(appDescriptionViewController, animated: true, completion: nil)
            }
        }
        else if self.collectionType == .AppBuyList {
            let app = self.appEntries[self.tabIndex][indexPath.item]
            let url = String(format:"http://itunes.apple.com/app/id%@", app.applicationiTunesIdentification)
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.collectionType == .AppSearch {
            let indexPath = self.collectionView!.indexPathsForSelectedItems()![0]
            let data = self.appEntries[self.tabIndex][indexPath.item]
            
            if data.exists == true {
                return true
            }
            else if data.applicationOriginalPrice == nil || data.applicationOriginalPrice == "Free" {
                return false
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.collectionType == .CategoriesSelection {
            return
        }
        else if self.collectionType == .AppList || self.collectionType == .AppSearch || self.collectionType == .SimilarApps || self.collectionType == .Categories {
            let destination = segue.destinationViewController as! APFAppDescriptionViewController
            let indexPath = self.collectionView!.indexPathsForSelectedItems()![0]
            
            let app = self.appEntries[self.tabIndex][indexPath.item]
            destination.parent = self;
            destination.title = ""
            destination.appEntry = app
            destination.appDescription = app.applicationDescription

            destination.isAppBuy = !app.availableInPROJECT

        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        }
        else {
            return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 8.0
        }
        else {
            return PAD_CELL_ITEM_SPACING;
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 8.0
        }
        else {
            return 12.0
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            let width: CGFloat! = self.collectionView?.bounds.width
            
            switch(self.collectionType) {
            case .CategoriesSelection:
                return CGSizeMake((width - 6 * categoriesSpacingConstant) / 2, 70.0)
            case .Categories:
                if indexPath.section == 0 {
                    return CGSizeMake(width - 4 * categoriesSpacingConstant, 45.0 + 12.0)
                }
                else {
                    return CGSizeMake(width - 4 * categoriesSpacingConstant, PAD_CELL_ITEM_HEIGHT)
                }
                
            case .AppSearch:
                return CGSizeMake(width - 4 * categoriesSpacingConstant, PAD_CELL_ITEM_HEIGHT)
            case .SimilarApps:
                return CGSizeMake((width - 8 * categoriesSpacingConstant)/3, 132.0)
                
            default:
                return CGSizeMake(width - 4 * categoriesSpacingConstant, PAD_CELL_ITEM_HEIGHT)
            }
        }
        else {
            let width: CGFloat! = self.collectionView?.bounds.width
            switch(self.collectionType) {
            case .CategoriesSelection:
                return CGSizeMake(PAD_CELL_ITEM_WIDTH, PAD_CELL_CAT_ITEM_HEIGHT)
            case .Categories:
                if indexPath.section == 0 {
                    return CGSizeMake(972.0, 45.0 + 12.0)
                }
                else {
                    return CGSizeMake(PAD_CELL_ITEM_WIDTH, PAD_CELL_CAT_ITEM_HEIGHT)
                }
            case .SimilarApps:
                return CGSizeMake((width-8 * categoriesSpacingConstant - 52)/3, 132.0)
                
            default:
                return CGSizeMake(PAD_CELL_ITEM_WIDTH, PAD_CELL_ITEM_HEIGHT)
            }
        }
    }
    
    @IBAction func actionButtonClicked(sender : AnyObject!)
    {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView:self.collectionView);
        let indexPath: NSIndexPath! = self.collectionView!.indexPathForItemAtPoint(buttonPosition);
        if (indexPath != nil)
        {
            let cell: APFPadAppCollectionViewCell? = self.collectionView?.cellForItemAtIndexPath(indexPath) as? APFPadAppCollectionViewCell
            let app = self.appEntries[self.tabIndex][indexPath.item]
            
            if cell?.Action == "Open"
            {
                UIApplication.sharedApplication().openURL(NSURL(string: String(format: "useriid-%@://", arguments: [app.applicationiTunesIdentification]))!)
                return;
            }
            
            let destination: APFAppDescriptionViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("AppDescription") as! APFAppDescriptionViewController
            

            destination.parent = self;
            destination.title = ""
            destination.appEntry = app
            destination.appDescription = app.applicationDescription
            
            
            destination.isAppBuy = !app.availableInPROJECT
            destination.userAction = cell?.Action
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad
            {
                destination.parent = self;
                destination.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                destination.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                
                self.presentViewController(destination, animated: true, completion: nil)
            }
            else {
                self.navigationController?.pushViewController(destination, animated: true)
            }
            
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(false)
        searchId++
        
        self.searchAPI = APFSearchAPI()
        weak var weakSearchAPI = self.searchAPI
        
        if !self.isAppBuy {
            self.getAppEntries[self.tabIndex] = { (page: NSInteger) -> [AnyObject]! in
                if page == 1 {
                    let result = weakSearchAPI?.getPROJECTResults(searchBar.text)
                    return result
                }
                else {
                    return []
                }
            }

        }
        else {
            self.getAppEntries[self.tabIndex] = { (page: NSInteger) -> [AnyObject]! in
                if page == 1 {
                    let result = weakSearchAPI?.getiTunesResults(searchBar.text)
                    return result
                }
                else {
                    return []
                }
            }

        }
        
        self.page[self.tabIndex] = 0
        self.appEntries[self.tabIndex] = []
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView?.reloadData()
        }
        
        self.didReachEndOfList[self.tabIndex] = { (UIViewControler) -> (Void) in
            return
        }
        
        self.updating = true
        self.addContentToAppList()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if self.collectionType == .AppSearch{
            self.noResultView.removeFromSuperview()
        }
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
