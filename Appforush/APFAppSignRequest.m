//
//  APFAppSignRequest.m
//  PROJECT
//
//  Created by PROJECT on 30/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFAppSignRequest.h"
#import "APFPROJECTAPI.h"
#import <SDCAlertView/SDCAlertView.h>
#import <SEGAnalytics.h>

@implementation APFAppSignRequest

-(id) initWithDownloader:(APFDownloader*) dl forAppId:(NSString *)appId{
    self = [super init];
    if(self) {
        delay = 5;
        soFar = 0;
        self.done = NO;
        self.twoStage = NO;
        self.appId = appId;

        dl.didFinishDownload = ^(NSData * data){
            if (data == nil) {
                [self handleError:nil];
            } else {
                [self processMessage:data];
            }
        };
        
        dl.didFailDownload = ^(NSError *err){
            [self handleError:(NSError*) err];
        };
        
        [dl start];
        
        self.dler = dl;
    }
    return self;
}

-(void) retry {
    //TODO uncomment
//    [[Analytics sharedAnalytics] track:@"App Sign Request - Retrying" properties:
//     @{ @"Request ID": [NSNumber numberWithInt:self.reqID],
//        @"Delay Interval" : [NSNumber numberWithInt:delay]}];
    soFar += delay;
    NSLog(@"Retrying!");
    [self.dler start];
}


-(void) processMessage:(NSData*) data {
    
    if(self.done)
        return;

    NSError *error = nil;
    NSDictionary *results;
    
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    if(error) {
        NSLog(@"Error: %@", error); // TODO failed = true?
        return;
    }
    
    if([object isKindOfClass:[NSDictionary class]]){
        results = object;
    }
    NSLog(@"Amir : %@",object);
    if (!results) {
        return;
    }
    
    NSString *status = [object objectForKey:@"status"];
    BOOL failed = false;
    
    if ([@"ready" isEqualToString:status]) {
        
        if([object objectForKey:@"rawfile"] != nil && [object objectForKey:@"patchfile"] != nil) {
            NSString *rawUrl = [object objectForKey:@"rawfile"];
            NSString *patchUrl = [object objectForKey:@"patchfile"];
            self.downloadAppUrl = rawUrl;
            self.downloadExtraUrl = patchUrl;
            self.twoStage = YES;
        }
        else {
            NSString *path = [object objectForKey:@"path"];
            self.downloadAppUrl = path;
            self.twoStage = NO;
        }
        
        if ([self.delegate respondsToSelector:@selector(didFetchDownloadAppUrl:)]) {
            [self.delegate didFetchDownloadAppUrl:self];
        }
        
        self.done = true;
    }
    else if([@"error" isEqualToString:status]) {
        failed = true;
        
        NSNumber* userStatus = [object objectForKey:@"user_status"];
        NSInteger userStatusInt = -1;
        
        if(userStatus) {
            userStatusInt = userStatus.integerValue;
        }
        
        switch(userStatusInt) {
            case UserStatusBlocked: {
                SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                                  message:@"اکانت شما قفل شده. لطفا با پشتیبانی تماس بگیرید!"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"تایید"
                                                        otherButtonTitles:nil, nil];
                [alert show];
                
                break;
            }
                
            case UserStatusEmailNotActive: {
                [[APFPROJECTAPI currentInstance] showEmailActivation];
                
                break;
            }
                
            case UserStatusLimited: {
                SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                                  message:@"لطفا آخرین صورتحساب خود را پرداخت نمایید"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"انصراف"
                                                        otherButtonTitles:@"تایید", nil];
                
                [alert showWithDismissHandler:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[object objectForKey:@"link"]]];
                    }
                }];
                
                break;
            }
                
            case UserStatusOk: {
                SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                                  message:@"درخواست شما با موفقیت ثبت شد. \nدانلود برنامه تا چند ثانیه دیگر آغاز می‌شود..."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"تایید"
                                                        otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
                
            case UserStatusUnknown:
            default: {
                SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                                  message:@"خطا در شناسایی آخرین وضعیت کاربر! لطفاً با پشتیبانی تماس بگیرید."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"تایید"
                                                        otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    else if([@"update" isEqualToString:status]){
        NSLog(@"Amir: %@",[object objectForKey:@"path"]);
        NSString *lastversion = [object objectForKey:@"lastv"];
        if (![VERSION isEqualToString:lastversion]) {
            //                [self updateAvailable];
            [APFPROJECTAPI currentInstance].compulsaryUpdate = YES;
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:true completion:nil];
            
            
        }
    }
    else if([@"not-downloadable" isEqualToString:status])
    {
        failed = true;
        SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                          message:@"برای دانلود رایگان این برنامه و دسترسی نامحدود به بیش از ۱۲ هزار برنامه دیگر٬ کافیست اشتراک ویژه اپفورال را تهیه کنید."
                                                         delegate:nil
                                                cancelButtonTitle:@"تایید"
                                                otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([@"working" isEqualToString:status]) {
        if (soFar <= 30) {
            if(soFar == 0) { // first time
                SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                                  message:@"درخواست شما با موفقیت ثبت شد. \nدانلود برنامه تا چند ثانیه دیگر آغاز می‌شود..."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"تایید"
                                                        otherButtonTitles:nil, nil];
                [alert show];
            }
            
            [self performSelector:@selector(retry) withObject:nil afterDelay:delay];
        }
        else {
            SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                              message:@"با عرض پوزش، در حال حاضر امکان دانلود این برنامه وجود ندارد. لطفا بعداً سعی کنید."
                                                             delegate:nil
                                                    cancelButtonTitle:@"تایید"
                                                    otherButtonTitles:nil, nil];
            [alert show];
            
            failed = true;
        }
    }
    
    if(failed) {
        if ([self.delegate respondsToSelector:@selector(failedDownloadAppUrl:)]) {
            [self.delegate failedDownloadAppUrl:self];
        }
        
        self.done = true;
    }
}

-(void) handleError:(NSError*) err{
    //if(self.done)
    //    return;
    if ([self.delegate respondsToSelector:@selector(failedDownloadAppUrl:)]) {
        [self.delegate failedDownloadAppUrl:self];
    }
    
    self.done = true;
}

@end
