//
//  APFAppDescription.h
//  PROJECT
//
//  Created by PROJECT on 30/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APFAppDescription : NSObject

@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) NSString *applicationVersion;
@property (nonatomic, strong) NSString *applicationReleaseDateString;
@property (nonatomic, strong) NSNumber *applicationReleaseDate;
@property (nonatomic, strong) NSString *applicationCategory;
@property (nonatomic, strong) NSString *applicationDeveloper;
@property (nonatomic, strong) NSString *applicationSize;
@property (nonatomic, strong) NSString *applicationiTunesIdentification;

@property (nonatomic, strong) NSString *applicationIconURL;
@property (nonatomic, strong) NSString *applicationLargeIconURL;
@property (nonatomic, strong) NSString *applicationHugeIconURL;

@property (nonatomic, strong) UIImage *applicationIcon;
@property (nonatomic, strong) UIImage *applicationLargeIcon;
@property (nonatomic, strong) UIImage *applicationHugeIcon;

@property (nonatomic, strong) NSNumber *applicationDownloads;
@property (nonatomic, strong) NSNumber *applicationAFDownloads;
@property (nonatomic, strong) NSString *applicationPrice;

@property (nonatomic, strong) NSString *applicationAddedDateString;
@property (nonatomic, strong) NSNumber *applicationAddedDate;
@property (nonatomic, strong) NSArray *applicationScreenshots;
@property (nonatomic, strong) NSArray *applicationBigScreenshots;
@property (nonatomic, strong) NSArray *applicationiPadScreenshots;
@property (nonatomic, strong) NSArray *applicationiPadBigScreenshots;
@property (nonatomic, strong) NSArray *applicationCopies;
@property (nonatomic, strong) NSString *applicationDescriptionString;
@property (nonatomic, strong) NSString *applicationLocalizedDescription;
@property (nonatomic, strong) NSString *applicationRequirements;
@property (nonatomic, strong) NSString *applicationCompatibility;
@property (nonatomic, strong) NSString *applicationMinOS;
@property (nonatomic, strong) NSString *applicationMaxOS;

@property (nonatomic, strong) NSString *error;

@property (nonatomic, strong) NSArray * recommended;
@property (nonatomic, assign) BOOL isUniqueInPROJECT;


+(APFAppDescription*) appDescriptionFromDictionary:(NSDictionary*)appDic;

@end
