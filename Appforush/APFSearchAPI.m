//
//  APFiTunesAPI.m
//  PROJECT
//
//  Created by PROJECT on 6/June/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFSearchAPI.h"
#import "APFPROJECTAPI.h"
#import "APFAppEntry.h"
#import "NSString+URLEncode.h"

#define PROJECT_SEARCH_QUERY  API_ROOT@"search/?term=%@&dev=%@&num=50"
#define ITUNES_SEARCH_QUERY     @"http://itunes.apple.com/search?term=%@&country=us&entity=software,iPadSoftware"

@implementation APFSearchAPI

+(NSString*) getURLForSearchQuery:(NSString*)query{
    NSString* device = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"iphone" : @"ipad";
    return [NSString stringWithFormat:PROJECT_SEARCH_QUERY, [query urlencode], device];
}

+(NSString*) getiTunesURLForSearchQuery:(NSString*)query{
    return [NSString stringWithFormat:ITUNES_SEARCH_QUERY, [query urlencode]];
}

+(NSSet*) getAppIDsFromResults:(NSArray *)list {
    NSMutableSet *ids = [[NSMutableSet alloc] init];
    
    for(APFAppEntry *entry in list) {
        [ids addObject:[NSNumber numberWithInteger:[entry.applicationiTunesIdentification intValue]]];
    }
    
    return ids;
}

+(NSMutableArray*) parseResults:(NSData*)data{
    NSMutableArray * ret  = nil;
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
        NSArray *list = [object objectForKey:@"results"];
        NSNumber *resultCount = (NSNumber *)[object objectForKey:@"resultCount"];
        NSMutableArray *appList = [[NSMutableArray alloc] initWithCapacity:[resultCount intValue]];
        for (NSDictionary *entry in list) {
            //BOOL exists = ([entry objectForKey:APP_EXISTS] != nil);
            NSDictionary *ad = [NSDictionary dictionaryWithObjectsAndKeys:
                                [entry objectForKey:APP_NAME],APP_NAME,
                                [entry objectForKey:APP_ID], APP_ID,
                                [entry objectForKey:CATEGORY], CATEGORY,
                                [entry objectForKey:ICON_URL_512], ICON_URL_512,
                                [entry objectForKey:IPAD_SCR_URLS], IPAD_SCR_URLS,
                                [entry objectForKey:IPHONE_SCR_URLS], IPHONE_SCR_URLS,
                                nil];
            [appList addObject:ad];
        }
        ret = appList;
    }
    return ret;
}

-(NSArray*)getPROJECTResults:(NSString *)query {
    if(!query) {
        return [NSArray array];
    }
    
    query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([query length] == 0) {
        return [NSArray array];
    }
    
    APFDownloader* dl = [[APFDownloader alloc] initWithDownloadURLString:[APFSearchAPI getURLForSearchQuery:query] withLifeTime:0];
    
    NSData* searchData = [dl downloadImmediate];
    
    if(!searchData) {
        return [NSArray array]; // nothing found!
    }
    
    NSArray* searchResults = [[APFPROJECTAPI currentInstance] parseDataList:searchData];
    appIds = [APFSearchAPI getAppIDsFromResults:searchResults];
    
    return searchResults;
}

-(NSArray*)getiTunesResults:(NSString *)query {
    if(!query) {
        return [NSArray array];
    }
    
    query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([query length] == 0) {
        return [NSArray array];
    }
    
    APFDownloader* dl = [[APFDownloader alloc] initWithDownloadURLString:[APFSearchAPI getiTunesURLForSearchQuery:query] withLifeTime:0];
    
    NSData* searchData = [dl downloadImmediate];
    NSDictionary* searchDict;
    
    if(!searchData) {
        return [NSArray array];
    }
    
    if(!appIds) {
        appIds = [NSSet set];
    }
    
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:searchData options:0 error:&error];
    
    if(error || ![object isKindOfClass:[NSDictionary class]]) {
        return [NSArray array];
    }
    
    searchDict = object;
    
    NSArray *results = [searchDict objectForKey:@"results"];
    NSNumber *resultCount = (NSNumber *)[searchDict objectForKey:@"resultCount"];
    
    NSMutableArray* searchResults = [[NSMutableArray alloc] initWithCapacity:[resultCount unsignedIntegerValue]];
    
    for(NSDictionary* entry in results) {
        if([appIds containsObject:[entry objectForKey:APP_ID]])
            continue;
        
        NSMutableDictionary* normalizedEntry = [@{
                                                 @"id": [NSString stringWithFormat:@"%@", [entry objectForKey:APP_ID]],
                                                 @"siz": @"Unknown",
                                                 @"nam": [entry objectForKey:APP_NAME],
                                                 @"cat": [entry objectForKey:CATEGORY],
                                                 @"prc": [entry objectForKey:APP_PRICE],
                                                 } mutableCopy];
        
        NSMutableString *iconURLString = [NSMutableString stringWithString:[entry objectForKey:ICON_URL_512]];
        NSLog(@"%@",entry);
        /*if ([iconURLString rangeOfString:@".png"].location != NSNotFound) {
            NSRange extentionRange = [iconURLString rangeOfString:@".png" options:NSBackwardsSearch];
            [iconURLString replaceCharactersInRange:extentionRange withString:@".jpg"];
            [iconURLString insertString:@".150x150-75" atIndex:extentionRange.location];
        }
        else if ([iconURLString rangeOfString:@".jpg"].location != NSNotFound) {
            NSRange extentionRange = [iconURLString rangeOfString:@".jpg" options:NSBackwardsSearch];
            [iconURLString insertString:@".150x150-75" atIndex:extentionRange.location];
        }
        else if ([iconURLString rangeOfString:@".tif"].location != NSNotFound) {
            NSRange extentionRange = [iconURLString rangeOfString:@".tif" options:NSBackwardsSearch];
            [iconURLString insertString:@".150x150-75" atIndex:extentionRange.location];
        }
        else {
            iconURLString = nil;
        }*/
        
        [normalizedEntry setValue:iconURLString forKey:@"a120"];
        
        APFAppEntry* appEntry = [APFAppEntry AppEntryFromDictionary:normalizedEntry];
        appEntry.exists = nil;
        [searchResults addObject:appEntry];
    }
    
    return searchResults;
}




@end
