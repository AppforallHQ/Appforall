//
//  APFPROJECTAPI.m
//  PROJECT
//
//  Created by PROJECT on 30/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFPROJECTAPI.h"
#import "APFDownloader.h"
#import "APFAppEntry.h"
#import "APFFileDownloadInfo.h"
#import "APFAppDescriptionViewController.h"
#import "APFUpdateAppsViewController.h"
#import "APFUpdateAppTableViewCell.h"
#import "SVProgressHUD.h"
#import "NSString+URLEncode.h"
#import "NSFileManager+DoNotBackup.h"
#import <Analytics/Analytics.h>
#import <SDCAlertView/SDCAlertView.h>
#import "SSKeychain/SSKeychain.h"
//#import <TCBlobDownload/TCBlobDownload.h>
//#import "CkoZip.h"
//#import "CkoZipEntry.h"
//#import <zipzap/zipzap.h>
#import "Objective-Zip.h"
#import "Objective-Zip+NSError.h"
@import AdSupport;
#import <sys/utsname.h> // import it in your header or implementation file.
#include <CommonCrypto/CommonDigest.h>
#import "PROJECT-Swift.h"

#define LOGIN_PATH API_ROOT@"login/?ver="VERSION@"&id=%@&aid=%@"
#define LOGIN_PATH_LIFETIME [NSNumber numberWithDouble:0]

#define LOGIN_WITH_USERNAME_PATH API_ROOT@"login/?ver="VERSION@"&id=%@&username=%@&password=%@&aid=%@&idfv=%@&uuid=%@&dev=%@&data=%@"
#define LOGIN_WITH_USERNAME_PATH_LIFETIME [NSNumber numberWithDouble:0]

#define REGISTER_WITH_USERNAME_PATH PANEL_ROOT@"register/api/"
#define REGISTER_WITH_USERNAME_BODY @"aid=%@&first_name=%@&idfv=%@&mobile_number=%@&username=%@&password=%@&uuid=%@&dev=%@&data=%@"
#define REGISTER_WITH_USERNAME_PATH_LIFETIME [NSNumber numberWithDouble:0]

#define RESEND_ACTIVATION_PATH PANEL_ROOT@"register/resend_activation/"
#define RESEND_ACTIVATION_BODY @"username=%@"
#define RESEND_ACTIVATION_PATH_LIFETIME [NSNumber numberWithDouble:0]

#define RESET_PASSWORD_PATH PANEL_ROOT@"reset/"
#define RESET_PASSWORD_BODY @"username=%@"
#define RESET_PASSWORD_PATH_LIFETIME [NSNumber numberWithDouble:0]

#define FEATURED_PATH API_ROOT@"data/featured/"
#define FEATURED_PATH_LIFETIME [NSNumber numberWithDouble:0]

#define UPDATES_PATH API_ROOT@"data/updates/?id=%@&aid=%@&token=%@"
#define UPDATES_PATH_LIFETIME [NSNumber numberWithDouble:0]

#define GET_TOP_APP_LIST API_ROOT@"data/list/"
#define GET_TOP_APP_LIST_LIFETIME [NSNumber numberWithDouble:0] //Prev 4*3600

#define GET_WEEKLY_TOP_APP_LIST API_ROOT@"data/top/week/"
#define GET_WEEKLY_TOP_APP_LIST_LIFETIME [NSNumber numberWithDouble:0] //Prev 24*3600

#define GET_APP_INFO API_ROOT@"data/info/?appid=%@"
#define GET_APP_INFO_LIFETIME [NSNumber numberWithDouble:0] //Prev 3600

#define LID_LOOKUP API_ROOT@"data/lidlookup/?id=%@"
#define LID_LOOKUP_LIFETIME [NSNumber numberWithDouble:0] //Prev 3600


#define GET_APPBUY_APP_INFO API_ROOT@"shop/appinfo/?appid=%@"
#define GET_APPBUY_APP_INFO_LIFETIME [NSNumber numberWithDouble:0] //Prev 3600

#define GET_LATEST_APPS API_ROOT@"data/list/?p=%d&debug=1"
#define GET_LATEST_APPS_LIFETIME [NSNumber numberWithDouble:0] //Prev 4*3600

#define GET_COLLECTION_APPS API_ROOT@"data/list/?tag=%@&p=%d"
#define GET_COLLECTION_APPS_LIFETIME [NSNumber numberWithDouble:0]

#define GET_CAT_APPS API_ROOT@"data/list/?cat=%@&p=%d"
#define GET_CAT_APPS_LIFETIME [NSNumber numberWithDouble:0] //Prev 4*3600

#define GET_TOP_APPS API_ROOT@"shop/cats/?cat=%@&dev=%@&t=%@&p=%d"
#define GET_TOP_APPS_LIFETIME [NSNumber numberWithDouble:0] //Prev 4*3600

#define GET_TAG_APPS API_ROOT@"data/list/?%@&p=%d"
#define GET_TAG_PARAM @"tag=%@"
#define GET_TAG_APPS_LIFETIME [NSNumber numberWithDouble:0] //Prev 4*3600

#define GET_APPBUY_CAT_APPS API_ROOT@"shop/list/?cat=%@&p=%d&dev=%@"
#define GET_APPBUY_CAT_APPS_LIFETIME [NSNumber numberWithDouble:0]

#define INSTALL_REQUEST API_ROOT@"data/download/request/?id=%@&aid=%@&appid=%@&token=%@&ts=1&afver="VERSION // Two-stage ENABLED (ts=1).
#define INSTALL_REQUEST_LIFETIME [NSNumber numberWithDouble:0]

#define GET_APPBUY_TAG_APPS API_ROOT@"shop/list/?%@&p=%d&dev=%@"
#define GET_APPBUY_TAG_APPS_LIFETIME [NSNumber numberWithDouble:0]

#define DOWNLOAD_HISTORY API_ROOT@"data/downloads/?id=%@&aid=%@&token=%@&p=%d"
#define DOWNLOAD_HISTORY_LIFETIME [NSNumber numberWithDouble:0]

#define GET_RELATED_APP_LIST API_ROOT@"data/list/?sort=4&cat=%@"
#define GET_RELATED_APP_LISTLIFETIME [NSNumber numberWithDouble:0]

#define APPBUY_HISTORY API_ROOT@"shop/history/?id=%@&aid=%@&userid=%@&p=%d"
#define APPBUY_HISTORY_LIFETIME [NSNumber numberWithDouble:0]

#define GET_SIMILAR_APPS API_ROOT@"data/recommend/?appid=%@&cat=%@"
#define GET_SIMILAR_APPS_LIFETIME [NSNumber numberWithDouble:0]

#define LOOKUP_RECOMMEND API_ROOT@"shop/lookup/?appid=%@"
#define LOOKUP_RECOMMEND_LIFETIME [NSNumber numberWithDouble:0]

#define PROPOSE_APP API_ROOT@"data/proposal/?userid=%@&id=%@"
#define PROPOSE_APP_LIFETIME [NSNumber numberWithDouble:0]

#define HIDE_UPDATE API_ROOT@"data/updates/hide/?id=%@&token=%@&appid=%@"
#define HIDE_UPDATE_LIFETIME [NSNumber numberWithDouble:0]

#define GET_APP_LIST_LIFETIME 0
#define MANIFEST_DOWNLOAD_PATH_LIFETIME 0

#define PAD_FOR_HASH @"SOME_HASH"

#define FINISH_DOWNLOAD API_ROOT@"data/download/finished/?id=%@&aid=%@&token=%@&appid=%@"
#define FINISH_DOWNLOAD_LIFETIME [NSNumber numberWithDouble:0]

#define LC_URL              "http://cdn.livechatinc.com/app/mobile/urls.json"
#define LC_LICENSE          "LC_LICENSE"
#define LC_CHAT_GROUP       "0"

#define CHAT_URL_BASE       @"https://CHAT_URL/?id=%@&udid=%@"

#define BASIC_VERSION_UDID  @"t111111111111111111111111111111111111111" // one t and 39 ones.


static APFPROJECTAPI *instance;

@implementation APFPROJECTAPI

+(APFPROJECTAPI*) currentInstance{
    if (!instance){
        instance = [[APFPROJECTAPI alloc] init];
        instance.working = NO;
        instance.enteredTheApp = NO;
        instance.compulsaryUpdate = NO;

        NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        instance.documentDirectoryURL = [URLs objectAtIndex:0];
        instance.fileDownloadDataArray = [[NSMutableArray alloc] init];
        instance.successfulDownloadDataArray = [[NSMutableArray alloc] init];

#if !(TARGET_IPHONE_SIMULATOR)
        instance.dID = @"SOME_ID";
#else
        instance.dID = @"SOME_OTHER_ID";
#endif

        if([instance.dID isEqualToString:BASIC_VERSION_UDID]) {
            instance.version = APFVersionBasic;
        }
        else {
            instance.version = APFVersionPlus;
        }

        [SVProgressHUD setFont:[UIFont fontWithName:@"IRANSans" size:15.0]];
    }
    return instance;
}

-(NSString*) idfv {
    if(_idfv) {
        return _idfv;
    }

    NSString * idfvStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    _idfv = idfvStr;

    return idfvStr;
}

-(NSString*) aid {
    if(_aid) {
        return _aid;
    }
    NSString * idfvStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    _aid = idfvStr;
    
    return idfvStr;
}

- (NSString*) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

-(NSString*) uuid {
    if(_uuid) {
        return _uuid;
    }
    
    NSString* appID = [[NSBundle mainBundle] bundleIdentifier];
    NSString* idfvStr = [SSKeychain passwordForService:appID account:@"uuid"];
    
    if(idfvStr == nil) {
        idfvStr = [[NSUUID UUID] UUIDString];
        [SSKeychain setPassword:idfvStr forService:appID account:@"uuid"];
    }
    
    _uuid = idfvStr;
    
    return idfvStr;
}

- (NSString *) createSHA512:(NSString *)source {
    
    const char *s = [source cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
    
    CC_SHA512(keyData.bytes, keyData.length, digest);
    
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    
    return [out description];
}

-(NSString *) hashData:(NSString*)idfv andAid:(NSString*)aid andUuid:(NSString*)uuid andDeviceName:(NSString*)deviceName {
    NSString * data = [NSString stringWithFormat:@"%@|%@|%@|%@_%@",idfv,aid,uuid,deviceName,PAD_FOR_HASH];
    return [self createSHA512:data];
}

-(NSArray *) getAllInstalledApplications
{
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    LSApplicationWorkspace * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSArray <LSApplicationProxy *> *apps = [workspace allApplications];
    return apps;
}

-(BOOL) isApplicationInstalled:(NSString *)appId
{
    NSString *appSchemaUrl = [NSString stringWithFormat:@"useriid-%@",appId];
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    LSApplicationWorkspace * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSArray <LSApplicationProxy *> *apps = [workspace applicationsAvailableForHandlingURLScheme:appSchemaUrl];
    return [apps count] > 0;
}




-(void) identifyWith:(NSDictionary*)data {
    if(!data || ![@"ok" isEqualToString:[data objectForKey:@"status"]]) {
        [[SEGAnalytics sharedAnalytics] identify:self.dID traits:nil];
        [[SEGAnalytics sharedAnalytics] track:@"run_PROJECT"];
        //[self connectionError];
        [self initialConnectionError];
        return;
    }

    [SVProgressHUD dismiss];

    NSString* userID  = nil;
    self.availableUpdatesCount = 0;

    if(self.version == APFVersionBasic) {
        self.authToken = [data objectForKey:@"token"];

        if(self.authToken == nil) {
            if ([self.PROJECTApiDelegate respondsToSelector:@selector(PROJECTAPILoadingWasCompleted:withState:)]) {
                [self.PROJECTApiDelegate PROJECTAPILoadingWasCompleted:self withState:APFLoginStateInvalidUsernameOrPassword];
            }
            
            return;
        }
    }
    else {
        self.authToken = @"";
    }

    userID = [data objectForKey:@"userID"];
    self.userFirstName = [data objectForKey:@"name"];
    NSString *userEmail = [data objectForKey:@"email"];

    self.apfUserInfo = [[APFUserInfo alloc] initWithId:userID andFirstName:self.userFirstName andEmail:userEmail];
    self.apfUserInfo.avatarUrl = [data objectForKey:@"avatar"];

    [self requestChatUrlWithEmail:userEmail]; // FUCKING IMPORTANT

    if(![[data objectForKey:@"expire_date"] isKindOfClass:[NSNull class]]) {
        self.apfUserInfo.expire_date = [APFUserInfo dateJSONTransformer:[data objectForKey:@"expire_date"]];
    }
    else {
        self.apfUserInfo.expire_date = nil;
    }
    NSLog(@"%@",data);
    if(![[data objectForKey:@"campaigns"] isKindOfClass:[NSNull class]]) {
        self.apfUserInfo.campaigns = [APFUserInfo campaignsDate:[data objectForKey:@"campaigns"]];
    }
    else {
        self.apfUserInfo.campaigns = nil;
    }
    

    if(userID != nil) {
        [[SEGAnalytics sharedAnalytics] identify:userID traits:nil];

        NSMutableArray *appEntries = [self getUpdateAppList];
        /*for (APFAppEntry *app in [appEntries copy]) {
            NSString *appSchemaUrl = [NSString stringWithFormat:@"useriid-%@://", app.applicationiTunesIdentification];

            if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appSchemaUrl]]) {
                [appEntries removeObject:app];
            }
        }*/

        if (appEntries.count > 0) {
            self.availableUpdatesCount = appEntries.count;
        }
    }
    else {
        [[SEGAnalytics sharedAnalytics] identify:self.dID traits:nil];
    }

    [[SEGAnalytics sharedAnalytics] track:@"run_PROJECT"];

    if ([self.PROJECTApiDelegate respondsToSelector:@selector(PROJECTAPILoadingWasCompleted:withState:)]) {
        [self.PROJECTApiDelegate PROJECTAPILoadingWasCompleted:self withState:APFLoginStateSuccess];
    }

}

-(NSString *) rot13String:(NSString *)stringToChange
{
	const char *_string = [stringToChange cStringUsingEncoding:NSASCIIStringEncoding];
	NSUInteger stringLength = stringToChange.length;
	char newString[stringLength+1];

	int x;
	for( x=0; x<stringLength; x++ )
	{
		unsigned int aCharacter = _string[x];

		if( 0x40 < aCharacter && aCharacter < 0x5B ) // A - Z
			newString[x] = (((aCharacter - 0x41) + 0x0D) % 0x1A) + 0x41;
		else if( 0x60 < aCharacter && aCharacter < 0x7B ) // a-z
			newString[x] = (((aCharacter - 0x61) + 0x0D) % 0x1A) + 0x61;
		else  // Not an alpha character
			newString[x] = aCharacter;
	}

	newString[x] = '\0';

	NSString *rotString = [NSString stringWithCString:newString encoding:NSASCIIStringEncoding];
	return( rotString );
}

-(APFAppSignRequest*) requestDownloadForAppID:(NSString*) appid {
    NSString *reqAdr = [NSString stringWithFormat:INSTALL_REQUEST, self.dID, self.idfv, appid, self.authToken];

    NSLog(@"Making request to %@", reqAdr);

    APFAppSignRequest* ret = [[APFAppSignRequest alloc] initWithDownloader:[[APFDownloader alloc] initWithDownloadURLString:reqAdr withLifeTime:INSTALL_REQUEST_LIFETIME] forAppId:appid];
    return ret;
}


-(void) showEmailActivation
{
    self.mainWindow = [UIApplication sharedApplication].keyWindow;
    APFRegisterDoneViewController *viewController = (APFRegisterDoneViewController*)[[[[UIApplication sharedApplication] keyWindow] rootViewController].storyboard instantiateViewControllerWithIdentifier:@"EmailActivation"];
    
    self.emailWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.emailWindow.rootViewController = viewController;
    self.emailWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.emailWindow.opaque = NO;
    self.emailWindow.windowLevel = UIWindowLevelAlert;
    self.emailWindow.backgroundColor = [UIColor clearColor];
    
    [self.emailWindow makeKeyAndVisible];
    return;
}

-(void) hideEmailActivation
{
    self.emailWindow.hidden = true;
    [self.mainWindow makeKeyAndVisible];
    self.emailWindow.windowLevel = UIWindowLevelNormal-1;
    self.emailWindow = nil;
}


/*-(APFUserInfo *) fetchUserStatus {

    NSString *fetchUserStatusPath = [NSString stringWithFormat:GET_USER_STATUS, self.dID];

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:fetchUserStatusPath withLifeTime:GET_USER_STATUS_LISTLIFETIME];
    NSData *data = [dl downloadImmediate];

    if (data) {
        NSNumber *userStatus  = nil;
        NSError *error = nil;
        NSDictionary *results;

        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        if(error) {
            self.apfUserInfo.userStatus = UserStatusUnknown;
            return self.apfUserInfo;
        }

        if([object isKindOfClass:[NSDictionary class]]){
            results = object;
        }

        if (results) {
            NSString *resultStatus = [object objectForKey:@"status"];
            if ([resultStatus isEqualToString:@"error"]) {
                self.apfUserInfo.userStatus = UserStatusUnknown;
                return self.apfUserInfo;
            }

            userStatus = [object objectForKey:@"user_status"];
            if (self.apfUserInfo != nil) {
                self.apfUserInfo.userStatus = userStatus.integerValue;

                if (userStatus.integerValue == UserStatusLimited) {
                    self.apfUserInfo.billPaymentUrl = [object objectForKey:@"link"];
                }
            }
        }
    } else {
        self.apfUserInfo.userStatus = UserStatusUnknown;
    }

    return self.apfUserInfo;
}*/

-(void) connectionError{
    [SVProgressHUD showErrorWithStatus:@"خطا در اتصال به سرور ‌اپفورال؛ آیا از اتصال به اینترنت اطمینان دارید؟"];
}

-(void) userBlocked {
    [SVProgressHUD showWithStatus:@"اکانت شما قفل شده. لطفا با پشتیبانی تماس بگیرید!" maskType:SVProgressHUDMaskTypeBlack];
}

-(void) userLimited{
    [SVProgressHUD showErrorWithStatus:@"دسترسی شما محدود شده است!"];
}

-(void) updateAvailable{
    [SVProgressHUD showErrorWithStatus:@"لطفا نسخه‌ی برنامه را به روز رسانی کنید!"];
}

-(void) parseRegisterResponse:(NSData*)data
{
    [SVProgressHUD dismiss];
    NSError *error = nil;
    NSDictionary *results;
    NSLog(@"Parsing register data");
    
    if(!data) {
        //[self connectionError];
        [self registerErrorWithError:nil];
        return;
    }
    
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    if(error) {
        //[self connectionError];
        [self registerErrorWithError:nil];
    }
    
    if([object isKindOfClass:[NSDictionary class]]){
        results = object;
    }
    if(results)
    {
        NSLog(@"Results : %@",results);
        if([results objectForKey:@"error"])
        {
            NSArray * messages = [results objectForKey:@"messages"];
            if(messages && [[messages objectAtIndex:0] objectAtIndex:1])
            {
                NSString * field = [[messages objectAtIndex:0] objectAtIndex:0];
                NSString * str = [[[messages objectAtIndex:0] objectAtIndex:1] objectAtIndex:0];
                [self registerErrorWithError:[NSString stringWithFormat:@"%@ : %@",field,str]];
            }
            else
            {
                [self registerErrorWithError:nil];
            }
        }
        else if([results objectForKey:@"done"])
        {
            NSString* appID = [[NSBundle mainBundle] bundleIdentifier];
            [SSKeychain setPassword:_loginUsername forService:appID account:@"basicUsername"];
            [SSKeychain setPassword:_loginPassword forService:appID account:@"basicPassword"];
            if ([self.PROJECTApiDelegate respondsToSelector:@selector(didRegisterSuccessful)]) {
                [self.PROJECTApiDelegate didRegisterSuccessful];
            }
        }
        else
        {
            [self registerErrorWithError:nil];
        }
    }
}



-(void) parseLoginResponse:(NSData*)data{
//    [NSThread sleepForTimeInterval:1];
//    [SVProgressHUD dismiss];

    NSError *error = nil;
    NSDictionary *results;
    NSLog(@"Parsing login data");

    if(!data) {
        //[self connectionError];
        [self initialConnectionError];
        return;
    }

    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    if(error) {
        //[self connectionError];
        [self initialConnectionError];
    }

    if([object isKindOfClass:[NSDictionary class]]){
        results = object;
    }
    BOOL limited = NO;
    if (results) {
        NSString* status = [object objectForKey:@"status"];

        if(![@"ok" isEqualToString:status]){
            limited = YES;
            if ([@"limited" isEqualToString:status]) {
                NSLog(@"User is limited!");

                if(self.version == APFVersionBasic) {
                    if ([self.PROJECTApiDelegate respondsToSelector:@selector(PROJECTAPILoadingWasCompleted:withState:)]) {
                        [self.PROJECTApiDelegate PROJECTAPILoadingWasCompleted:self withState:APFLoginStateInvalidUsernameOrPassword];
                    }

                    return;
                }

//                [self userLimited];
            }
            else if ([@"blocked" isEqualToString:status]) {
                [self userBlocked];
                return;
            }
        }

        if(!limited){
            NSString* appID = [[NSBundle mainBundle] bundleIdentifier];
            [SSKeychain setPassword:_loginUsername forService:appID account:@"basicUsername"];
            [SSKeychain setPassword:_loginPassword forService:appID account:@"basicPassword"];

            NSString *lastversion = [object objectForKey:@"lastv"];
            if (![VERSION isEqualToString:lastversion]) {
                //                [self updateAvailable];

                dispatch_async(dispatch_get_main_queue(), ^{
                    SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                                      message:@"اپفورال در حال به روز شدن است.\nلطفا در پنجره‌ای که ظاهر خواهد شد دکمه install و سپس Home را بزنید."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"تایید"
                                                            otherButtonTitles:nil, nil];

                    [alert show];
                    //                    [SVProgressHUD showProgress:-1 status:@"برای ادامه لطفا اپفورال خود را به‌روز رسانی نمایید." maskType:SVProgressHUDMaskTypeBlack];
                });
                [self performSelector:@selector(offerUpgrade:) withObject:[object objectForKey:@"path"] afterDelay:8];
            } else {
                [self identifyWith:results];
            }
        } else {
            [self identifyWith:results];
        }

        // ********************************************************************************

        self.working = YES;

        /*APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:GET_WEEKLY_TOP_APP_LIST withLifeTime:GET_WEEKLY_TOP_APP_LIST_LIFETIME];

        dl.didFailDownload = ^(NSError* err){
            [self connectionError];
        };

        [dl start];

        // ********************************************************************************

        dl = [[APFDownloader alloc] initWithDownloadURLString:GET_TOP_APP_LIST withLifeTime:GET_TOP_APP_LIST_LIFETIME];

        dl.didFailDownload = ^(NSError* err){
            [self connectionError];
        };

        [dl start];

        // ********************************************************************************

        dl = [[APFDownloader alloc] initWithDownloadURLString:
              [NSString stringWithFormat:GET_LATEST_APPS, 1]
                                              withLifeTime: GET_LATEST_APPS_LIFETIME];
        dl.didFailDownload = ^(NSError* err){
            [self connectionError];
        };

        [dl start];*/

        //self.enteredTheApp = YES;
    }
}

-(void) offerUpgrade:(NSString*)path{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", path]]];
}

-(void) initialConnectionError {
    SDCAlertView* alert = [[SDCAlertView alloc] initWithTitle:@"خطا در اتصال به اپفورال"
                                                      message:@"از اتصال خود به اینترنت مطمئن شوید و دوباره سعی کنید."
                                                     delegate:nil cancelButtonTitle:@"سعی مجدد" otherButtonTitles:nil];

    [alert showWithDismissHandler:^(NSInteger buttonIndex) {
        [self loginWithUsername:_loginUsername password:_loginPassword];
    }];
}

-(void) registerErrorWithError:(NSString *)errorMessage
{
    [SVProgressHUD dismiss];
    if(errorMessage)
    {
        SDCAlertView* alert = [[SDCAlertView alloc] initWithTitle:@"خطا در ثبت نام"
                                                          message:errorMessage
                                                         delegate:nil cancelButtonTitle:@"تایید" otherButtonTitles:nil];
        
        [alert showWithDismissHandler:nil];
    }
    else
    {
        SDCAlertView* alert = [[SDCAlertView alloc] initWithTitle:@"خطا در ثبت نام"
                                                          message:@"خطا در ثبت اطلاعات"
                                                         delegate:nil cancelButtonTitle:@"تایید" otherButtonTitles:nil];
        
        [alert showWithDismissHandler:nil];
    }
}


-(void) login{
    [self loginWithUsername:nil password:nil];
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password {
    NSLog(@"ID: %@", self.dID);
    NSString* loginPath;

    _loginUsername = username;
    _loginPassword = password;
    
    NSString * aid = self.aid;
    NSString * idfv = self.idfv;
    NSString * uuid = self.uuid;
    NSString * deviceName = self.deviceName;
    NSString * hash = [self hashData:idfv andAid:aid andUuid:uuid andDeviceName:deviceName];
    
    if([username length] > 0 && [password length] > 0) {
        loginPath = [NSString stringWithFormat:LOGIN_WITH_USERNAME_PATH, self.dID, [username urlencode], [password urlencode],[aid urlencode],[idfv urlencode],[uuid urlencode],[deviceName urlencode],[hash urlencode]];
    }
    else {
        loginPath = [NSString stringWithFormat:LOGIN_PATH, self.dID, self.idfv];
    }

    NSLog(@"Login: %@", loginPath);
    APFDownloader *login = [[APFDownloader alloc] initWithDownloadURLString:loginPath withLifeTime:LOGIN_PATH_LIFETIME];

    login.didFailDownload = ^(NSError* err){
        [self initialConnectionError];
    };

    login.didFinishDownload = ^(NSData *data){
        [self parseLoginResponse:data];
    };

    [login start];
}


-(void)registerWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name tel:(NSString*)tel
{
    [SVProgressHUD showProgress:-1];
    //"aid=%@&first_name=%@&idfv=%@&mobile_number=%@&username=%@&password=%@&uuid=%@"
    NSString * aid = self.aid;
    NSString * idfv = self.idfv;
    NSString * uuid = self.uuid;
    NSString * deviceName = self.deviceName;
    NSString * hash = [self hashData:idfv andAid:aid andUuid:uuid andDeviceName:deviceName];
    
    _loginUsername = email;
    _loginPassword = password;
    self.emailToResend = email;
    
    NSString * registerBody = [NSString stringWithFormat:REGISTER_WITH_USERNAME_BODY,[aid urlencode],[name urlencode],[idfv urlencode],[tel urlencode],[email urlencode],[password urlencode],[uuid urlencode],[deviceName urlencode],[hash urlencode]];
    NSString * registerPath = [NSString stringWithFormat:REGISTER_WITH_USERNAME_PATH];
    APFDownloader * reg = [[APFDownloader alloc] initWithDownloadURLString:registerPath withLifeTime:REGISTER_WITH_USERNAME_PATH_LIFETIME withPostBody:registerBody];
    
    reg.didFailDownload = ^(NSError* err){
        [self registerErrorWithError:nil];
    };
    
    reg.didFinishDownload = ^(NSData *data){
        [self parseRegisterResponse:data];
    };
    
    [reg start];

    
}


-(void)resendActivationWithEmail:(NSString*)email
{
    [SVProgressHUD showProgress:-1];
    
    NSString * em = email;
    if (em == nil) em = _loginUsername;
    
    NSString * registerBody = [NSString stringWithFormat:RESEND_ACTIVATION_BODY,[em urlencode]];
    NSString * registerPath = [NSString stringWithFormat:RESEND_ACTIVATION_PATH];
    APFDownloader * reg = [[APFDownloader alloc] initWithDownloadURLString:registerPath withLifeTime:RESEND_ACTIVATION_PATH_LIFETIME withPostBody:registerBody];
    
    reg.didFailDownload = ^(NSError* err){
        [SVProgressHUD dismiss];
        SDCAlertView* alert = [[SDCAlertView alloc] initWithTitle:nil
                                                          message:@"خطا در ارسال مجدد ایمیل فعالسازی"
                                                         delegate:nil cancelButtonTitle:@"تایید" otherButtonTitles:nil];
        
        [alert showWithDismissHandler:nil];
    };
    
    reg.didFinishDownload = ^(NSData *data){
        [SVProgressHUD dismiss];
        SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                          message:[NSString stringWithFormat:@"ایمیل فعالسازی با موفقیت ارسال گردید."]
                                                         delegate:nil
                                                cancelButtonTitle:@"تایید"
                                                otherButtonTitles:nil, nil];
        [alert showWithDismissHandler:^(NSInteger buttonIndex) {
            [[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController] dismissViewControllerAnimated:true completion:nil];
        }];

    };
    
    [reg start];
    
}


-(void)forgotPasswordWithEmail:(NSString*)email
{
    [SVProgressHUD showProgress:-1];
    
    
    NSString * registerBody = [NSString stringWithFormat:RESET_PASSWORD_BODY,[email urlencode]];
    NSString * registerPath = [NSString stringWithFormat:RESET_PASSWORD_PATH];
    APFDownloader * reg = [[APFDownloader alloc] initWithDownloadURLString:registerPath withLifeTime:RESET_PASSWORD_PATH_LIFETIME withPostBody:registerBody];
    
    reg.didFailDownload = ^(NSError* err){
        [SVProgressHUD dismiss];
        SDCAlertView* alert = [[SDCAlertView alloc] initWithTitle:nil
                                                          message:@"خطا در ارسال ایمیل تغییر رمز عبور"
                                                         delegate:nil cancelButtonTitle:@"تایید" otherButtonTitles:nil];
        
        [alert showWithDismissHandler:nil];
    };
    
    reg.didFinishDownload = ^(NSData *data){
        [SVProgressHUD dismiss];
        SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                          message:[NSString stringWithFormat:@"ایمیل تغییر رمز عبور با موفقیت ارسال گردید."]
                                                         delegate:nil
                                                cancelButtonTitle:@"تایید"
                                                otherButtonTitles:nil, nil];
        [alert showWithDismissHandler:^(NSInteger buttonIndex) {
            [[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController] dismissViewControllerAnimated:true completion:nil];
        }];
        
    };
    
    [reg start];
    
}




-(NSString*) getURLForAppDescriptionWithiTunesID:(NSString*)iTunesID forAppBuy:(BOOL)isAppBuy {
    if(!isAppBuy) {
        NSLog(@"%@",[NSString stringWithFormat:GET_APP_INFO, iTunesID]);
        return [NSString stringWithFormat:GET_APP_INFO, iTunesID];
    }
    else {
        NSLog(@"%@",[NSString stringWithFormat:GET_APPBUY_APP_INFO, iTunesID]);
        return [NSString stringWithFormat:GET_APPBUY_APP_INFO, iTunesID];
    }

}

-(NSString*) getURLForAppListWithPage:(int)page{
    return [NSString stringWithFormat:GET_LATEST_APPS, page];
}

-(NSString*) getURLForTopList:(NSString*)category withPage:(int)page forType:(NSString*)t {
    NSString* ret;

    NSString* device = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"iphone" : @"ipad";
    ret = [NSString stringWithFormat:GET_TOP_APPS, [category urlencode], device, [t urlencode], page];

    return ret;
}

-(NSString*) getURLForTagList:(NSArray*)tags withPage:(int)page forAppBuy:(BOOL)isAppBuy {
    NSString* ret;

    NSArray * url_tags = [NSArray array];
    for(NSString * tag in tags){
        url_tags = [url_tags arrayByAddingObject:[[NSString stringWithFormat:GET_TAG_PARAM, [tag urlencode]] lowercaseString]];
    }

    if(!isAppBuy) {
        ret = [NSString stringWithFormat:GET_TAG_APPS, [url_tags componentsJoinedByString:@"&"], page];
    }
    else {
        NSString* device = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"iphone" : @"ipad";
        ret = [NSString stringWithFormat:GET_APPBUY_TAG_APPS, [url_tags componentsJoinedByString:@"&"], page, device];
    }
    NSLog(@"Ret : %@",ret);
    return ret;
}



-(NSArray*) parseDataList:(NSData*)data{
    NSArray * ret  = nil;
    NSError *error = nil;
    NSDictionary *results;

    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    if(error) {
        return ret;
    }

    if([object isKindOfClass:[NSDictionary class]]){
        results = object;
    }

    if (results) {
        NSArray *list = [object objectForKey:@"list"];
        NSMutableArray *appList = [[NSMutableArray alloc] initWithCapacity:40];
        for (NSDictionary *entry in list) {
            [appList addObject:[APFAppEntry AppEntryFromDictionary:entry]];
        }
        ret = appList;
    }
    return ret;
}

-(NSArray*) processAppsArray:(NSArray*)list {
    NSMutableArray *appList = [[NSMutableArray alloc] initWithCapacity:40];

    for(NSDictionary *entry in list) {
        [appList addObject:[APFAppEntry AppEntryFromDictionary:entry]];
    }

    return appList;
}



-(void) proposeAppWithId:(NSString*)appid {
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:
                         [NSString stringWithFormat:PROPOSE_APP, self.apfUserInfo.userId, appid]
                                                            withLifeTime: PROPOSE_APP_LIFETIME];
    NSData * ret = [dl downloadImmediate];
    if (ret)
    {
        NSError *error = nil;
        NSDictionary *results;
        
        id object = [NSJSONSerialization
                     JSONObjectWithData:ret
                     options:0
                     error:&error];
        if(error) {
            return;
        }
        
        if([object isKindOfClass:[NSDictionary class]]){
            results = object;
        }
        if ([results objectForKey:@"done"])
        {
            SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                              message:@"درخواست شما ثبت گردید."
                                                             delegate:nil
                                                    cancelButtonTitle:@"تایید"
                                                    otherButtonTitles:nil, nil];
            
            [alert show];
        }
    }
}

-(void) hideAppUpdate:(NSString*)appid andComplete:(void(^)())completionHandler {
    [SVProgressHUD showProgress:-1];
    NSLog(@"%@",[NSString stringWithFormat:HIDE_UPDATE, self.dID, self.authToken, appid]);
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:
                         [NSString stringWithFormat:HIDE_UPDATE, self.dID, self.authToken, appid]
                                                            withLifeTime: HIDE_UPDATE_LIFETIME];
    NSData * ret = [dl downloadImmediate];
    [SVProgressHUD dismiss];
    if (ret)
    {
        NSError *error = nil;
        NSDictionary *results;
        
        id object = [NSJSONSerialization
                     JSONObjectWithData:ret
                     options:0
                     error:&error];
        if(error) {
            return;
        }
        
        if([object isKindOfClass:[NSDictionary class]]){
            results = object;
        }
        NSLog(@"results : %@",results);
        if ([results objectForKey:@"done"])
        {
            if([[results objectForKey:@"done"] boolValue])
            {
                completionHandler();
            }
        }
    }
}


-(NSArray*) getSimilarApps:(NSString*)appid category:(NSString*)category {
    NSArray * ret;
    
    NSLog(@"%@",[NSString stringWithFormat:GET_SIMILAR_APPS, appid, category]);
    
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:
                         [NSString stringWithFormat:GET_SIMILAR_APPS, appid, [category urlencode]]
                                                            withLifeTime: GET_SIMILAR_APPS_LIFETIME];
    NSData *retData = [dl downloadImmediate];
    
    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}


-(NSArray*) getTopApps:(NSString*)category listPage:(int) page forType:(NSString*)type {
    NSArray * ret;

    NSLog(@"%@",[self getURLForTopList:category withPage:page forType:type]);
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:
                         [self getURLForTopList:category withPage:page forType:type]
                                                      withLifeTime: GET_CAT_APPS_LIFETIME];
    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}

-(NSArray*) getTagCategory:(NSArray*)tags listPage:(int) page forAppBuy:(BOOL)isAppBuy {
    NSArray * ret;
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:
                         [self getURLForTagList:tags withPage:page forAppBuy:isAppBuy]
                                                            withLifeTime: GET_TAG_APPS_LIFETIME];
    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}


-(NSArray*) getAppListByURL:(NSString *)url page:(NSInteger)page {
    NSArray* ret;

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:[NSString stringWithFormat:url, page] withLifeTime:GET_APP_LIST_LIFETIME];

    NSData* retData = [dl downloadImmediate];

    if(retData) {
        ret = [self parseDataList:retData];
    }
    else {
        return [NSArray array];
    }

    return ret;
}

-(NSArray*) getRecommendedApps:(NSArray*)ids
{
    NSArray* ret;

    if( ids == nil || [ids count] == 0)
        return [NSArray array];
    NSString * urldata = [ids componentsJoinedByString:@","];

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:[NSString stringWithFormat:LOOKUP_RECOMMEND    , [urldata urlencode]] withLifeTime:LOOKUP_RECOMMEND_LIFETIME];
    
    NSData* retData = [dl downloadImmediate];
    
    if(retData) {
        ret = [self parseDataList:retData];
    }
    else {
        return [NSArray array];
    }
    
    return ret;

}

-(NSDictionary*) lidLookup:(NSArray *)lids
{
    
    NSString * urldata = [lids componentsJoinedByString:@","];
    
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:[NSString stringWithFormat:LID_LOOKUP    , [urldata urlencode]] withLifeTime:LID_LOOKUP_LIFETIME];
    
    NSData* retData = [dl downloadImmediate];
    
    if(retData) {
        NSError *error = nil;
        NSDictionary *results;
        
        id object = [NSJSONSerialization
                     JSONObjectWithData:retData
                     options:0
                     error:&error];
        if(error) {
            return nil;
        }
        
        if([object isKindOfClass:[NSDictionary class]]){
            results = object;
        }
        
        if (results) {
            return results;
        }
        return nil;
    }
    else {
        return nil;
    }
}



-(NSArray*)getCollectionApps:(NSString*)collectionName page:(NSInteger)page {
    NSArray * ret;

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:[NSString stringWithFormat:GET_COLLECTION_APPS, collectionName, page]
                                                            withLifeTime: GET_COLLECTION_APPS_LIFETIME];
    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}

-(NSArray*) getLatestListPage:(int) page{
    NSArray * ret;

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:
                      [NSString stringWithFormat:GET_LATEST_APPS, page]
                                                      withLifeTime: GET_LATEST_APPS_LIFETIME];
    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}

-(NSData*) getFeaturedPageData {
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:FEATURED_PATH withLifeTime:FEATURED_PATH_LIFETIME];
    NSData* retData = [dl downloadImmediate];
    
    return retData;
}

-(NSArray *)getDownloadHistory:(int)page {
    NSArray* ret;

    NSLog(@"%@",[NSString stringWithFormat:DOWNLOAD_HISTORY, self.dID, self.idfv, self.authToken, page]);
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:[NSString stringWithFormat:DOWNLOAD_HISTORY, self.dID, self.idfv, self.authToken, page] withLifeTime:DOWNLOAD_HISTORY_LIFETIME];

    NSData* retData = [dl downloadImmediate];

    if(retData) {
        ret = [self parseDataList:retData];
    }
    else {
        return [NSArray array];
    }

    return ret;
}

-(NSArray*) getWeeklyTopList{
    NSArray * ret;

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:GET_WEEKLY_TOP_APP_LIST withLifeTime:GET_WEEKLY_TOP_APP_LIST_LIFETIME];

    //    NSData *retData = [NSData dataWithContentsOfURL:[NSURL URLWithString:GET_WEEKLY_TOP_APP_LIST]];
    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}

-(NSArray*) getRelatedAppList:(NSString*)category {
    NSArray * ret;

    NSString *relatedAppPath = [NSString stringWithFormat:GET_RELATED_APP_LIST, category];
    relatedAppPath = [relatedAppPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    relatedAppPath = [relatedAppPath stringByReplacingOccurrencesOfString: @"&" withString: @"%26"];
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:relatedAppPath withLifeTime:GET_RELATED_APP_LISTLIFETIME];

    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}

-(NSMutableArray*) getUpdateAppList{
    NSArray * ret;

    NSString *request = [NSString stringWithFormat:UPDATES_PATH, self.dID, self.idfv, self.authToken];
    NSLog(@"Making request to %@", request);
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:request withLifeTime:UPDATES_PATH_LIFETIME];

    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }

    self.updatesList = [[NSMutableArray alloc] initWithArray:ret];
    NSArray * tmp = [self.updatesList copy];
    for (APFAppEntry *app in tmp) {
        if (![[APFPROJECTAPI currentInstance] isApplicationInstalled:app.applicationiTunesIdentification]) {
            [self.updatesList removeObject:app];
        }
    }
    return self.updatesList;
}

-(NSArray*) getTopAppList{
    NSArray * ret;

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:GET_TOP_APP_LIST withLifeTime:GET_TOP_APP_LIST_LIFETIME];

//        NSData *retData = [NSData dataWithContentsOfURL:[NSURL URLWithString:GET_TOP_APP_LIST]];
    NSData *retData = [dl downloadImmediate];

    if (retData) {
        ret = [self parseDataList:retData];
    }
    return ret;
}

-(APFAppDescription*) parseDescriptionFromData:(NSData*)data{
    APFAppDescription* ret = nil;
    NSError *error = nil;
    NSDictionary *results;

    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    if(error) {
        return ret;
    }

    if([object isKindOfClass:[NSDictionary class]]){
        results = object;
    }

    if (results) {
        ret = [APFAppDescription appDescriptionFromDictionary:results];
    }
    return ret;
}

-(APFAppDescription*) getAppDescriptionWithID:(NSString*)iTunesID forAppBuy:(BOOL)isAppBuy {
    APFAppDescription* ret = nil;

    //    NSData *retData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self getURLForAppDescriptionWithiTunesID:iTunesID]]];

    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:[self getURLForAppDescriptionWithiTunesID:iTunesID forAppBuy:isAppBuy] withLifeTime:GET_APP_INFO_LIFETIME];

    NSData *retData = [dl downloadImmediate];


    if (retData) {
        ret = [self parseDescriptionFromData:retData];
    }

    return ret;
}

#pragma mark -
#pragma mark Download delegate methods

-(int)getFileDownloadInfoIndexWithTCBlobDownloader:(unsigned long)taskIdentifier{
    int index = -1;
    for (int i=0; i<[self.fileDownloadDataArray count]; i++) {
        APFFileDownloadInfo *fdi = [self.fileDownloadDataArray objectAtIndex:i];
        if (fdi.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }

    return index;
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    NSUInteger index = [self getFileDownloadInfoIndexWithTCBlobDownloader:downloadTask.taskIdentifier];
    if (index != -1) {
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];

        //NSLog(@"R: %llu - D: %llu - T: %llu", totalBytesWritten, fileDownloadInfo.downloadedBytes, fileDownloadInfo.totalFileLength);
        //NSLog(@"State: %lu", (unsigned long)fileDownloadInfo.state);
         //if (blobDownload.state != TCBlobDownloadStateCancelled) {
        uint64_t downloadedBytes = 0;

        if(fileDownloadInfo.twoStage) {
            if(fileDownloadInfo.currentStage == 1) {
                fileDownloadInfo.downloadedBytes = totalBytesWritten;
            }
            else {
                downloadedBytes = fileDownloadInfo.downloadedBytes;
            }
        }
        fileDownloadInfo.downloadProgress = ((float) (totalBytesWritten + downloadedBytes) / (float)fileDownloadInfo.totalFileLength);
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            if ([self.PROJECTApiDelegate isKindOfClass:(APFAppDescriptionViewController.class)] &&
                [[[((APFAppDescriptionViewController *)self.PROJECTApiDelegate).appDescription.applicationCopies lastObject] objectForKey:@"lid"] isEqualToString:fileDownloadInfo.appId]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.PROJECTApiDelegate didDownloadProgressForAppId:fileDownloadInfo.appId withProgress:fileDownloadInfo.downloadProgress];
                });
            } else if ([self.PROJECTApiDelegate isKindOfClass:(APFUpdateAppsViewController.class)]) {
                NSArray *visibleCells = [((APFUpdateAppsViewController *) self.PROJECTApiDelegate).tableView visibleCells];
                for (UITableViewCell *cell in visibleCells) {
                    if([cell isKindOfClass:APFUpdateAppTableViewCell.class])
                    {
                        if ([((APFUpdateAppTableViewCell*)cell).appId isEqualToString:fileDownloadInfo.appId]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [(APFUpdateAppTableViewCell*)cell didDownloadProgressForAppId:fileDownloadInfo.appId withProgress:fileDownloadInfo.downloadProgress];
                            });
                        }
                    }
                }
            }
        }
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"Stop With Error %@", task);
    NSLog(@"Error: %@", [error localizedDescription]);
    if(!error) return;
    if(error.code == NSURLErrorCancelled)
    {
        NSLog(@"CANCELED BY USER");
        return;
    }
    NSUInteger index = [self getFileDownloadInfoIndexWithTCBlobDownloader:task.taskIdentifier];
    if (index != -1) {
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
        fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;

        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateActive) {
            SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                              message:[NSString stringWithFormat:@"خطا در دانلود برنامه %@ برای ادامه دانلود پس از بررسی اینترنت دوباره اقدام نمایید.", fileDownloadInfo.appName]
                                                             delegate:nil
                                                    cancelButtonTitle:@"تایید"
                                                    otherButtonTitles:nil, nil];
            [alert showWithDismissHandler:^(NSInteger buttonIndex) {
                if ([self.PROJECTApiDelegate isKindOfClass:(APFAppDescriptionViewController.class)] &&
                    [[[((APFAppDescriptionViewController *)self.PROJECTApiDelegate).appDescription.applicationCopies lastObject] objectForKey:@"lid"] isEqualToString:fileDownloadInfo.appId]) {
                    [self.PROJECTApiDelegate didDownloadFail];
                } else if ([self.PROJECTApiDelegate isKindOfClass:(APFUpdateAppsViewController.class)]) {
                    NSArray *visibleCells = [((APFUpdateAppsViewController *) self.PROJECTApiDelegate).tableView visibleCells];
                    for (UITableViewCell *cell in visibleCells) {
                        if([cell isKindOfClass:APFUpdateAppTableViewCell.class]){
                            if ([((APFUpdateAppTableViewCell*)cell).appId isEqualToString:fileDownloadInfo.appId]) {
                                [(APFUpdateAppTableViewCell*)cell didDownloadFail];
                            }
                        }
                    }
                }
            }];
        } else {
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = [NSString stringWithFormat:@"خطا در دانلود برنامه %@ برای ادامه دانلود پس از بررسی اینترنت دوباره اقدام نمایید.", fileDownloadInfo.appName];
            localNotification.alertAction = @"Try Again!";

            //On sound
            localNotification.soundName = UILocalNotificationDefaultSoundName;

            NSDictionary *userDict = @{@"AppName": fileDownloadInfo.appName};

            localNotification.userInfo = userDict;

            //increase the badge number of application plus 1
            if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == -1) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }

            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;

            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}

-(void) backgroundCallback:(id)info
{
    NSLog(@"ON BACKGROUND API");
}


-(BOOL) isNotMerged:(NSString*)appId
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *destinationPathDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/%@/", appId]];
    NSString* firstStageFinalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.raw"];
    NSString* secondStageFinalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.patch"];
    return [fileManager fileExistsAtPath:firstStageFinalPath] && [fileManager fileExistsAtPath:secondStageFinalPath];
}

-(BOOL) mergeZipFilesWithAppId:(NSString*)appId
{
    //NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *destinationPathDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/%@/", appId]];
    NSString* firstStageFinalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.raw"];
    NSString* secondStageFinalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.patch"];
    NSString* finalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];
    return [self mergeZipFilesWithFirstPath:firstStageFinalPath andSecond:secondStageFinalPath andFinal:finalPath];
    
}


-(BOOL) mergeZipFilesWithFirstPath:(NSString*)firstStageFinalPath andSecond:(NSString*) secondStageFinalPath andFinal:(NSString*) finalPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    OZZipFile * secondFile = [[OZZipFile alloc] initWithFileName:secondStageFinalPath mode:OZZipFileModeUnzip];
    OZZipFile * firstFile = [[OZZipFile alloc] initWithFileName:firstStageFinalPath mode:OZZipFileModeAppend];
    
    do
    {
        OZFileInZipInfo * info = [secondFile getCurrentFileInZipInfoWithError:nil];
        NSLog(@"ZIP Writing %@",info.name);
        NSMutableData *buffer= [[NSMutableData alloc]
                                initWithLength:4096];
        
        OZZipReadStream *readStream = [secondFile readCurrentFileInZip];
        OZZipWriteStream *writeStream = [firstFile writeFileInZipWithName:info.name compressionLevel:OZZipCompressionLevelNone];
        
        // Read-then-write buffered loop
        NSLog(@"READ WRITE STARTED");
        NSLog(@"LEVEL : %d",info.level);
        do {
            
            // Reset buffer length
            [buffer setLength:4096];
            
            // Expand next chunk of bytes
            unsigned long bytesRead= [readStream readDataWithBuffer:buffer];
            if (bytesRead > 0) {
                
                // Write what we have read
                [buffer setLength:bytesRead];
                [writeStream writeData:buffer];
                
            } else
                break;
            
        } while (YES);
        
        NSLog(@"FINISHED WRITING");
        [writeStream finishedWriting];
        [readStream finishedReading];
    } while([secondFile goToNextFileInZip]);
    NSLog(@"FINILIZING");
    [firstFile close];
    [secondFile close];
    
    [fileManager removeItemAtPath:secondStageFinalPath error:nil];
    [fileManager removeItemAtPath:finalPath error:nil];
    NSError * error;
   return [fileManager moveItemAtPath:firstStageFinalPath toPath:finalPath error:&error];
}



-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"FINISHED %@", downloadTask);
    NSLog(@"FILE URL : %@",location);
    if (true) { //Download Will Always be successfull on this delegate method
        NSUInteger index = [self getFileDownloadInfoIndexWithTCBlobDownloader:downloadTask.taskIdentifier];
        if (index != -1) {
            APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];

            NSString *appId = fileDownloadInfo.appId;
            NSString *appName = fileDownloadInfo.appName;

            NSError *error;
            NSFileManager *fileManager = [NSFileManager defaultManager];

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *destinationPathDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/%@/", appId]];
            /*if (![fileManager fileExistsAtPath:destinationPathDirectory]) {
                //Create Directory!
                [fileManager createDirectoryAtPath:destinationPathDirectory withIntermediateDirectories:NO attributes:nil error:&error];
            }

            NSString *destinationPathFile = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];
            NSURL *destinationURL = [NSURL fileURLWithPath:destinationPathFile];

            if ([fileManager fileExistsAtPath:[destinationURL path]]) {
                [fileManager removeItemAtURL:destinationURL error:nil];
            }

            NSURL *sourceURL = [NSURL fileURLWithPath:blobDownload.pathToFile];
            BOOL success = [fileManager copyItemAtURL:sourceURL
                                                toURL:destinationURL
                                                error:&error];*/

            NSString* finalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];

            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            {
                __block BOOL success = false;

                if(fileDownloadInfo.twoStage) {
                    //APFBackgroundTask * bgTask = [[APFBackgroundTask alloc] init];
                    //[bgTask startBackgroundTasks:5 target:self selector:@selector(backgroundCallback:) Continue:false];
                    NSString* firstStageFinalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.raw"];
                    NSString* secondStageFinalPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.patch"];
                    NSLog(@"Amir On Stage:%d",fileDownloadInfo.currentStage);
                    if(fileDownloadInfo.currentStage == 1) {
                        [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:firstStageFinalPath] error:nil];
                        [fileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:firstStageFinalPath]];
                        
                        fileDownloadInfo.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fileDownloadInfo.downloadExtraSource]];
                        fileDownloadInfo.taskIdentifier = fileDownloadInfo.downloadTask.taskIdentifier;
                        fileDownloadInfo.downloadTask.priority = NSURLSessionTaskPriorityHigh;
                        [fileDownloadInfo.downloadTask resume];
                        fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                        fileDownloadInfo.taskResumeData = nil;
                        fileDownloadInfo.currentStage = 2;
                        return;
                    }
                    else if(fileDownloadInfo.currentStage == 2) {
                        NSError * Zerror;
                        [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:secondStageFinalPath] error:&Zerror];
                        NSLog(@"MOVE AT PATH ERROR %@",Zerror);
                        [fileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:secondStageFinalPath]];

                        /*ZZArchive* rawArchive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:firstStageFinalPath] error:nil];
                        if(rawArchive == nil) {
                            // TODO Error handling
                            return;
                        }

                        ZZArchive* patchArchive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:secondStageFinalPath] error:nil];
                        if(patchArchive == nil) {
                            // TODO Error handling
                            return;
                        }

                        NSMutableArray* rawEntries = [rawArchive.entries mutableCopy];
                        for(ZZArchiveEntry* entry in rawEntries)
                        {
                            NSLog(@"Amir Old: %@",entry.fileName);
                        }
                        for(ZZArchiveEntry* entry in patchArchive.entries) {
                            //NSInputStream *entryStream = [entry newStreamWithError:nil];;
                            //int chunkSize = 1024 * 1024; // 1 MB
                            // TODO Switch to stream model
                            ZZArchiveEntry* newEntry = [ZZArchiveEntry archiveEntryWithFileName:entry.fileName compress:false dataBlock:^NSData *(NSError *__autoreleasing *error) {
                                return [entry newDataWithError:nil];
                            }];
                            NSLog(@"FILE TO ADD: %@",newEntry.fileName);
                            [rawEntries addObject:newEntry];
                        }

                        BOOL suc = [rawArchive updateEntries:rawEntries error:nil];
                        NSLog(@"SUCCESS : %d",suc);*/

                        // CHILKAT code

                        /*CkoZip* patchArchive = [[CkoZip alloc] init];
                        //[patchArchive setVerboseLogging:true];
                        NSLog(@"Unlock: %d",[patchArchive UnlockComponent:@"JAMESVZIP_LAMovQKvkEwk"]);
                        
                        
                        
                        BOOL status = [patchArchive OpenZip:secondStageFinalPath];

                        if(status != YES) {
                            NSLog(@"FIRST APPEND FAILED");
                            return;
                        }

                        status = [patchArchive QuickAppend:firstStageFinalPath];
                        
                        NSLog(@"YEEES : %d",status);
                        NSLog(@"%@",patchArchive.LastErrorText);*/
                        

                        
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                            [[SEGAnalytics sharedAnalytics] track:@"finish_down_an_app" properties:
                             @{ @"Application Name": appName,
                                @"Category" : fileDownloadInfo.appCategory,
                                @"Version" : fileDownloadInfo.appVersion}];
                            [self notifyFinishDownloadToServerWithAppId:appId];
                            
                            [self.successfulDownloadDataArray addObject:[self.fileDownloadDataArray objectAtIndex:index]];
                            [self.fileDownloadDataArray removeObjectAtIndex:index];
                            [[SEGAnalytics sharedAnalytics] flush];
                            dispatch_semaphore_signal(sema);
                        });
                        
                        success = [self mergeZipFilesWithFirstPath:firstStageFinalPath andSecond:secondStageFinalPath andFinal:finalPath];
                    }
                    else {
                        // What the hell is going on!
                    }
                }
                else {
                    success = [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:finalPath] error:nil];
                    [fileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:finalPath]];
                }
                
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                {

                    if (success) {

                        //[[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:destinationURL];

                        /*if ([[NSFileManager defaultManager] fileExistsAtPath:blobDownload.pathToDownloadDirectory]) {
                            if (![[NSFileManager defaultManager] removeItemAtPath:blobDownload.pathToDownloadDirectory error:&error]) {
                                NSLog(@"Delete directory error: %@", error);
                            }
                        }*/

                        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                        {
                            if ([self.PROJECTApiDelegate isKindOfClass:(APFAppDescriptionViewController.class)] &&
                                [[[((APFAppDescriptionViewController *)self.PROJECTApiDelegate).appDescription.applicationCopies lastObject] objectForKey:@"lid"] isEqualToString:appId]) {
                                [self.PROJECTApiDelegate didDownloadFinish];
                            } else if ([self.PROJECTApiDelegate isKindOfClass:(APFUpdateAppsViewController.class)]) {
                                APFUpdateAppsViewController *updateAppsViewController = (APFUpdateAppsViewController *) self.PROJECTApiDelegate;
                                NSArray *visibleCells = [updateAppsViewController.tableView visibleCells];
                                for (UITableViewCell *cell in visibleCells) {
                                    if([cell isKindOfClass:APFUpdateAppTableViewCell.class]){
                                        if ([((APFUpdateAppTableViewCell*)cell).appId isEqualToString:appId]) {
                                            [(APFUpdateAppTableViewCell*)cell didDownloadFinish];
                                        }
                                    }
                                }
                            }
                        }

                        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                        if (state == UIApplicationStateActive) {
                            SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                                              message:[NSString stringWithFormat:@"دانلود %@ با موفقیت انجام شد.\nبا انتخاب دکمه install نصب شروع می‌شود. برای مشاهده برنامه نصب شده دکمه Home را بزنید.", appName]
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"تایید"
                                                                    otherButtonTitles:nil, nil];
                            [alert show];

                            
                            APFAppDelegate * delegate = [UIApplication sharedApplication].delegate;
                            [delegate retainBackground];
                            NSString *manifestPath = [NSString stringWithFormat:MANIFEST_DOWNLOAD_PATH, appId];

                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", manifestPath]]];

                            /*NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:manifestPath]
                                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                 timeoutInterval:60.0];

                            [NSURLConnection sendAsynchronousRequest:request
                                                               queue:[NSOperationQueue mainQueue]
                                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                                                       NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                                                       NSLog(@"Response: %@", newStr);


                                                   }
                             ];*/
                        } else {
                            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                            localNotification.alertBody = [NSString stringWithFormat:@"دانلود %@ با موفقیت انجام شد.", appName];
                            localNotification.alertAction = @"Install app!";

                            //On sound
                            localNotification.soundName = UILocalNotificationDefaultSoundName;

                            NSDictionary *userDict = @{@"AppId": appId, @"AppName": appName};

                            localNotification.userInfo = userDict;

                            //increase the badge number of application plus 1

                            if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == -1) {
                                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                            }

                            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;

                            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                        }
                    }
                    else { // if(success)
                        //TOOD error handling
                    }
               }
            }
        } else {
            //TOOD error handling
        }
    }
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    APFAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    
    if (appDelegate.backgroundTransferCompletionHandler != nil) {
        // Copy locally the completion handler.
        void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
        
        // Make nil the backgroundTransferCompletionHandler.
        appDelegate.backgroundTransferCompletionHandler = nil;
        
        //[[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Call the completion handler to tell the system that there are no other background transfers.
        completionHandler();
    }
    
}


- (void) notifyFinishDownloadToServerWithAppId:(NSString *)appId {
    NSString *request = [NSString stringWithFormat:FINISH_DOWNLOAD, self.dID, self.idfv, self.authToken, appId];

    NSLog(@"FINISH REQUEST : %@",request);
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:request withLifeTime:FINISH_DOWNLOAD_LIFETIME];

    dl.timeoutInterval = 10;
    [dl downloadImmediate];
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        if ([self.PROJECTApiDelegate isKindOfClass:(APFUpdateAppsViewController.class)]) {
            [(APFUpdateAppsViewController *) self.PROJECTApiDelegate fetchDataAndReloadTable];
        }
    }
}

-(NSArray*)getAppBuyHistory:(int)page {
    NSString* appbuyHistoryURL = [NSString stringWithFormat:APPBUY_HISTORY, self.dID, self.idfv, self.apfUserInfo.userId, page];
    APFDownloader* dl = [[APFDownloader alloc] initWithDownloadURLString:appbuyHistoryURL withLifeTime:0];

    NSData* appbuyData = [dl downloadImmediate];
    NSDictionary* appsDict;

    if(!appbuyData) {
        return [NSArray array];
    }

    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:appbuyData options:0 error:&error];

    if(error || ![object isKindOfClass:[NSDictionary class]]) {
        return [NSArray array];
    }

    appsDict = object;

    NSArray *results = [appsDict objectForKey:@"list"];
    NSUInteger resultCount = results.count;

    NSMutableArray* finalResults = [[NSMutableArray alloc] initWithCapacity:resultCount];

    for(NSDictionary* entry in results) {
        NSMutableDictionary* normalizedEntry = [@{
                                                  @"id": [NSString stringWithFormat:@"%@", [entry objectForKey:@"itunes_id"]],
                                                  @"siz": @"Unknown",
                                                  @"nam": [entry objectForKey:@"appname"],
                                                  @"cat": @"Unknown",
                                                  @"a120": [entry objectForKey:@"icon"],
                                                  @"a160": [entry objectForKey:@"icon"],
                                                  @"abstatus": [entry objectForKey:@"status"],
                                                  @"PROJECT2": [entry objectForKey:@"apple_id"]
                                                  } mutableCopy];

        APFAppEntry* appEntry = [APFAppEntry AppEntryFromDictionary:normalizedEntry];
        appEntry.exists = nil;
        [finalResults addObject:appEntry];
    }

    return finalResults;
}


#pragma mark - chat

- (void)requestChatUrlWithEmail:(NSString *)email {
    self.chatURL = [NSString stringWithFormat:CHAT_URL_BASE, self.apfUserInfo.userId, self.dID];
}

@end
