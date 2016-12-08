//
//  APFDownloader.h
//  PROJECT
//
//  Created by PROJECT on 29/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APFDownloaderErrorDomain @"ir.PROJECT.APFDownloaderErrorDomain"

@interface APFDownloader : NSObject <NSURLConnectionDelegate> {
    long long written, expected;
    BOOL _forceDownload;
}

@property (nonatomic, strong) NSString *downloadURL;
@property (nonatomic, strong) NSString *requestBody;
@property (nonatomic, assign) BOOL isPOST;

@property (nonatomic, strong) NSNumber *lifetime;
@property (nonatomic, assign) BOOL forceDownload;

@property (nonatomic, copy) void (^didFinishDownload)(NSData*);
@property (nonatomic, copy) void (^didFailDownload)(NSError*);
@property (nonatomic, copy) void (^updateDownloadProgress)(float);

@property (nonatomic,assign) float timeoutInterval;

@property (nonatomic, strong) NSString* userAgent;

-(id) initWithDownloadURLString:(NSString*)url withLifeTime:(NSNumber*)lifetime;
-(id) initWithDownloadURLString:(NSString *)url withLifeTime:(NSNumber *)lifetime withPostBody:(NSString*)postBody;
-(id) initWithDownloadURLString:(NSString*)url withLifeTime:(NSNumber*)lifetime useAppStoreUserAgent:(BOOL)appStoreUserAgent;
-(id) initWithDownloadURLString:(NSString*)url withLifeTime:(NSNumber*)lifetime forceDownload:(BOOL)fDownload;
-(id) initWithDownloadURLString:(NSString*)url withLifeTime:(NSNumber*)lifetime forceDownload:(BOOL)fDownload useAppStoreUserAgent:(BOOL)appStoreUserAgent;
-(void) forceStart;
-(void) start;
-(float) downloadProgress;
-(NSData*) downloadImmediate;



@end
