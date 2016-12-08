//
//  APFDownloadsListTableViewController.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 24/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFDownloadsListTableViewController: UITableViewController {

    var refreshTimer: NSTimer!
    
    var isAppsLoaded: Bool = false
    
    var appArrays: [APFFileDownloadInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    func directorySize(url: NSURL) -> UInt64
    {
        var bool: ObjCBool = false
        if NSFileManager().fileExistsAtPath(url.path!, isDirectory: &bool) {
            if bool.boolValue {
                // lets get the folder files
                let fileManager =  NSFileManager.defaultManager()
                let files = try! fileManager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: [])
                var folderFileSizeInBytes: UInt64 = 0
                for file in files {
                    folderFileSizeInBytes +=  UInt64(try! (fileManager.attributesOfItemAtPath(file.path!) as NSDictionary).fileSize().hashValue)
                }
                return folderFileSizeInBytes
            }
        }
        return 0;
    }
    
    func fetchData()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let lids: NSMutableArray! = []
            let fileManager = NSFileManager.defaultManager()
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory = paths.first!
            let destinationPathDirectory = (documentsDirectory as NSString).stringByAppendingPathComponent("Web")
            let files = try? fileManager.contentsOfDirectoryAtPath(destinationPathDirectory)
            
            for file in files! {
                let fullPath = (destinationPathDirectory as NSString).stringByAppendingPathComponent(file)
                
                if (try? fileManager.contentsOfDirectoryAtPath(fullPath))?.count > 0 {
                    let size = self.directorySize(NSURL(fileURLWithPath: fullPath))
                    if size < 4096 {
                        continue
                    }
                    var toAdd = true
                    for app in APFPROJECTAPI.currentInstance().fileDownloadDataArray
                    {
                        if (app as! APFFileDownloadInfo).appId == file
                        {
                            toAdd = false;
                            break;
                        }
                    }
                    if(toAdd)
                    {
                        lids.addObject(file)
                    }
                }
            }
            let data = APFPROJECTAPI.currentInstance().lidLookup(lids as NSArray as [AnyObject])
            if(data == nil)
            {
                return
            }
            
            for file in files! {
                let fullPath = (destinationPathDirectory as NSString).stringByAppendingPathComponent(file)
                
                if (try? fileManager.contentsOfDirectoryAtPath(fullPath))?.count > 0 {
                    if let lid = data[file]
                    {
                        let info = APFFileDownloadInfo(fileAppId: file, andAppName: lid["nam"] as! String, andAppIcon: lid["a160"] as! String, andItunesId:lid["id"] as! String)
                        info.totalFileLength = self.directorySize(NSURL(fileURLWithPath: fullPath))
                        self.appArrays.append(info)
                    }
                }
            }
            self.isAppsLoaded = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return APFPROJECTAPI.currentInstance().fileDownloadDataArray.count
        case 1:
            return self.isAppsLoaded ? self.appArrays.count : 1
        case 2:
            return 1
        default:
            return APFPROJECTAPI.currentInstance().fileDownloadDataArray.count
        }
    }
    
    /*override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 24))
        var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width - 20, 24))
        
        switch(section) {
        case 0:
            label.text = "در حال انجام"
        case 1:
            label.text = "پایان یافته"
        default:
            label.text = "در حال انجام"
        }

        label.font = UIFont(name: "Yekan", size: 16.0)
        label.textAlignment = NSTextAlignment.Right
        
        view.addSubview(label)
        view.backgroundColor = UIColor(white: 0.95, alpha: 0.75)
        
        return view
    }*/

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseIdentifier: String!
        var info: APFFileDownloadInfo!
        
        if(indexPath.section == 2)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("DeleteDownloads", forIndexPath: indexPath)
            cell.backgroundColor = tableView.backgroundColor
            return cell
        }
        
        if(indexPath.section == 1 && !self.isAppsLoaded)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("DownloadCell", forIndexPath: indexPath) as! APFDownloadsListTableViewCell
            cell.loading()
            return cell
        }
        
        switch(indexPath.section) {
        case 0:
            info = APFPROJECTAPI.currentInstance().fileDownloadDataArray.objectAtIndex(indexPath.item) as! APFFileDownloadInfo
            reuseIdentifier = "DownloadCell"
        case 1:
            info = self.appArrays[indexPath.item]
            reuseIdentifier = "DownloadCell"
            
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! APFDownloadsListTableViewCell
        
        cell.enable()
        
        cell.appName = info.appName
        cell.state = indexPath.section == 1 ? DownloadState.Successful : DownloadState.Downloading
        cell.total = info.totalFileLength
        cell.progress = indexPath.section == 1 ? 1 : info.downloadProgress
        cell.tag = indexPath.row
        if (indexPath.section == 1){
            cell.downloadStateIcon.hidden = false
            cell.downloadPercentageLabel.hidden = true
        }
        else
        {
            cell.downloadStateIcon.hidden = true
            cell.downloadPercentageLabel.hidden = false
        }
        
        
        if let appIcon = info.appIcon {
            cell.appIcon.image = appIcon
        }
        else {
            cell.appIcon.image = UIImage(named: "noIconForApps")
            
            if info.iconDownloadedHandler == nil {
                info.iconDownloadedHandler = { () -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if cell.tag == indexPath.row {
                            cell.appIcon.image = info.appIcon
                        }
                    }
                }
            }
            
            info.startDownloadIconWithSize()
        }
        cell.appIcon.layer.cornerRadius = 12.0
        
        
        return cell
    }
    
    
    @IBAction func deleteDownloadedApps() {
        let alert = SDCAlertView(title: "حذف فایل‌های اضافی", message: "این کار صرفا فایلهای دانلود شده را حذف می‌کند و این به معنی uninstall کردن برنامه‌ها نیست.", delegate: nil, cancelButtonTitle: "انصراف")
        alert.addButtonWithTitle("تایید")
        
        alert.showWithDismissHandler({ (buttonIndex: Int) -> Void in
            if buttonIndex == 1 {
                let fileManager = NSFileManager.defaultManager()
                let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                let documentsDirectory = paths.first!
                let destinationPathDirectory = (documentsDirectory as NSString).stringByAppendingPathComponent("Web")
                let files = try? fileManager.contentsOfDirectoryAtPath(destinationPathDirectory)
                
                for file in files! {
                    let fullPath = (destinationPathDirectory as NSString).stringByAppendingPathComponent(file)
                    
                    if (try? fileManager.contentsOfDirectoryAtPath(fullPath))?.count > 0 {
                        do {
                            try fileManager.removeItemAtPath(fullPath)
                        } catch _ {
                        }
                    }
                }
                self.appArrays = []
                self.refreshDownloads(self)
                SVProgressHUD.showSuccessWithStatus("همه فایل‌ها حذف شدند.")
            }
        })
    }
    
    
    override func viewDidAppear(animated: Bool) {
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("refreshDownloads:"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        if self.refreshTimer != nil {
            self.refreshTimer.invalidate()
            self.refreshTimer = nil
        }
    }
    
    func refreshDownloads(sender: AnyObject) {
        self.appArrays.appendContentsOf(APFPROJECTAPI.currentInstance().successfulDownloadDataArray as NSArray as! [APFFileDownloadInfo])
        APFPROJECTAPI.currentInstance().successfulDownloadDataArray.removeAllObjects()
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 2) {return 51.0+8.0;}
        return 80.0 + 8.0
    }

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

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AppDescription" {
            let destination = segue.destinationViewController as! APFAppDescriptionViewController
            let path = self.tableView.indexPathForSelectedRow
            
            var downloadItem: APFFileDownloadInfo!
            var appEntry: APFAppEntry!
            
            if path?.section == 0 { // completed
                downloadItem = APFPROJECTAPI.currentInstance().fileDownloadDataArray.objectAtIndex(path!.item) as! APFFileDownloadInfo
            }
            else {
                downloadItem = self.appArrays[path!.item]
            }
            
            if downloadItem.appEntry != nil {
                appEntry = downloadItem.appEntry
            }
            else {
                appEntry = APFAppEntry()
                appEntry.applicationiTunesIdentification = downloadItem.appiTunesId;
            }
            
            destination.appEntry = appEntry
            destination.appDescription = appEntry.applicationDescription
        }
    }


}
