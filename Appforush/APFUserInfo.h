//
//  APFUserInfo.h
//  PROJECT
//
//  Created by Nima Azimi on 21/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFDownloader.h"
#import <Foundation/Foundation.h>

@interface APFUserInfo : NSObject

@property (strong, nonatomic) NSString *userId;
@property (nonatomic, strong) NSString *firstName;
@property (strong, nonatomic) NSString *email;
@property (nonatomic, assign) NSInteger userStatus;
@property (strong, nonatomic) NSString *billPaymentUrl;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSDate *expire_date;
@property (strong, nonatomic) NSDate *campaigns;
@property (strong, nonatomic) APFDownloader *avatarDL;
@property (nonatomic, copy) void (^avatarDownloadedHandler)(void);


-(id) initWithId:(NSString *)userId andFirstName:(NSString *)name andEmail:(NSString *)email;
-(void) startDownloadAvatar;

+(NSDate*) dateJSONTransformer:(NSString*)dateString;
+(NSDate*) campaignsDate:(NSString*)dateString;

@end
