//
//  APFUpdateAppTableViewCell.m
//  PROJECT
//
//  Created by Nima Azimi on 12/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Analytics/Analytics.h>
#import <SDCAlertView/SDCAlertView.h>
#import <sys/stat.h>
#import "APFUpdateAppTableViewCell.h"
#import "FFCircularProgressView.h"
#import "APFFileDownloadInfo.h"

@interface APFUpdateAppTableViewCell()

@property (strong, nonatomic) IBOutlet FFCircularProgressView *circularProgressView;

@property (nonatomic, strong) NSURL *documentDirectoryURL;
@property (nonatomic, strong) APFAppSignRequest *appSignRequest;

@end

@implementation APFUpdateAppTableViewCell
@synthesize installButton;
@synthesize cancelButton;
-(void) awakeFromNib {
    [super awakeFromNib];
    
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppBg"]];
    self.backgroundView = bgView;
    
    self.cellHRuleConstraint.constant = 1 / [UIScreen mainScreen].scale;
    CGFloat cornerRadius = 12.0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        cornerRadius = 12.0;
    } else {
        cornerRadius = 12.0;
    }
    
    CALayer *imageLayer = self.cellItemImageView.layer;
    imageLayer.cornerRadius = cornerRadius;
    imageLayer.masksToBounds = YES;
    self.cellItemImageView.clipsToBounds = YES;
    
    self.installButton.layer.cornerRadius = 2.0;
    self.cancelButton.layer.cornerRadius = 2.0;
    
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.documentDirectoryURL = [URLs objectAtIndex:0];
    
    if (self.appId != nil) {
        [self processInstallAndProgressUI];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processInstallAndProgressUI)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(void)setFrame:(CGRect)frame {
    //frame.origin.x += 8;
    
    frame.size.width -= 16;
    frame.origin.y += 8;
    frame.size.height -= 8;
    
    [super setFrame:frame];
}

- (void) processInstallAndProgressUI {
    
    //Create progress UI
    [self.circularProgressView removeFromSuperview];
    self.circularProgressView = nil;

//    float dimension = 44.0;
//    CGPoint center = self.iconDownloadOverlay.center;
//    CGRect bounds;
//    bounds = CGRectMake(center.x - dimension / 2, center.y - dimension / 2, dimension, dimension);
    
    self.circularProgressView = [[FFCircularProgressView alloc] init];
    self.circularProgressView.translatesAutoresizingMaskIntoConstraints = false;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(handlePauseResume:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.circularProgressView addGestureRecognizer:tapGestureRecognizer];
    [self.contentView addSubview:self.circularProgressView];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconDownloadOverlay attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.circularProgressView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconDownloadOverlay attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.circularProgressView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.circularProgressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.circularProgressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
    
    NSUInteger index = [self downloadQueueIndex];
    if (index != -1) {
        [self.installButton setHidden:YES];
        [self.cancelButton setHidden:NO];
        [self.circularProgressView setHidden:NO];
        [self.iconDownloadOverlay setHidden:NO];
        
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
        
        if (fileDownloadInfo.downloadTask != nil) {
            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
        }
        NSLog(@"PROCESSING UI! PROBLEM HERE %lu",(unsigned long)fileDownloadInfo.fileDownloadStatus);
        switch (fileDownloadInfo.fileDownloadStatus) {
            case APFFileDownloadInfoStatusInit:
                break;
            case APFFileDownloadInfoStatusDownloading: {
                self.circularProgressView.isPaused = NO;
                [self.circularProgressView setNeedsDisplay];
                [self.circularProgressView  setProgress:fileDownloadInfo.downloadProgress]; // Added by @sadjad
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                break;
            }
            case APFFileDownloadInfoStatusCompleted:
                break;
            case APFFileDownloadInfoStatusPaused:{
                self.circularProgressView.isPaused = YES;
                if (fileDownloadInfo.taskResumeData != nil)
                    [self.circularProgressView  setProgress:fileDownloadInfo.downloadProgress];
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                break;
            }
            case APFFileDownloadInfoStatusCancelled: {
                self.circularProgressView.isPaused = YES;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                break;
            }
            default:
                break;
        }
    } else {
        [self.installButton setHidden:NO];
        [self.cancelButton setHidden:YES];
        [self.circularProgressView setHidden:YES];
        [self.iconDownloadOverlay setHidden:YES];
    }
}

-(int) downloadQueueIndex {
    int index = -1;
    for (int i=0; i<[[APFPROJECTAPI currentInstance].fileDownloadDataArray count]; i++) {
        APFFileDownloadInfo *fdi = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:i];
        if ([fdi.appId isEqualToString:self.appId]) {
            index = i;
            break;
        }
    }
    
    return index;
}

- (IBAction)confirmInstallation:(id)sender {
    [self startDownloadAndInstallWithAppId:self.appId];
}

- (void) startDownloadAndInstallWithAppId:(NSString *)appId {
    
    self.appSignRequest = [[APFPROJECTAPI currentInstance] requestDownloadForAppID:self.appId];
    self.appSignRequest.delegate = self;
    
    [self.circularProgressView startSpinProgressBackgroundLayer];
    [self.installButton setHidden:YES];
    [self.circularProgressView setHidden:NO];
    [self.iconDownloadOverlay setHidden:NO];
    
    /*SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                      message:@"درخواست شما با موفقیت ثبت شد. \nدانلود برنامه تا چند ثانیه دیگر آغاز می‌شود..."
                                                     delegate:nil
                                            cancelButtonTitle:@"تایید"
                                            otherButtonTitles:nil, nil];*/
    //[alert show];
    
    //TODO change to new event for update apps
    //    [[SEGAnalytics sharedAnalytics] track:@"send_request_to_update_an_app" properties:
    //     @{ @"Application Name": self.applicationName,
    //        @"Category" : self.appDescription.applicationCategory,
    //        @"Version" : self.appDescription.applicationVersion}];

}

- (IBAction)cancelInstallation:(id)sender {
    NSUInteger index = [self downloadQueueIndex];
    if (index != -1) {
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
        
        [fileDownloadInfo.downloadTask cancel];
        fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusCancelled;
        [[APFPROJECTAPI currentInstance].fileDownloadDataArray removeObjectAtIndex:index];
        [self processInstallAndProgressUI];
    }
}

-(void) didDownloadProgressForAppId:(NSString *)appId withProgress:(double)progress {
    NSLog(@"Progress %@: %f",self.appName, progress);
    
    [self.circularProgressView stopSpinProgressBackgroundLayer];
    [self.circularProgressView  setProgress:progress];
}

- (void) didDownloadFail {
    self.circularProgressView.isPaused = YES;
    [self.circularProgressView setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
}

- (void) didDownloadFinish {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self processInstallAndProgressUI];
        [self.installButton setHidden:YES];
    });
}

- (void) pauseDownload
{
    NSUInteger index = [self downloadQueueIndex];
    if (index != -1) {
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
        if(fileDownloadInfo.fileDownloadStatus == APFFileDownloadInfoStatusDownloading)
        {
            [self handlePauseResume:nil];
        }
    }
}

- (IBAction)handlePauseResume:(UITapGestureRecognizer *)tapRecognizer {
    
    NSUInteger index = [self downloadQueueIndex];
    if (index != -1) {
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
        
        if (fileDownloadInfo.downloadTask != nil) {
            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
        }
        
        NSString *stateString;
        NSLog(@"HANDLE PAUSE RESUME STATE : %d",fileDownloadInfo.fileDownloadStatus);
        switch (fileDownloadInfo.fileDownloadStatus) {
            case APFFileDownloadInfoStatusInit:
                stateString = @"Ready";
                break;
            case APFFileDownloadInfoStatusDownloading: {
                stateString = @"Downloading";
                NSLog(@"Downloading!!!!!!!!! %llu", fileDownloadInfo.downloadedBytes);
                [fileDownloadInfo.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                    if (resumeData != nil) {
                        fileDownloadInfo.taskResumeData = [[NSData alloc] initWithData:resumeData];
                        fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                    }
                }];
                
                self.circularProgressView.isPaused = YES;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusPaused;
                break;
            }
            case APFFileDownloadInfoStatusCompleted:
                stateString = @"Done";
                break;
            case APFFileDownloadInfoStatusPaused:{
                stateString = @"Cancelled";
                self.circularProgressView.isPaused = NO;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                
                fileDownloadInfo.downloadTask = [[APFPROJECTAPI currentInstance].session downloadTaskWithResumeData:fileDownloadInfo.taskResumeData];
                fileDownloadInfo.taskIdentifier = fileDownloadInfo.downloadTask.taskIdentifier;
                fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                [fileDownloadInfo.downloadTask resume];
                fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusDownloading;
                break;
            }
            case APFFileDownloadInfoStatusCancelled: {
                stateString = @"Failed";
                
                self.circularProgressView.isPaused = NO;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                [fileDownloadInfo.downloadTask cancel];
                fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                break;
            }
            default:
                break;
        }
    }
    
}

-(void) didFetchDownloadAppUrl:(id)sender {
    NSString *appID = self.appId;
    APFAppSignRequest *signRequest = (APFAppSignRequest *)sender;
    
    NSString *downloadUrl = signRequest.downloadAppUrl;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destinationPathDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/%@/temp/", appID]];
    
    if (![fileManager fileExistsAtPath:destinationPathDirectory]) {
        [fileManager createDirectoryAtPath:destinationPathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *downloadPath;
    NSString *downloadExtraPath;
    
    APFFileDownloadInfo *fileDownloadInfo = [[APFFileDownloadInfo alloc] initWithFileAppId:appID
                                                                               andiTunesId:self.appiTunesId
                                                                                andAppName:self.appName
                                                                            andAppCategory:@""
                                                                             andAppVersion:@""
                                                                         andDownloadSource:downloadUrl andAppIcon:self.appIconUrl];
    
    if(signRequest.twoStage) {
        fileDownloadInfo.twoStage = true;
        fileDownloadInfo.currentStage = 1;
        fileDownloadInfo.downloadExtraSource = signRequest.downloadExtraUrl;
        
        downloadPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.raw"];
        downloadExtraPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.patch"];
        
        if([fileManager fileExistsAtPath:downloadExtraPath isDirectory:false]) {
            [fileManager removeItemAtPath:downloadExtraPath error:nil];
        }
        
        fileDownloadInfo.downloadExtraPath = downloadExtraPath;
    }
    else {
        fileDownloadInfo.twoStage = false;
        downloadPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];
    }
    
    if([fileManager fileExistsAtPath:downloadPath isDirectory:false]) {
        [fileManager removeItemAtPath:downloadPath error:nil];
    }
    
    //fileDownloadInfo.appEntry = self.appEntry;
    fileDownloadInfo.downloadTask = [[APFPROJECTAPI currentInstance].session downloadTaskWithURL:[NSURL URLWithString:downloadUrl]];
    fileDownloadInfo.taskIdentifier = fileDownloadInfo.downloadTask.taskIdentifier;

    
    //NSLog(@"FileName: %@", fileDownloadInfo.downloadTask.fileName);
    //NSLog(@"Directory: %@", fileDownloadInfo.downloadTask.pathToDownloadDirectory);
    
    NSURL *URL = [NSURL URLWithString:downloadUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"HEAD"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        long long size = [response expectedContentLength];
        
        if(!fileDownloadInfo.twoStage) {
            fileDownloadInfo.totalFileLength = size;
            
            NSLog(@"Total File Size: %llu", fileDownloadInfo.totalFileLength);
            
            [self.cancelButton setHidden:NO];
            
            [fileDownloadInfo.downloadTask resume];
            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
            fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusDownloading;
            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
            [[APFPROJECTAPI currentInstance].fileDownloadDataArray addObject:fileDownloadInfo];
        }
        else {
            NSMutableURLRequest *requestExtra = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileDownloadInfo.downloadExtraSource]];
            [requestExtra setHTTPMethod:@"HEAD"];
            
            [NSURLConnection sendAsynchronousRequest:requestExtra queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                fileDownloadInfo.totalFileLength = size + [response expectedContentLength];
                
                [self.cancelButton setHidden:NO];
                
                [fileDownloadInfo.downloadTask resume];
                fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusDownloading;
                [[APFPROJECTAPI currentInstance].fileDownloadDataArray addObject:fileDownloadInfo];
            }];
        }
    }];
    
    ////////////////////////// OLD CODE *****
    /*
    NSString *downloadUrl = ((APFAppSignRequest *) sender).downloadAppUrl;

    APFFileDownloadInfo *fileDownloadInfo = [[APFFileDownloadInfo alloc] initWithFileAppId:self.appId
                                                                               andiTunesId:self.appiTunesId
                                                                                andAppName:self.appName
                                                                            andAppCategory:@""
                                                                             andAppVersion:@""
                                                                         andDownloadSource:downloadUrl];
    
    fileDownloadInfo.downloadTask = [[TCBlobDownloader alloc] initWithURL:[NSURL URLWithString:downloadUrl]
                                                             downloadPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), self.appId]]
                                                                 delegate:[APFPROJECTAPI currentInstance]];
    
    NSLog(@"FileName: %@", fileDownloadInfo.downloadTask.fileName);
    NSLog(@"Directory: %@", fileDownloadInfo.downloadTask.pathToDownloadDirectory);
    
    NSURL *URL = [NSURL URLWithString:downloadUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"HEAD"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               long long size = [response expectedContentLength];
                               fileDownloadInfo.totalFileLength = size;
                               
                               NSLog(@"Total File Size: %llu", fileDownloadInfo.totalFileLength);
                               
                               [self.cancelButton setHidden:NO];
                               
                               [[TCBlobDownloadManager sharedInstance] startDownload:fileDownloadInfo.downloadTask];
                               fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                               [[APFPROJECTAPI currentInstance].fileDownloadDataArray addObject:fileDownloadInfo];
                           }
     ];*/
    
}

- (void) failedDownloadAppUrl:(id)sender {
    self.circularProgressView.isPaused = NO;
    [self.circularProgressView setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    [self.circularProgressView setHidden:YES];
    [self.iconDownloadOverlay setHidden:YES];
}


@end
