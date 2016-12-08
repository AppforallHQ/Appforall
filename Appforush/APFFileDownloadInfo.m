//
//  APFFileDownloadInfo.m
//  PROJECT
//
//  Created by Nima Azimi on 16/July/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFFileDownloadInfo.h"

#define kAppIdKey                   @"AppId"
#define kAppiTunesIdKey                   @"AppiTunesId"
#define kAppNameKey                 @"AppName"
#define kAppCategoryKey             @"AppCategory"
#define kAppVersionKey              @"AppVersion"
#define kAppIcon                    @"AppIcon"
#define kDownloadSourceKey          @"DownloadSource"
#define kDownloadExtraSource        @"DownloadExtraSource"
#define kDownloadExtraPath          @"DownloadExtraPath"
#define kDownloadProgressKey        @"DownloadProgressKey"
#define kIsDownloadingKey           @"IsDownloadingKey"
#define kDownloadCompleteKey        @"DownloadCompleteKey"
#define kDownloadTaskKey            @"DownloadTaskKey"
#define kDownloadedBytesKey         @"DownloadedBytesKey"
#define kTotalFileLengthKey         @"TotalFileLengthKey"
#define kStateKey                   @"StateKey"
#define kPathToFileKey              @"PathToFileKey"
#define kTaskResumeDataKey          @"TaskResumeDataKey"
#define kFileDownloadStatus         @"FileDownloadStatus"
#define kTwoStage                   @"TwoStage"
#define kCurrentStage               @"CurrentStage"

@implementation APFFileDownloadInfo


-(id)initWithFileAppId:(NSString *)appId andAppName:(NSString*)appName andAppIcon:(NSString*)appIcon andItunesId:(NSString*) iTunesId
{
    if (self==[super init])
    {
        self.appId = appId;
        self.appName = appName;
        self.appIconUrl = appIcon;
        self.appiTunesId = iTunesId;
    }
    return self;
}

-(id)initWithFileAppId:(NSString *)appId andiTunesId:(NSString*)appiTunesId andAppName:(NSString *)appName
        andAppCategory:(NSString *)appCategory andAppVersion:(NSString *)appVersion
     andDownloadSource:(NSString *)source andAppIcon:(NSString *)appIcon {
    if (self == [super init]) {
        self.appId = appId;
        self.appiTunesId = appiTunesId;
        self.appName = appName;
        self.appCategory = appCategory;
        self.appVersion = appVersion;
        self.downloadSource = source;
        self.downloadExtraPath = @"";
        self.downloadExtraSource = @"";
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.downloadTask = nil;
        self.taskResumeData = nil;
        self.taskIdentifier = 0;
        self.downloadedBytes = 0;
        self.totalFileLength = 0;
        self.state = 0;
        self.pathToFile = nil;
        self.fileDownloadStatus = APFFileDownloadInfoStatusInit;
        self.appIconUrl = appIcon;
    }
    
    return self;
}

-(id)initWithFileAppId:(NSString *)appId andAppName:(NSString *)appName
        andAppCategory:(NSString *)appCategory andAppIcon:(NSString *)appIcon andAppVersion:(NSString *)appVersion
     andDownloadSource:(NSString *)source andDownloadProgress:(float)downloadProgress
      andIsDownloading:(BOOL)isDownloading andDownloadComplete:(BOOL)downloadComplete
       andDownloadTask:(NSURLSessionDownloadTask *)downloadTask andDownloadedByte:(uint64_t)downloadedByte
    andTotalFileLength:(uint64_t)totalFileLength andState:(NSUInteger)state andPathToFile:(NSString *)pathToFile andResumeData:(NSData*)resumeData andFileDownloadStatus:(APFFileDownloadInfoStatus)downloadInfoStatus andTwoStage:(BOOL)twoStage andCurrentStage:(int)currentStage {
    if (self == [super init]) {
        self.appId = appId;
        self.appName = appName;
        self.appCategory = appCategory;
        self.appVersion = appVersion;
        self.downloadSource = source;
        self.downloadProgress = downloadProgress;
        self.isDownloading = isDownloading;
        self.downloadComplete = downloadComplete;
        self.downloadTask = downloadTask;
        self.taskIdentifier = downloadTask.taskIdentifier;
        self.taskResumeData = resumeData;
        self.downloadedBytes = downloadedByte;
        self.totalFileLength = totalFileLength;
        self.state = state;
        self.pathToFile = pathToFile;
        self.fileDownloadStatus = downloadInfoStatus;
        self.twoStage = twoStage;
        self.currentStage = currentStage;
        self.appIconUrl = appIcon;
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_appId forKey:kAppIdKey];
    [encoder encodeObject:_appiTunesId forKey:kAppiTunesIdKey];
    [encoder encodeObject:_appName forKey:kAppNameKey];
    [encoder encodeObject:_appCategory forKey:kAppCategoryKey];
    [encoder encodeObject:_appVersion forKey:kAppVersionKey];
    [encoder encodeObject:_downloadSource forKey:kDownloadSourceKey];
    [encoder encodeObject:_downloadExtraPath forKey:kDownloadExtraPath];
    [encoder encodeObject:_downloadExtraSource forKey:kDownloadExtraSource];
    [encoder encodeFloat:_downloadProgress forKey:kDownloadProgressKey];
    [encoder encodeBool:_isDownloading forKey:kIsDownloadingKey];
    [encoder encodeBool:_downloadComplete forKey:kDownloadCompleteKey];
    [encoder encodeInt64:_downloadedBytes forKey:kDownloadedBytesKey];
    [encoder encodeInt64:_totalFileLength forKey:kTotalFileLengthKey];
    [encoder encodeInteger:_state forKey:kStateKey];
    [encoder encodeObject:_pathToFile forKey:kPathToFileKey];
    [encoder encodeObject:_taskResumeData forKey:kTaskResumeDataKey];
    [encoder encodeInteger:_fileDownloadStatus forKey:kFileDownloadStatus];
    [encoder encodeInt:_currentStage forKey:kCurrentStage];
    [encoder encodeBool:_twoStage forKey:kTwoStage];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *appId = [decoder decodeObjectForKey:kAppIdKey];
    NSString *appiTunesId = [decoder decodeObjectForKey:kAppiTunesIdKey];
    NSString *appName = [decoder decodeObjectForKey:kAppNameKey];
    NSString *appCategory = [decoder decodeObjectForKey:kAppCategoryKey];
    NSString *appVersion = [decoder decodeObjectForKey:kAppVersionKey];
    NSString *downloadSourceKey = [decoder decodeObjectForKey:kDownloadSourceKey];
    NSString *downloadExtraSource = [decoder decodeObjectForKey:kDownloadExtraSource];
    NSString *downloadExtraPath = [decoder decodeObjectForKey:kDownloadExtraPath];
    float downloadProgress = [decoder decodeFloatForKey:kDownloadProgressKey];
    BOOL isDownloading = [decoder decodeBoolForKey:kIsDownloadingKey];
    BOOL downloadComplete = [decoder decodeBoolForKey:kDownloadCompleteKey];
    uint64_t downloadedByte = [decoder decodeInt64ForKey:kDownloadedBytesKey];
    uint64_t totalFileLength = [decoder decodeInt64ForKey:kTotalFileLengthKey];
    NSUInteger state = [decoder decodeIntegerForKey:kStateKey];
    NSString *pathToFile = [decoder decodeObjectForKey:kPathToFileKey];
    NSData * resumeData = [decoder decodeObjectForKey:kTaskResumeDataKey];
    APFFileDownloadInfoStatus status = [decoder decodeIntegerForKey:kFileDownloadStatus];
    BOOL twoStage = [decoder decodeBoolForKey:kTwoStage];
    int currentStage = [decoder decodeIntForKey:kCurrentStage];
    NSString * appIconUrl = [decoder decodeObjectForKey:kAppIcon];
    
    APFFileDownloadInfo* dlInfo = [self initWithFileAppId:appId andAppName:appName andAppCategory:appCategory andAppIcon:appIconUrl
                     andAppVersion:appVersion andDownloadSource:downloadSourceKey
               andDownloadProgress:downloadProgress andIsDownloading:isDownloading andDownloadComplete:downloadComplete
                   andDownloadTask:nil andDownloadedByte:downloadedByte andTotalFileLength:totalFileLength andState:state
            andPathToFile:pathToFile andResumeData:resumeData andFileDownloadStatus:status andTwoStage:twoStage andCurrentStage:currentStage];
    
    dlInfo.downloadExtraPath = downloadExtraPath;
    dlInfo.downloadExtraSource = downloadExtraSource;
    dlInfo.appiTunesId = appiTunesId;
    
    return dlInfo;
}


-(void)startDownloadIconWithSize {
    if (self.activeIconDL) {
        return;
    }
    
    NSString *urlString = self.appIconUrl;
    APFFileDownloadInfo * link = self;
    
    if(!urlString)
        return;
    
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:urlString withLifeTime:[NSNumber numberWithDouble:10*24*3600] useAppStoreUserAgent:TRUE];
    self.activeIconDL = dl;
    
    __weak APFDownloader *dlLink = dl;
    
    dl.didFinishDownload = ^(NSData *data){
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        link.appIcon = image;
        
        // call our delegate and tell it that our icon is ready for display
        if (link.iconDownloadedHandler)
            link.iconDownloadedHandler();
        
        self.activeIconDL = nil;
    };
    
    dl.didFailDownload = ^(NSError* err){
        if(link->tries < 2){
            NSLog(@"Download has failed, trying again");
        }else{
            NSLog(@"Giving up on %@.\nError: %@", dlLink.downloadURL, [err localizedDescription]);
        }
        [dlLink start];
        link->tries++;
    };
    
    self.activeIconDL = dl;
    [dl start];
}



@end
