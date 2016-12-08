//
//  APFAppDownload.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 13/3/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

@objc class APFAppDownload: NSObject {
    var twoStage: Bool = false
    
    var appId: String!
    var iTunesId: String!
    var appName: String!
    var appCategory: String!
    var appVersion: String!
    
    var downloadUrl: String!
    var extraDownloadUrl: String!
    
    var downloadTask: TCBlobDownloader!
    var extraDownloadTask: TCBlobDownloader!
    
    var totalSize: UInt64 = 0
    var downloadedSize: UInt64 = 0
    
    init(appId: String, iTunesId: String, appName: String!, appCategory: String!, appVersion: String!, downloadUrl: String,extraDownloadUrl: String) {
        
        super.init()
        
        self.appId = appId
        self.iTunesId = iTunesId
        self.appName = appName
        self.appCategory = appCategory
        self.appVersion = appVersion
        
        self.downloadUrl = downloadUrl
        self.extraDownloadUrl = extraDownloadUrl
        
        var extraFileRequest = NSMutableURLRequest(URL: NSURL(string: self.extraDownloadUrl)!)
        extraFileRequest.HTTPMethod = "HEAD"
        
        NSURLConnection.sendAsynchronousRequest(extraFileRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var extraFileSize = UInt64(response.expectedContentLength)
            
            self.downloadTask = TCBlobDownloader(
                URL: NSURL(string: self.downloadUrl),
                downloadPath: "",
                
                firstResponse: { (response: NSURLResponse!) -> Void in
                    self.totalSize = extraFileSize + UInt64(response.expectedContentLength)
                    return
                }, progress: { (receivedLength: UInt64, totalLength: UInt64, remainingTime: Int, progress: Float) -> Void in
                    self.downloadedSize += receivedLength
                    return
                }, error: { (error: NSError!) -> Void in
                    
                }, complete: { (downloadFinished: Bool, pathToFile: String!) -> Void in
                    if self.twoStage {
                        self.extraDownloadTask = TCBlobDownloader(
                            URL: NSURL(string: self.extraDownloadUrl),
                            downloadPath: "",
                            
                            firstResponse: { (response: NSURLResponse!) -> Void in
                                
                            }, progress: { (receivedLength: UInt64, totalLength: UInt64, remainingTime: Int, progress: Float) -> Void in
                                self.downloadedSize += receivedLength
                                return
                            }, error: { (error: NSError!) -> Void in
                                
                            }, complete: { (downloadFinished: Bool, pathToFile: String!) -> Void in
                                
                            })
                    }
                    else {
                        // deal with finished download
                    }
            })
        }
    }
    
    var state: TCBlobDownloadState {
        get {
            if !twoStage {
                return downloadTask.state
            }
            else {
                if downloadTask.state != TCBlobDownloadState.Done {
                    return downloadTask.state
                }
                else if extraDownloadTask != nil {
                    return extraDownloadTask.state
                }
                else {
                    return TCBlobDownloadState.Downloading
                }
            }
        }
    }
}
