//
//  APFAppDelegate.m
//  PROJECT
//
//  Created by PROJECT on 29/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFAppDelegate.h"
#import "APFPROJECTAPI.h"
#import "APFWelcomeViewController.h"
#import "APFFileDownloadInfo.h"
#import "PROJECT-Swift.h"
#import <Analytics/Analytics.h>
#import <SDCAlertView/SDCAlertView.h>
#import <sys/stat.h>
#import "UIColor+APFColors.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#include "APFUpdateAppsViewController.h"
//#import <DDLog.h>
//#import <DDTTYLogger.h>

@implementation APFAppDelegate


- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath{
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        if (!type || [[filePath pathExtension] isEqualToString:type]){
            [filePaths addObject:[directoryPath stringByAppendingPathComponent:filePath]];
            NSLog(@"%@",[directoryPath stringByAppendingPathComponent:filePath]);
        }
    }
    
    return filePaths;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[NRLogger setLogLevels:NRLogLevelError];
    //[NewRelicAgent startWithApplicationToken:@"NEWRELIC_TOKEN"];
    
    [Fabric with:@[CrashlyticsKit]];
    
    //[[Crashlytics sharedInstance] setDebugMode:YES];
    //[Crashlytics startWithAPIKey:@"CRASHLYTICS_TOKEN"];
    
    bgTask = [[APFBackgroundTask alloc] init];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil]];
    }
    
    
    application.applicationIconBadgeNumber = -1;
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *persistedDownloadDataPth = [documentsDirectory stringByAppendingPathComponent:@"downloadData.plist"];
    
    NSMutableArray *loadedDownloadData = [NSKeyedUnarchiver unarchiveObjectWithFile:persistedDownloadDataPth];
    if (loadedDownloadData != nil && (loadedDownloadData.count > 0)) {
        for(APFFileDownloadInfo * fileDownloadInfo in loadedDownloadData)
        {
            if(fileDownloadInfo.taskResumeData)
            {
                NSLog(@"TASK : %@ : %lu",fileDownloadInfo.appName,(unsigned long)fileDownloadInfo.taskResumeData.length);
            }
        }
        [APFPROJECTAPI currentInstance].fileDownloadDataArray = loadedDownloadData;
    }
    
    [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:@""]];

    // During development: reset the settings cache frequently so that
    // as you change settings on your integrations page, the settings update quickly here.
    // [[SEGAnalytics sharedAnalytics] reset]; //TODO: remove before app store release
    
    if([APFPROJECTAPI currentInstance].version == APFVersionPlus) {
        [[APFPROJECTAPI currentInstance] login];
    }
    
    ////////////////////////////////////////////////////////////
    // UINavigationBar appearance                             //
    ////////////////////////////////////////////////////////////
    
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [[UINavigationBar appearance] setTranslucent:NO];
        [[UITabBar appearance] setTranslucent:NO];
    }
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor userBlue]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"IRANSans" size:16.0],
                                                            NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"IRANSans" size:12.0]}
                                                forState:UIControlStateNormal];
    
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"IRANSans" size:12.0]}
                                                   forState:UIControlStateNormal];
    

    
    [[SDCAlertView appearance] setMessageLabelFont:[UIFont fontWithName:@"IRANSans" size:14.0]];
    [[SDCAlertView appearance] setTitleLabelFont:[UIFont fontWithName:@"IRANSans" size:15.0]];
    [[SDCAlertView appearance] setNormalButtonFont:[UIFont fontWithName:@"IRANSans" size:14.0]];
    [[SDCAlertView appearance] setSuggestedButtonFont:[UIFont fontWithName:@"IRANSans" size:14.0]];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"IRANSans" size:8.5]}
                                                 forState:UIControlStateNormal];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"IRANSans" size:12.0]}
                                                                                            forState:UIControlStateNormal];
    }
    else {
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"IRANSans" size:13.0]}
                                                                                            forState:UIControlStateNormal];
        
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"IRANSans" size:10.0]}
                                                 forState:UIControlStateNormal];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *documentDBFolderPath = [documentsDirectory stringByAppendingPathComponent:@"Web"];
    NSString *resourceDBFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    
    if (![fileManager fileExistsAtPath:documentDBFolderPath]) {
        //Create Directory!
        [fileManager createDirectoryAtPath:documentDBFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    } else {
        NSLog(@"Directory exists! %@", documentDBFolderPath);
    }
    
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:resourceDBFolderPath error:&error];
    for (NSString *s in fileList) {
        NSString *newFilePath = [documentDBFolderPath stringByAppendingPathComponent:s];
        NSString *oldFilePath = [resourceDBFolderPath stringByAppendingPathComponent:s];
        if (![fileManager fileExistsAtPath:newFilePath]) {
            //File does not exist, copy it
            [fileManager copyItemAtPath:oldFilePath toPath:newFilePath error:&error];
        }
    }
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
	NSLog(@"Setting document root: %@", documentDBFolderPath);
    
    //NSLog(@"FILES");
    //[self recursivePathsForResourcesOfType:nil inDirectory:documentDBFolderPath];
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.PROJECT"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;
    [sessionConfiguration setAllowsCellularAccess:true];
    
    
    [APFPROJECTAPI currentInstance].session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:[APFPROJECTAPI currentInstance]
                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    
    
    
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];
    [self.httpServer setPort:8080];
    [self.httpServer setDocumentRoot:documentDBFolderPath];
    

    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=https://repo.PROJECT.ir/ios9test/man6.plist"]]];
    
    
    /*[httpServer addGETHandlerForBasePath:@"/" directoryPath:documentDBFolderPath indexFilename:nil cacheAge:0 allowRangeRequests:true];
    [httpServer startWithOptions:@{
                                   GCDWebServerOption_BindToLocalhost: [NSNumber numberWithBool:true],
                                   GCDWebServerOption_AutomaticallySuspendInBackground: [NSNumber numberWithBool:true],
                                   GCDWebServerOption_ConnectedStateCoalescingInterval: [NSNumber numberWithDouble:30.0],
                                   GCDWebServerOption_BonjourName: @"",
                                   GCDWebServerOption_Port: [NSNumber numberWithUnsignedInteger:8080]
                                   } error:nil];*/
    
    /*if(![[NSUserDefaults standardUserDefaults] boolForKey:@"memory-fucked-2"]) {
        NSLog(@"Fucking memory up.");
        for(int i = 0; i < 25000; i++) { // 4KB * 1,000 * 10
            int *ptr = malloc(4096); // 4KB
            assert(ptr != NULL);
            *ptr = 0;
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"memory-fucked-2"];
    }
    else {
        NSLog(@"Memory is already fucked up.");
    }*/
    
    return YES;
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    NSLog(@"HandleEventsForBackgroundURLSession");
    self.backgroundTransferCompletionHandler = completionHandler;
    
}


-(void) retainBackground
{
    self.lastUpdate = [NSDate date];
    if(![bgTask running])
        [bgTask startBackgroundTasks:5 target:self selector:@selector(backgroundCallback:)];
    [self.httpServer start:nil];
}

/*- (void)startServer
{
    // Start the server (and check for problems)
	
	NSError *error;
	if([httpServer startW])
	{
		NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
	}
	else
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}
}*/

-(void) backgroundCallback:(id)info
{
    NSLog(@"### Bg Task Running");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    NSMutableArray *downloadDataToPersist = [APFPROJECTAPI currentInstance].fileDownloadDataArray;
//
//    for (APFFileDownloadInfo *fileDownloadInfo in downloadDataToPersist) {
//        
//        if (fileDownloadInfo.downloadTask) {
//            [fileDownloadInfo.downloadTask cancelDownloadAndRemoveFile:NO];
//            
//            NSFileManager *fm = [NSFileManager defaultManager];
//            
//            if ([fm fileExistsAtPath:fileDownloadInfo.downloadTask.pathToFile]) {
//                struct stat statbuf;
//                const char *cpath = [fileDownloadInfo.downloadTask.pathToFile fileSystemRepresentation];
//                if (cpath && stat(cpath, &statbuf) == 0) {
//                    NSNumber *fileSize = [NSNumber numberWithUnsignedLongLong:statbuf.st_size];
//                    fileDownloadInfo.downloadedBytes = [fileSize unsignedLongLongValue];
//                }
//            }
//            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
//        }
//    }

//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths firstObject];
//    NSString *downloadDataPathForPersistance = [documentsDirectory stringByAppendingPathComponent:@"downloadData.plist"];
//    [NSKeyedArchiver archiveRootObject:downloadDataToPersist toFile:downloadDataPathForPersistance];
    

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = -1;
    if ([[APFPROJECTAPI currentInstance].PROJECTApiDelegate isKindOfClass:(APFUpdateAppsViewController.class)]) {
        [(APFUpdateAppsViewController *) [APFPROJECTAPI currentInstance].PROJECTApiDelegate fetchDataAndReloadTable];
    }
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths firstObject];
//    NSString *persistedDownloadDataPth = [documentsDirectory stringByAppendingPathComponent:@"downloadData.plist"];
//    NSMutableArray *loadedDownloadData = [NSKeyedUnarchiver unarchiveObjectWithFile:persistedDownloadDataPth];
//    if (loadedDownloadData != nil && (loadedDownloadData.count > 0)) {
//        [APFPROJECTAPI currentInstance].fileDownloadDataArray = loadedDownloadData;
//    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"Application will terminate...");
    [self.httpServer stop];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSMutableArray *downloadDataToPersist = [APFPROJECTAPI currentInstance].fileDownloadDataArray;
    //NSMutableArray *successfulDownloadDataToPersist = [APFPROJECTAPI currentInstance].successfulDownloadDataArray;


    for (APFFileDownloadInfo *fileDownloadInfo in downloadDataToPersist) {

        if (fileDownloadInfo.downloadTask && fileDownloadInfo.downloadTask.state == NSURLSessionTaskStateRunning) {
            [fileDownloadInfo.downloadTask cancel];
            [downloadDataToPersist removeObject:fileDownloadInfo];
        }
        if(fileDownloadInfo.taskResumeData)
        {
            NSLog(@"TASK : %@ : %lu",fileDownloadInfo.appName,(unsigned long)fileDownloadInfo.taskResumeData.length);
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *downloadDataPathForPersistance = [documentsDirectory stringByAppendingPathComponent:@"downloadData.plist"];
    //NSString *successfulDownloadDataPathForPersistance = [documentsDirectory stringByAppendingPathComponent:@"downloadDataSuccess.plist"];
    [NSKeyedArchiver archiveRootObject:downloadDataToPersist toFile:downloadDataPathForPersistance];
    //[NSKeyedArchiver archiveRootObject:successfulDownloadDataToPersist toFile:successfulDownloadDataPathForPersistance];

}

-(void) installApp:(NSString*) appId
{
    [self retainBackground];
    if ([[APFPROJECTAPI currentInstance].PROJECTApiDelegate isKindOfClass:(APFAppDescriptionViewController.class)]) {
        APFAppDescriptionViewController * app = ((APFAppDescriptionViewController *) [APFPROJECTAPI currentInstance].PROJECTApiDelegate);
        
        if(app.appDescription.applicationCopies && app.appDescription.applicationCopies.count > 0)
        {
            NSString *AppappId = [[app.appDescription.applicationCopies lastObject] objectForKey:@"lid"];
            if([AppappId isEqualToString:appId])
            {
                [app.installButton setTitle:@"در حال نصب..." forState:UIControlStateDisabled];
                [app.installButton setEnabled:false];
            }
        }
    }
    if ([[APFPROJECTAPI currentInstance] isNotMerged:appId])
    {
        [SVProgressHUD showProgress:-1];
        [[APFPROJECTAPI currentInstance] mergeZipFilesWithAppId:appId];
        [SVProgressHUD dismiss];
    }
    NSString *manifestPath = [NSString stringWithFormat:MANIFEST_DOWNLOAD_PATH, appId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", manifestPath]]];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    application.applicationIconBadgeNumber = -1;
    NSString *appId = [notification.userInfo objectForKey:@"AppId"];
    NSString *appName = [notification.userInfo objectForKey:@"AppName"];
    
    if (![appId isKindOfClass:[NSNull class]] && appId != nil && (appId.length > 0)) {
        SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                          message:[NSString stringWithFormat:@"دانلود %@ با موفقیت انجام شد.\nبا انتخاب دکمه install نصب شروع می‌شود. برای مشاهده برنامه نصب شده دکمه Home را بزنید.", appName]
                                                         delegate:nil
                                                cancelButtonTitle:@"تایید"
                                                otherButtonTitles:nil, nil];
        [alert show];
        
        [self performSelector:@selector(installApp:) withObject:appId afterDelay:8];
        
    } else {
        SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                          message:[NSString stringWithFormat:@"خطا در دانلود برنامه %@ برای ادامه دانلود پس از بررسی اینترنت دوباره اقدام نمایید.", appName]
                                                         delegate:nil
                                                cancelButtonTitle:@"تایید"
                                                otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [APFDeepLinker.sharedInstance handleUrl:url];
    return YES;
}

@end
