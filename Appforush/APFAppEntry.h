//
//  APFAppEntry.h
//  PROJECT
//
//  Created by PROJECT on 29/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APFDownloader.h"
#import "APFAppDescription.h"

typedef NS_ENUM(NSInteger, IconSize) {
    NormalIcon = 120,
    LargeIcon = 160,
    HugeIcon = 512
};

@interface APFAppEntry : NSObject {
    int tries;
    BOOL isDownloadingIcon;
}

@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) NSString *applicationVersion;
@property (nonatomic, strong) NSNumber *applicationDownloads;
@property (nonatomic, strong) NSString *applicationCategory;
@property (nonatomic, strong) NSNumber *applicationAFDownloads;
@property (nonatomic, strong) NSString *applicationiTunesIdentification;
@property (nonatomic, strong) NSString *applicationIconURL;
@property (nonatomic, strong) NSString *applicationLargeIconURL;
@property (nonatomic, strong) NSString *applicationHugeIconURL;
@property (nonatomic, strong) NSString *applicationCompatibility;
@property (nonatomic, strong) NSString *applicationSize;
@property (nonatomic, strong) NSString *applicationOriginalPrice;
@property (nonatomic, strong) NSArray *applicationCopies;
@property (nonatomic, strong) NSString *applicationReleaseNote;
@property (nonatomic, strong) NSNumber *applicationAppBuyStatus;
@property (nonatomic, strong) NSString *userAppleID;

@property (nonatomic, strong) UIImage *applicationIcon;
@property (nonatomic, strong) UIImage *applicationLargeIcon;
@property (nonatomic, strong) UIImage *applicationHugeIcon;
@property (nonatomic, strong) UIImage *applicationPrimaryScreenshot;
@property (nonatomic, strong) APFAppDescription *applicationDescription;
@property (nonatomic, strong) APFDownloader *activeDescDL, *activeIconDL;

@property (nonatomic, assign) BOOL availableInBasic;
@property (nonatomic, assign) BOOL availableInPROJECT;

@property (nonatomic, assign) NSInteger iranPrice;

@property (nonatomic, assign) float averageUserRating;
@property (nonatomic, assign) NSInteger userRatingCount;

@property (nonatomic, strong) NSNumber* exists;

@property (nonatomic, copy) void (^iconDownloadedHandler)(void);
@property (nonatomic, copy) void (^descriptionDownloadedHandler)(void);
@property (nonatomic, copy) void (^descriptionDownloadFailedHandler)(void);


+(APFAppEntry*) AppEntryFromDictionary:(NSDictionary*) appEntryDic;

- (void)startDownloadIcon;
- (void)startDownloadIconWithSize:(IconSize)size;
- (void)startDownloadDescriptionForAppBuy:(BOOL)isAppBuy;

@end
