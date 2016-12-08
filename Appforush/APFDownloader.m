//
//  APFDownloader.m
//  PROJECT
//
//  Created by PROJECT on 29/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFDownloader.h"

@interface APFDownloader ()

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *activeConnection;

@end

@implementation APFDownloader

#define CACHE_FOLDER @"/cache"

NSArray* iPhoneUserAgents;
NSArray* iPadUserAgents;

+(NSString*) getRandomAppStoreUserAgent {
    if(!iPhoneUserAgents) {
        iPhoneUserAgents = @[
            @"AppStore/2.0 iOS/8.2 model/iPhone7,1 build/12D508 (6; dt:107)",
            @"AppStore/2.0 iOS/7.1.2 model/iPhone6,1 build/11D257 (6; dt:89)",
            @"AppStore/2.0 iOS/8.3 model/iPhone6,1 build/12F70 (6; dt:89)"
        ];
        
        iPadUserAgents = @[
            @"AppStore/2.0 iOS/8.2 model/iPad4,1 build/12D508 (5; dt:94)",
            @"AppStore/2.0 iOS/8.1.3 model/iPad3,4 build/12B466 (5; dt:83)",
        ];
    }
    
    __weak NSArray* target = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? iPhoneUserAgents : iPadUserAgents;
    
    NSUInteger randomIndex = arc4random() % [target count];
    
    return [target objectAtIndex:randomIndex];
}

-(id) initWithDownloadURLString:(NSString *)url withLifeTime:(NSNumber *)lifetime forceDownload:(BOOL)fDownload useAppStoreUserAgent:(BOOL)appStoreUserAgent {
    self = [self initWithDownloadURLString:url withLifeTime:lifetime forceDownload:fDownload];
    
    if(appStoreUserAgent) {
        self.userAgent = [APFDownloader getRandomAppStoreUserAgent];
    }
    
    return self;
}

-(id)initWithDownloadURLString:(NSString *)url withLifeTime:(NSNumber *)lifetime useAppStoreUserAgent:(BOOL)appStoreUserAgent {
    self = [self initWithDownloadURLString:url withLifeTime:lifetime forceDownload:NO useAppStoreUserAgent:appStoreUserAgent];
    return self;
}

-(id) initWithDownloadURLString:(NSString*)url withLifeTime:(NSNumber*)lifetime forceDownload:(BOOL)fDownload{
    self = [super init];
    if (self) {
        self.downloadURL = url;
        self.lifetime = lifetime;
        // self.lifetime = 0;
        self.isPOST = false;
        written = expected = 0;
        self.forceDownload = fDownload;
    }
    return self;
}

-(id) initWithDownloadURLString:(NSString*)url withLifeTime:(NSNumber*)lifetime
{
    self = [super init];
    if (self) {
        self.downloadURL = url;
        self.lifetime = lifetime;
        //        self.lifetime = 0;
        self.isPOST = false;
        written = expected = 0;
        self.forceDownload = NO;
    }
    return self;
}

-(id) initWithDownloadURLString:(NSString *)url withLifeTime:(NSNumber *)lifetime withPostBody:(NSString*)postBody
{
    self = [super init];
    if (self)
    {
        self.downloadURL = url;
        self.lifetime = lifetime;
        self.isPOST = true;
        self.requestBody = postBody;
        written = expected = 0;
        self.forceDownload = NO;
    }
    return self;
}

- (NSString *)documentsPathForURLString:(NSString *)url
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    if(url!=nil){
        return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:CACHE_FOLDER@"/%u",[url hash]]];
    }else{
        return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:CACHE_FOLDER]];
    }
}

- (void) prepareCacheFolder
{
    NSString *path = [self documentsPathForURLString:nil];
    NSFileManager *nsf = [NSFileManager defaultManager];
    if (![nsf fileExistsAtPath:path]) {
        [nsf createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

-(NSData*) checkCache
{
    if (self.lifetime.doubleValue<1 || self.forceDownload) {
        return nil;
    }
    
    [self prepareCacheFolder];
    NSData *data = nil;
    NSString *docPath = [self documentsPathForURLString:self.downloadURL];
    NSFileManager *nsf = [NSFileManager defaultManager];
    //    NSLog(@"checking cache at %@", docPath);
    if ([nsf fileExistsAtPath:docPath]) {
        //        NSLog(@"File exists at %@", docPath);
        NSDictionary *att = [nsf attributesOfItemAtPath:docPath error:nil];
        if (att!=nil) {
            NSDate * modDate = [att fileModificationDate];
            //            NSLog(@"Mod date %@", modDate);
            if (modDate != nil && [[NSDate date] timeIntervalSinceDate:modDate] < [self.lifetime doubleValue]) {
                data = [NSData dataWithContentsOfFile:docPath];
                //                NSLog(@"Using cache on %@", self.downloadURL);
            }else{
                NSLog(@"File %@ has expired", self.downloadURL);
                [nsf removeItemAtPath:docPath error:nil];
            }
        }else{
            NSLog(@"File %@ has expired", self.downloadURL);
            [nsf removeItemAtPath:docPath error:nil];
        }
    }
    return data;
}

-(void) saveToCache:(NSData*)data
{
    if (self.lifetime.doubleValue<1) {
        return;
    }
    if ([self.activeDownload length]>0) {
        NSString *savingPath =[self documentsPathForURLString:self.downloadURL];
        [data writeToFile:savingPath atomically:YES];
        //        NSLog(@"Cache data saved at %d, %@", [self.activeDownload length], savingPath);
    }
}


-(float) downloadProgress
{
    float ret = 0;
    if(expected!=0){
        ret = (float)(written)/(float)(expected);
    }
    //    NSLog(@"Progress: (%u,%u) %f", written, expected, ret);
    return ret;
}

-(NSData*) downloadImmediate
{
    NSData *retVal = [self checkCache];
    //    NSLog(@"Request to %@", self.downloadURL);
    if (retVal==nil) {
        //        retVal = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.downloadURL] options:NSDataReadingUncached error:nil];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadURL]
                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:60.0];
        
        if(self.userAgent) {
            [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
            [request setValue:@"143441-1,20 t:native" forHTTPHeaderField:@"X-Apple-Store-Front"];
        }
        
        retVal = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:nil
                                                   error:nil];
        [self saveToCache:retVal];
    }
    //    NSLog(@"Returning %@", [[NSString alloc] initWithData:retVal encoding:NSASCIIStringEncoding]);
    return retVal;
}


-(void) start
{
    NSData *retVal = [self checkCache];
    if (retVal!=nil) {
        if(self.didFinishDownload)
            self.didFinishDownload(retVal);
    }
    else {
        self.activeDownload = [NSMutableData data];
        if(!self.timeoutInterval)
        {
            self.timeoutInterval = 20;
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadURL]
                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:self.timeoutInterval];
        
        if (self.isPOST)
        {
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"REQUEST BODY : %@",self.requestBody);
        }
        
        if(self.userAgent) {
            [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
            [request setValue:@"143441-1,20 t:native" forHTTPHeaderField:@"X-Apple-Store-Front"];
        }

        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        self.activeConnection = conn;
    }
}

-(void) forceStart
{
    self.activeDownload = [NSMutableData data];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadURL]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:60.0];
    
    if(self.userAgent) {
        [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"143441-1,20 t:native" forHTTPHeaderField:@"X-Apple-Store-Front"];
    }
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.activeConnection = conn;
}


///////////////////////////////////////////////
#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if([response respondsToSelector:@selector(statusCode)]) {
        NSInteger statusCode = [((NSHTTPURLResponse*)response) statusCode];
        
        if(statusCode / 100 >= 4) { // Some kind of error happened
            [connection cancel];
            
            if(self.didFailDownload) {
                NSError* error = [NSError errorWithDomain:APFDownloaderErrorDomain code:-1 userInfo:@{@"statusCode": [NSNumber numberWithInteger:statusCode]}];
                self.didFailDownload(error);
            }
            
            self.activeConnection = nil;
            self.activeDownload = nil;
            
        }
    }
    
    expected = response.expectedContentLength;
    written = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.activeDownload appendData:data];
    written += data.length;
    
    if (self.updateDownloadProgress) {
        self.updateDownloadProgress([self downloadProgress]);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Download error %@", error);
    
    self.activeDownload = nil;
    self.activeConnection = nil;
    
    if(self.didFailDownload)
        self.didFailDownload(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    // NSLog(@"Download finished! %u vs. %u / %u | %@", written,self.activeDownload.length , expected, self.downloadURL);
    
    [self saveToCache:self.activeDownload];
    
    if(self.didFinishDownload)
        self.didFinishDownload(self.activeDownload);
    
    self.activeDownload = nil;
    self.activeConnection = nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}


@end
