//
//  APFUserInfo.m
//  PROJECT
//
//  Created by Nima Azimi on 21/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFUserInfo.h"
#import "APFPROJECTAPI.h"

@implementation APFUserInfo

-(id) initWithId:(NSString *)userId andFirstName:(NSString *)firstName andEmail:(NSString *)email {
    
    if (self = [super init]) {
        self.userId = userId;
        self.firstName = firstName;
        self.email = email;
        self.userStatus = UserStatusUnknown;
    }
    return  self;
}

-(void)startDownloadAvatar {
    APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:self.avatarUrl withLifeTime:[NSNumber numberWithDouble:3600 * 24]];
    self.avatarDL = dl;
    
    dl.didFinishDownload = ^(NSData *data) {
        UIImage* image = [[UIImage alloc] initWithData:data];
        self.avatar = image;
        
        if(self.avatarDownloadedHandler) {
            self.avatarDownloadedHandler();
        }
        
        self.avatarDL = nil;
    };
    
    [dl start];
}

+(NSDate*) dateJSONTransformer:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSSSSSZ"];
    return [dateFormatter dateFromString:dateString];
}

+(NSDate*) campaignsDate:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSS"];
    return [dateFormatter dateFromString:dateString];
}

@end
