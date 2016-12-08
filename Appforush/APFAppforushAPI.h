//
//  APFPROJECTAPI.h
//  PROJECT
//
//  Created by PROJECT on 30/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSApplicationProxy.h"
#import <objc/runtime.h>
#import "APFAppDescription.h"
#import "APFAppSignRequest.h"
#import "APFUserInfo.h"
#import "APFAppDelegate.h"
#import "APFBackgroundTask.h"

#define VERSION @"2.7.0"

#define API_ROOT @"https://API_ROOT"
#define PANEL_ROOT @"https://PANEL_ROOT"
#define MANIFEST_DOWNLOAD_PATH API_ROOT@"apps/download/manifest/%@/"

//#define CHILKAT_UNLOCK_CODE @"NCCSBEMVC_eNqjUqdCcLfl"

typedef NS_ENUM(NSInteger, UserStatus) {
    UserStatusOk = 1,
    UserStatusLimited = 2,
    UserStatusEmailNotActive = 4,
    UserStatusBlocked = 99,
    UserStatusUnknown = -1,
    UserStatusConnectionProblem = -2
};

typedef NS_ENUM(NSUInteger, APFVersion) {
    APFVersionBasic = 1,
    APFVersionPlus = 2
};

typedef NS_ENUM(NSUInteger, APFLoginState) {
    APFLoginStateSuccess = 1,
    APFLoginStateInvalidUsernameOrPassword = 2
};

@protocol APFPROJECTAPIDelegate <NSObject>

@optional

- (void) PROJECTAPILoadingWasCompleted:(id)sender withState:(APFLoginState)state;
- (void) didDownloadProgressForAppId:(NSString *)appId withProgress:(double)progress;
- (void) didDownloadFail;
- (void) didDownloadFinish;
- (void) didRegisterSuccessful;

@end


@interface APFPROJECTAPI : NSObject <NSURLSessionDelegate> {

    NSString* _dID;
    NSString* _idfv;
    NSString* _aid;
    NSString* _uuid;
    NSString* _loginUsername;
    NSString* _loginPassword;
    //NSURL* urlToHandle;
}

@property (nonatomic, assign) APFVersion version;
@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, retain) NSString *dID;
@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, retain, readonly) NSString* idfv;
@property (nonatomic, retain, readonly) NSString* aid;
@property (nonatomic, retain, readonly) NSString* uuid;
@property (nonatomic, retain, readonly) NSString* deviceName;

@property (nonatomic, strong) APFUserInfo *apfUserInfo;
@property (nonatomic, assign) BOOL working;
@property (nonatomic, assign) BOOL enteredTheApp;
@property (nonatomic, assign) BOOL compulsaryUpdate;


@property (nonatomic, assign) id<APFPROJECTAPIDelegate> PROJECTApiDelegate;

@property (nonatomic, strong) NSMutableArray *fileDownloadDataArray;
@property (nonatomic, strong) NSMutableArray *successfulDownloadDataArray;
@property (nonatomic, strong) NSMutableArray *failedDownloadDataArray;
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURL *documentDirectoryURL;

@property (nonatomic, strong) NSString *chatURL;

@property (nonatomic, assign) NSUInteger availableUpdatesCount;

@property (nonatomic, assign) NSString * emailToResend;

@property (nonatomic, strong) NSMutableArray * updatesList;
@property (nonatomic, strong) UIWindow * emailWindow;
@property (nonatomic, strong) UIWindow * mainWindow;
-(void) showEmailActivation;
-(void) hideEmailActivation;


-(void) registerErrorWithError:(NSString *)errorMessage;

+(APFPROJECTAPI*) currentInstance;

-(BOOL) isApplicationInstalled:(NSString *)appId;

-(NSArray*) parseDataList:(NSData*)data;
-(NSArray*) processAppsArray:(NSArray*)list;
-(APFAppDescription*) parseDescriptionFromData:(NSData*)data;
-(NSString*) getURLForAppDescriptionWithiTunesID:(NSString*)iTunesID forAppBuy:(BOOL)isAppBuy;
-(NSString*) getURLForAppListWithPage:(int)page;
-(NSString*) getURLForTopList:(NSString*)category withPage:(int)page forType:(NSString*)type;
-(NSString*) getURLForTagList:(NSArray*)tags withPage:(int)page forAppBuy:(BOOL)isAppBuy;

-(void) proposeAppWithId:(NSString*)appid;
-(void) hideAppUpdate:(NSString*)appid andComplete:(void(^)())completionHandler;

-(NSData*) getFeaturedPageData;
-(NSArray*) getTopAppList;
-(NSArray*) getWeeklyTopList;
-(NSArray*) getAppListByURL:(NSString*)url page:(NSInteger)page;
-(NSArray*) getLatestListPage:(int) page;
-(NSArray*) getDownloadHistory:(int) page;
-(NSDictionary*) lidLookup:(NSArray*) lids;
-(NSArray*) getSimilarApps:(NSString*)appid category:(NSString*)category;
-(NSArray*) getTopApps:(NSString*)category listPage:(int)page forType:(NSString*)type;
-(NSArray*) getTagCategory:(NSArray*)tags listPage:(int) page forAppBuy:(BOOL)isAppBuy;
-(NSArray*) getRecommendedApps:(NSArray*)ids;
-(APFAppDescription*) getAppDescriptionWithID:(NSString*)iTunesID forAppBuy:(BOOL)isAppBuy;
-(NSMutableArray*) getUpdateAppList;
-(NSArray*) getRelatedAppList:(NSString*)category;
-(NSArray*) getCollectionApps:(NSString*)collectionName page:(NSInteger)page;
-(NSArray*) getAppBuyHistory:(int)page;

-(void) login;
-(void) loginWithUsername:(NSString*)username password:(NSString*)password;
-(void)registerWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name tel:(NSString*)tel;
-(void)resendActivationWithEmail:(NSString*)email;
-(void)forgotPasswordWithEmail:(NSString*)email;
-(void) identifyWith:(NSDictionary*)data;

-(NSString *) rot13String:(NSString *)stringToChange;

-(APFAppSignRequest*) requestDownloadForAppID:(NSString*) appid;

-(BOOL) isNotMerged:(NSString*)appId;
-(BOOL) mergeZipFilesWithAppId:(NSString*)appId;


//-(APFUserInfo*) fetchUserStatus;

@end
