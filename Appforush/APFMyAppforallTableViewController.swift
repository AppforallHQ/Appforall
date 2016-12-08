//
//  APFMyPROJECTTableViewController.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 24/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFMyPROJECTTableViewController: UITableViewController {

//    @IBOutlet weak var userAvatar: UIImageView!
//    @IBOutlet weak var userName: UILabel!
//    @IBOutlet weak var userAccountStatus: UILabel!
//    @IBOutlet weak var currentDownloads: UIView!
    
    var userInfo: APFUserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        self.currentDownloads.backgroundColor = UIColorFromHex("#FF3B30")
//        self.currentDownloads.layer.cornerRadius = 6.0
//        self.currentDownloads.clipsToBounds = true
        
        self.userInfo = APFPROJECTAPI.currentInstance().apfUserInfo
        self.tableView.sectionHeaderHeight = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
//        
//        if APFPROJECTAPI.currentInstance().fileDownloadDataArray.count > 0 {
//            self.currentDownloads.hidden = false
//           (self.currentDownloads as? UILabel)?.text = " \(APFPROJECTAPI.currentInstance().fileDownloadDataArray.count) "
//        }
//        else {
//            self.currentDownloads.hidden = true
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (APFPROJECTAPI.currentInstance().version == .Basic) ? 5 : 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return 0
        case 3, 4:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyPROJECTUser", forIndexPath: indexPath) as! APFMyPROJECTUserInfoTableViewCell
            
            cell.backgroundColor = UIColor.clearColor()
            cell.userAvatar.layer.cornerRadius = cell.userAvatar.bounds.size.width / 2
            cell.userAvatar.clipsToBounds = true
            
            cell.userName.text = self.userInfo.firstName
            
            if self.userInfo.avatar != nil {
                cell.userAvatar.image = userInfo.avatar
            }
            else {
                userInfo.avatarDownloadedHandler = { () -> (Void) in
                    cell.userAvatar.image = self.userInfo.avatar
                }
                
                self.userInfo.startDownloadAvatar()
            }
            
            let now = NSDate()
            
            if APFPROJECTAPI.currentInstance().version == APFVersion.Basic {
                cell.userAccountStatus.textColor = UIColorFromHex("#0BD318")
                if (self.userInfo.campaigns != nil) {
                    let df = NSDateFormatter()
                    df.dateFormat = "YYYY/MM/dd"
                    df.calendar = NSCalendar(calendarIdentifier: NSPersianCalendar)
                    cell.userAccountStatus.text = String(format: "تاریخ پایان اشتراک: %@", df.stringFromDate(self.userInfo.campaigns))
                }
                else
                {
                    cell.userAccountStatus.text = String(format: "تاریخ پایان اشتراک: %@", "ندارد - رایگان")
                }
            }
            else {
                if self.userInfo.expire_date == nil || now.compare(self.userInfo.expire_date) == NSComparisonResult.OrderedDescending {
                    cell.userAccountStatus.text = "اشتراک شما پایان یافته است."
                    cell.userAccountStatus.textColor = UIColorFromHex("#FF3B30")
                }
                else {
                    cell.userAccountStatus.textColor = UIColorFromHex("#0BD318")
                    let df = NSDateFormatter()
                    df.dateFormat = "YYYY/MM/dd"
                    df.calendar = NSCalendar(calendarIdentifier: NSPersianCalendar)
                    cell.userAccountStatus.text = String(format: "تاریخ پایان اشتراک: %@", df.stringFromDate(self.userInfo.expire_date))
                }
            }
            
            cell.backgroundView = nil
            
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyPROJECTLink", forIndexPath: indexPath) 
            
            cell.backgroundColor = UIColor.clearColor()
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.textLabel?.textAlignment = .Right
            
            cell.backgroundView = UIView()
            cell.backgroundView?.subviews.map({ $0.removeFromSuperview() })
            cell.backgroundView?.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            
            cell.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            cell.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            
            switch(indexPath.item) {
            case 1:
                cell.textLabel!.text = "دانلودها"
            case 2:
                cell.textLabel!.text = "برنامه‌های دانلود شده"
            case 3:
                cell.textLabel!.text = "ارتباط با پشتیبانی"
            case 0:
                cell.textLabel!.text = "مشاهده آخرین خریدها"
            default:
                break
            }
            
            var background: UIImageView! = nil

            // TODO fix this when MyApp releases.
            switch(indexPath.item) {
            case 0:
                background = UIImageView(image: UIImage(named: "ListBgTop"))
            case 1...2:
                background = UIImageView(image: UIImage(named: "ListBgMiddle"))
            case 3:
                background = UIImageView(image: UIImage(named: "ListBgBottom"))
            default:
                break
            }
            
            if indexPath.item < 3 {
                // add separator line
                let separator = UIView()
                cell.backgroundView?.addSubview(separator)
                
                separator.translatesAutoresizingMaskIntoConstraints = false
                
                separator.backgroundColor = UIColor(red: 193.0/255.0, green: 193.0/255.0, blue: 193.0/255.0, alpha: 1.0)
                
                let sepConstraints_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-25-[sep]-25-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["sep": separator])
                let sepConstraints_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[sep(\(1 / UIScreen.mainScreen().scale))]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["sep": separator])
                
                cell.backgroundView?.addConstraints(sepConstraints_H)
                cell.backgroundView?.addConstraints(sepConstraints_V)
            }
            
            cell.separatorInset = UIEdgeInsetsMake(0, 25.0, 0.0, 25.0)
            cell.backgroundView?.insertSubview(background, atIndex: 0)
            
            background.translatesAutoresizingMaskIntoConstraints = false
            
            let bgConstraints_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[bg]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bg": background])

            let bgConstraints_V = NSLayoutConstraint.constraintsWithVisualFormat("V:|[bg]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bg": background])
            
            cell.backgroundView?.addConstraints(bgConstraints_H)
            cell.backgroundView?.addConstraints(bgConstraints_V)
            
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyPROJECTLink", forIndexPath: indexPath) 
            
            cell.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            
            cell.backgroundColor = UIColor.clearColor()
            
            cell.textLabel?.text = "حذف فایل‌های اضافی در اپفورال"
            //cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.textAlignment = .Center
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            let background = UIImageView(image: UIImage(named: "AppBg"))
            background.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.insertSubview(background, atIndex: 0)
            
            let bgConstraints_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[bg]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bg": background])
            
            let bgConstraints_V = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[bg]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bg": background])
            
            cell.addConstraints(bgConstraints_H)
            cell.addConstraints(bgConstraints_V)
            
            return cell
        }
        else if indexPath.section == 3 && APFPROJECTAPI.currentInstance().version == .Basic {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyPROJECTLink", forIndexPath: indexPath) 
            
            cell.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            
            cell.backgroundColor = UIColor.clearColor()
            
            cell.textLabel?.text = "خروج از اپفورال"
            cell.textLabel?.textAlignment = .Center
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            let background = UIImageView(image: UIImage(named: "AppBg"))
            background.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.insertSubview(background, atIndex: 0)
            
            let bgConstraints_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[bg]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bg": background])
            
            let bgConstraints_V = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[bg]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bg": background])
            
            cell.addConstraints(bgConstraints_H)
            cell.addConstraints(bgConstraints_V)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyPROJECTLink", forIndexPath: indexPath) 
            
            //object_setClass(cell.textLabel!, APFLabel.self)
            
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.text = String(format: "اپفورال نسخه‌ی %@", VERSION)
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = UIColor(white: 0.4, alpha: 1.0)
            cell.textLabel?.font = cell.textLabel?.font.fontWithSize(10.0)
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            return cell
        }

        return UITableViewCell()
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 178.0
        }
        else if indexPath.section == 2 {
            return 50.0 + 8.0
        }
        else if indexPath.section == 3 && APFPROJECTAPI.currentInstance().version == .Basic {
            return 50.0 - 8.0
        }
        else if indexPath.section == 3 {
            return 35.0
        }
        
        return 50.0
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView(frame: CGRectZero)
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 && indexPath.item == 0 {
            cell.textLabel?.textColor = UIColor.redColor()
        }

    }
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func logout() {
        let bundleId = NSBundle.mainBundle().bundleIdentifier
        SSKeychain.deletePasswordForService(bundleId, account: "basicPassword")
        SSKeychain.deletePasswordForService(bundleId, account: "basicUsername")
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            switch(indexPath.item) {
            case 1:
                self.performSegueWithIdentifier("MyDownloads", sender: self)
            case 2:
                self.performSegueWithIdentifier("DownloadHistory", sender: self)
            case 3:
                self.performSegueWithIdentifier("Support", sender: self)
            case 0:
                self.performSegueWithIdentifier("AppBuyHistory", sender: self)
            default:
                break
            }
        }
        else if indexPath.section == 2 {
            switch(indexPath.item) {
            default:
                break
            }
        }
        else if indexPath.section == 3 && APFPROJECTAPI.currentInstance().version == .Basic {
            logout()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DownloadHistory" {
            var destination = segue.destinationViewController 
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {

            }
            else {
                destination = (destination as! UINavigationController).topViewController!
            }
            
            (destination as! APFPadAppCollectionViewController).getAppEntries[0] = { (page: Int) -> ([AnyObject]!) in
                return APFPROJECTAPI.currentInstance().getDownloadHistory(Int32(page))
            }
            (destination as! APFPadAppCollectionViewController).collectionType = .AppList
            (destination as! APFPadAppCollectionViewController).showActionButton = false
            
            destination.title = "برنامه‌های دانلود شده"
        }
        else if segue.identifier == "Support" {
            var destination = segue.destinationViewController 
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                destination = (destination as! UINavigationController).viewControllers.first!
            }
            
            let chatUrl = APFPROJECTAPI.currentInstance().chatURL
            (destination as! APFChatViewController).chatUrl = chatUrl;
        }
        else if segue.identifier == "AppBuyHistory" {
            var destination = segue.destinationViewController 
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {

            }
            else {
                destination = (destination as! UINavigationController).viewControllers.first!
            }
            
            (destination as! APFPadAppCollectionViewController).getAppEntries[0] = { (page: Int) -> ([AnyObject]!) in
                return APFPROJECTAPI.currentInstance().getAppBuyHistory(Int32(page))
            }
            
            (destination as! APFPadAppCollectionViewController).collectionType = .AppBuyList
            
            destination.title = "آخرین خریدها"
        }
    }

}
