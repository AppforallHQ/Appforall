//
//  APFFileDownloadInfo.h
//  PROJECT
//
//  Created by Nima Azimi on 16/July/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFAppEntry.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APFFileDownloadInfoStatus) {
    APFFileDownloadInfoStatusInit = 0,
    APFFileDownloadInfoStatusDownloading = 1,
    APFFileDownloadInfoStatusPaused = 2,
    APFFileDownloadInfoStatusCancelled = 3,
    APFFileDownloadInfoStatusCompleted = 4,
};


@interface APFFileDownloadInfo : NSObject <NSCoding>
{
    int tries;
}

@property (nonatomic, assign) BOOL twoStage;
@property (nonatomic, assign) int currentStage;

@property (nonatomic, assign) APFFileDownloadInfoStatus fileDownloadStatus;

@property (nonatomic, strong) APFAppEntry *appEntry;
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appIconUrl;
@property (nonatomic, strong) NSString *appiTunesId;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appCategory;
@property (nonatomic, strong) NSString *appVersion;

@property (nonatomic, strong) NSString *downloadSource;
@property (nonatomic, strong) NSString *downloadExtraSource;
@property (nonatomic, strong) NSString *downloadExtraPath;

@property (nonatomic, strong) UIImage *appIcon;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *taskResumeData;
@property (nonatomic) unsigned long taskIdentifier;
@property (nonatomic, assign) uint64_t downloadedBytes;
@property (nonatomic, assign) uint64_t totalFileLength;
@property (nonatomic) float downloadProgress;
@property (nonatomic) BOOL isDownloading;
@property (nonatomic) BOOL downloadComplete;
@property (nonatomic, assign) NSUInteger state;
@property (nonatomic, strong) NSString *pathToFile;
@property (nonatomic,strong) APFDownloader * activeIconDL;
@property (nonatomic, copy) void (^iconDownloadedHandler)(void);


-(id)initWithFileAppId:(NSString *)appId andAppName:(NSString*)appName andAppIcon:(NSString*)appIcon andItunesId:(NSString*) iTunesId;

-(id)initWithFileAppId:(NSString *)appId andiTunesId:(NSString*)appiTunesId andAppName:(NSString *)appName
        andAppCategory:(NSString *)appCategory andAppVersion:(NSString *)appVersion
     andDownloadSource:(NSString *)source andAppIcon:(NSString *)appIcon;

-(void)startDownloadIconWithSize;

@end
