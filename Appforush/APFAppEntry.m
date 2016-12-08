//
//  APFAppEntry.m
//  PROJECT
//
//  Created by PROJECT on 29/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFAppEntry.h"
#import "APFPROJECTAPI.h"

#define kAppIconSize 60

static UIImage* maskw;
static UIImage* maskg;

@implementation APFAppEntry

-(id) init{
    self = [super init];
    if (self) {
        self.exists = [NSNumber numberWithBool:true];
        self.availableInBasic = false;
        
        if(!maskw){
            maskw = [UIImage imageNamed:@"afNoImage1"];
            maskg = [UIImage imageNamed:@"afNoImage2"];
            tries = 0;
            isDownloadingIcon = false;
        }
    }
    return self;
}

+(APFAppEntry*) AppEntryFromDictionary:(NSDictionary*) appEntryDic{
    APFAppEntry *ret = [[APFAppEntry alloc] init];
    
    [ret setDataFromDictionary:appEntryDic];
    
    return ret;
}

-(void) setDataFromDictionary:(NSDictionary*) appEntryDic {
    [self setApplicationName:[appEntryDic objectForKey:@"nam"]];
    [self setApplicationVersion:[appEntryDic objectForKey:@"ver"]];
    [self setApplicationDownloads:[NSNumber numberWithInt:[[appEntryDic objectForKey:@"gdl"] intValue]]];
    [self setApplicationAFDownloads:[NSNumber numberWithInt:[[appEntryDic objectForKey:@"dl"] intValue]]];
    [self setApplicationiTunesIdentification:[appEntryDic objectForKey:@"id"]];
    [self setApplicationCompatibility:[appEntryDic objectForKey:@"com"]];
    [self setApplicationSize:[appEntryDic objectForKey:@"siz"]];
    [self setApplicationCopies:[appEntryDic objectForKey:@"cop"]];
    [self setApplicationReleaseNote:[appEntryDic objectForKey:@"releaseNote"]];
    [self setApplicationIconURL:[appEntryDic objectForKey:@"a120"]];
    [self setApplicationLargeIconURL:[appEntryDic objectForKey:@"a160"]];
    [self setApplicationHugeIconURL:[appEntryDic objectForKey:@"a512"]];
    [self setApplicationCategory:[appEntryDic objectForKey:@"cat"]];
    [self setApplicationOriginalPrice:[appEntryDic objectForKey:@"prc"]];
    [self setUserAppleID:[appEntryDic objectForKey:@"PROJECT2"]];
    [self setAvailableInBasic:[[appEntryDic objectForKey:@"userbasic"] boolValue]];
    
    
    if ([appEntryDic objectForKey:@"PROJECT"])
        [self setAvailableInPROJECT:[[appEntryDic objectForKey:@"PROJECT"] boolValue]];
    else
        [self setAvailableInPROJECT:false];
    
    if ([appEntryDic objectForKey:@"irprc"])
        [self setIranPrice:[[appEntryDic objectForKey:@"irprc"] integerValue]];
    else
        [self setIranPrice:-1];
    
    if ([appEntryDic objectForKey:@"averageUserRating"]){
        [self setAverageUserRating:[[appEntryDic objectForKey:@"averageUserRating"] floatValue]];
        [self setUserRatingCount:[[appEntryDic objectForKey:@"userRatingCount"] integerValue]];
    }
    else{
        [self setAverageUserRating:0.0];
        [self setUserRatingCount:0];
    }

    
    
    if ([appEntryDic objectForKey:@"abstatus"]) {
        [self setApplicationAppBuyStatus:[NSNumber numberWithInt:[[appEntryDic objectForKey:@"abstatus"] intValue]]];
    }
    else {
        [self setApplicationAppBuyStatus:nil];
    }
}

-(void)startDownloadIconWithSize:(IconSize)size {
    if (self.activeIconDL) {
        return;
    }
    
    NSString *urlString;
    APFAppEntry *link = self;
    
    switch(size) {
        case NormalIcon:
            urlString = self.applicationIconURL;
            break;
        case LargeIcon:
            urlString = self.applicationLargeIconURL;
            break;
        case HugeIcon:
            urlString = self.applicationHugeIconURL;
            break;
    }
    
    if(!urlString)
        return;
    
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:urlString withLifeTime:[NSNumber numberWithDouble:10*24*3600] useAppStoreUserAgent:TRUE];
    self.activeIconDL = dl;
    
    __weak APFDownloader *dlLink = dl;
    
    dl.didFinishDownload = ^(NSData *data){
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        switch(size) {
            case NormalIcon:
                link.applicationIcon = image;
                break;
            case LargeIcon:
                link.applicationLargeIcon = image;
                break;
            case HugeIcon:
                link.applicationHugeIcon = image;
                break;
        }
        
        // call our delegate and tell it that our icon is ready for display
        if (link.iconDownloadedHandler)
            link.iconDownloadedHandler();
        
        self.activeIconDL = nil;
        isDownloadingIcon = false;
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

-(void)startDownloadIcon {
    if(self.applicationIcon || isDownloadingIcon) {
        return;
    }
    
    isDownloadingIcon = true;
    [self startDownloadIconWithSize:NormalIcon];
    
}

-(void)startDownloadDescriptionForAppBuy:(BOOL)isAppBuy {
    
    if(self.activeDescDL || self.applicationDescription){
        return;
    }
    
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:
                      [[APFPROJECTAPI currentInstance] getURLForAppDescriptionWithiTunesID:self.applicationiTunesIdentification forAppBuy:isAppBuy] withLifeTime:[NSNumber numberWithDouble:0] useAppStoreUserAgent:true]; //Prev: 3600
    
    APFAppEntry *link = self;
    
    dl.didFinishDownload = ^(NSData *data){
        APFAppDescription *desc = [[APFPROJECTAPI currentInstance] parseDescriptionFromData:data];
        
        [link setApplicationDescription:desc];
        
        if (link.descriptionDownloadedHandler)
            link.descriptionDownloadedHandler();
        
        link.activeDescDL = nil;
    };
    
    dl.didFailDownload = ^(NSError* error) {
        if(link.descriptionDownloadFailedHandler) {
            link.descriptionDownloadFailedHandler();
        }
    };
    
    self.activeDescDL = dl;
    
    [dl start];
}

@end
