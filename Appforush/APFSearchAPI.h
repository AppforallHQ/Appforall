//
//  APFiTunesAPI.h
//  PROJECT
//
//  Created by PROJECT on 6/June/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_NAME            @"trackName"
#define APP_ID              @"trackId"
#define CATEGORY            @"primaryGenreName"
#define ICON_URL_100        @"artworkUrl100"
#define ICON_URL_512        @"artworkUrl512"
#define IPAD_SCR_URLS       @"ipadScreenshotUrls"
#define IPHONE_SCR_URLS     @"screenshotUrls"
#define APP_EXISTS          @"exists"
#define APP_PRICE           @"formattedPrice"

@interface APFSearchAPI : NSObject {
    NSSet* appIds;
}

+(NSString*) getURLForSearchQuery:(NSString*)query;
+(NSString*) getiTunesURLForSearchQuery:(NSString*)query;
+(NSSet*) getAppIDsFromResults:(NSArray*)list;
+(NSMutableArray*) parseResults:(NSData*)data;

-(NSArray*) getPROJECTResults:(NSString*)query;
-(NSArray*) getiTunesResults:(NSString*)query;

@end
