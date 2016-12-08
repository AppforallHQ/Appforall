//
//  APFAppDescription.m
//  PROJECT
//
//  Created by PROJECT on 30/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFAppDescription.h"
#import "APFPROJECTAPI.h"

#define NAME_KEY @"nam"
#define GLOBAL_DOWNLOAD_KEY @"gdl"
#define ORUSH_DOWNLOAD_KEY @"dl"
#define CATEGORY_KEY @"cat"
#define ICON_KEY @"ico"
#define VERSION_KEY @"ver"
#define DEVELOPER_KEY @"ven"
#define RELEASE_DATE_KEY @"rel"
#define ADDED_DATE_KEY @"add"
#define SIZE_KEY @"siz"
#define SCREENSHOTS_KEY @"scr"
#define BIG_SCREENSHOTS_KEY @"bigscr"
#define IPAD_SCREENS_KEY @"iscr"
#define IPAD_BIG_SCREENS_KEY @"bigiscr"
#define DESCRIPTIONS_KEY @"des"
#define REQUIRMENTS_KEY @"req"
#define COPIES_KEY @"cop"
#define COMPATIBILITY @"com"
#define MIN_OS @"minos"
#define MAX_OS @"maxos"
#define ITUNES_IDENTIFICATION @"id"
#define LOCALIZED_DESCRIPTION @"locdes"
#define RECOMMEND @"recommend"

@implementation APFAppDescription

static NSDateFormatter *nsf = NULL;

+(APFAppDescription*) appDescriptionFromDictionary:(NSDictionary*)appDic{
    if ([appDic objectForKey:@"error"]!=nil) {
        return nil;
    }
    if (nsf==NULL) {
        nsf = [[NSDateFormatter alloc] init];
        [nsf setDateFormat:@"YYYY/MM/dd"];
    }
    APFAppDescription *retVal = [[APFAppDescription alloc] init];
    [retVal setApplicationName:[appDic objectForKey:NAME_KEY]];
    [retVal setApplicationMinOS:[appDic objectForKey:MIN_OS]];
    [retVal setApplicationMaxOS:[appDic objectForKey:MAX_OS]];
    [retVal setApplicationDownloads:[NSNumber numberWithInt:[[appDic objectForKey:GLOBAL_DOWNLOAD_KEY] intValue]]];
    [retVal setApplicationAFDownloads:[NSNumber numberWithInt:[[appDic objectForKey:ORUSH_DOWNLOAD_KEY] intValue]]];
    [retVal setApplicationCategory:[appDic objectForKey:CATEGORY_KEY]];
    [retVal setApplicationVersion:[appDic objectForKey:VERSION_KEY]];
    [retVal setApplicationDeveloper:[appDic objectForKey:DEVELOPER_KEY]];
    [retVal setApplicationReleaseDate:
     [NSNumber numberWithInt:[[appDic objectForKey:RELEASE_DATE_KEY] intValue]]];
    
    [retVal setApplicationAddedDate:
     [NSNumber numberWithInt:[[appDic objectForKey:ADDED_DATE_KEY] intValue]]];
    
    [retVal setApplicationSize:[appDic objectForKey:SIZE_KEY]];
    
    [retVal setApplicationScreenshots:[appDic objectForKey:SCREENSHOTS_KEY]];
    
    [retVal setApplicationBigScreenshots:[appDic objectForKey:BIG_SCREENSHOTS_KEY]];
    
    [retVal setApplicationiPadScreenshots:[appDic objectForKey:IPAD_SCREENS_KEY]];
    
    [retVal setApplicationiPadBigScreenshots:[appDic objectForKey:IPAD_BIG_SCREENS_KEY]];
    
    [retVal setApplicationDescriptionString:[appDic objectForKey:DESCRIPTIONS_KEY]];
    
    [retVal setApplicationLocalizedDescription:[appDic objectForKey:LOCALIZED_DESCRIPTION]];
    
    [retVal setApplicationRequirements:[appDic objectForKey:REQUIRMENTS_KEY]];
    
    [retVal setApplicationCopies:[appDic objectForKey:COPIES_KEY]];
    
    [retVal setApplicationCompatibility:[appDic objectForKey:COMPATIBILITY]];
    
    [retVal setApplicationPrice:[appDic objectForKey:@"prc"]];
    
    [retVal setApplicationiTunesIdentification:[appDic objectForKey:ITUNES_IDENTIFICATION]];
    
    [retVal setApplicationIconURL:[appDic objectForKey:@"a120"]];
    [retVal setApplicationLargeIconURL:[appDic objectForKey:@"a160"]];
    [retVal setApplicationHugeIconURL:[appDic objectForKey:@"a512"]];
    
    [retVal setIsUniqueInPROJECT:false];
    if ([appDic objectForKey:@"uniq"])
    {
        [retVal setIsUniqueInPROJECT:[[appDic objectForKey:@"uniq"] boolValue]];
    }
    
    
    if ([appDic objectForKey:RECOMMEND])
    {
        [retVal setRecommended:[appDic objectForKey:RECOMMEND]];
        NSLog(@"Recommended Set");
    }
    else
    {
        [retVal setRecommended:[NSArray array]];
    }
    
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
//        ([UIScreen mainScreen].scale == 2.0)) {
//        [retVal setApplicationIconURL:[appDic objectForKey:@"a120"]];
//    } else {
//        [retVal setApplicationIconURL:[appDic objectForKey:@"a60"]];
//    }
    //    [retVal setApplicationIconURL:[appDic objectForKey:ICON_KEY]];
    
    //    for (NSString* scr in retVal.applicationScreenshots) {
    //        NSLog(@"%@", scr);
    //    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[retVal.applicationAddedDate intValue]];
    retVal.applicationAddedDateString = [nsf stringFromDate:date];
    date = [NSDate dateWithTimeIntervalSince1970:[retVal.applicationReleaseDate intValue]];
    retVal.applicationReleaseDateString = [nsf stringFromDate:date];
    
    return retVal;
}


@end
