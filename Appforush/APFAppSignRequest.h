//
//  APFAppSignRequest.h
//  PROJECT
//
//  Created by PROJECT on 30/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APFDownloader.h"


@protocol APFAppSignRequestDelegate <NSObject>

@required
- (void) didFetchDownloadAppUrl:(id)sender;
- (void) failedDownloadAppUrl:(id)sender;

@end

@interface APFAppSignRequest : NSObject {
    
    int delay;
    int soFar;
}

@property (nonatomic, assign) int reqID;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, retain) APFDownloader *dler;
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, assign) id<APFAppSignRequestDelegate> delegate;

@property (nonatomic, strong) NSString *downloadAppUrl;
@property (nonatomic, strong) NSString *downloadExtraUrl;

@property (nonatomic, assign) BOOL twoStage;

-(id) initWithDownloader:(APFDownloader*) dl forAppId:(NSString *)appId;
-(void) processMessage:(NSData*) data;

@end
