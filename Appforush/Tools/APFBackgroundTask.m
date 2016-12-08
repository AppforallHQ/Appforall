//
//  APFBackgroundTask.m
//  PROJECT
//
//  Created by Nima Azimi on 30/July/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFBackgroundTask.h"
#import "APFAppDelegate.h"

@implementation APFBackgroundTask

-(id) init
{
    self = [super init];
    if(self)
    {
        bgTask = UIBackgroundTaskInvalid;
        expirationHandler =nil;
        timer =nil;
    }
    return  self;
    
}

-(void) startBackgroundTasks:(NSInteger)time_  target:(id)target_ selector:(SEL)selector_
{
    timerInterval =time_;
    target = target_;
    selector = selector_;
    
    [self initBackgroudTask];
    
    //minimum 600 sec
    [[UIApplication sharedApplication] setKeepAliveTimeout:900 handler:^{
        [self initBackgroudTask];
    }];
}

-(void) initBackgroudTask
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       if([self running])
                           [self stopAudio];
                       
                       while([self running])
                       {
                           [NSThread sleepForTimeInterval:5]; //wait for finish
                           NSLog(@"HERE FUCK BG");
                       }
                       [self playAudio];
                   });
    
}

- (void) audioInterrupted:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber *interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    if([interuptionType intValue] == 1)
    {
        [self initBackgroudTask];
    }
    
}

-(void) playAudioWav
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        const char bytes[] = {0x52, 0x49, 0x46, 0x46, 0x26, 0x0, 0x0, 0x0, 0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20, 0x10, 0x0, 0x0, 0x0, 0x1, 0x0, 0x1, 0x0, 0x44, 0xac, 0x0, 0x0, 0x88, 0x58, 0x1, 0x0, 0x2, 0x0, 0x10, 0x0, 0x64, 0x61, 0x74, 0x61, 0x2, 0x0, 0x0, 0x0, 0xfc, 0xff};
        NSData* data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
        NSString * docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        // Build the path to the database file
        NSString * filePath = [[NSString alloc] initWithString:
                               [docsDir stringByAppendingPathComponent: @"background.wav"]];
        [data writeToFile:filePath atomically:YES];
        NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
        NSError * error;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        //        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: &error];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        [player setDelegate:(id)self];
        player.volume = 0.01;
        //player.numberOfLoops = -1; //Infinite
        [player prepareToPlay];
        [player play];
        timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:target selector:selector userInfo:nil repeats:NO];
    });
}

-(void) playAudio
{
    
    UIApplication * app = [UIApplication sharedApplication];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    
    typeof(self) __weak weakSelf = self;
    
    expirationHandler = ^{
        typeof(weakSelf) __strong strongSelf = weakSelf;
        [app endBackgroundTask:strongSelf->bgTask];
        strongSelf->bgTask = UIBackgroundTaskInvalid;
        [strongSelf->timer invalidate];
        [strongSelf->player stop];
        NSLog(@"############### Background Task Expired.");
        // [self playMusic];
    };
    bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
    [self playAudioWav];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Audio Stopping for 60 seconds");
    APFAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    NSTimeInterval interval = [delegate.lastUpdate timeIntervalSinceNow];
    NSLog(@"Time Remained : %f",interval);
    if(interval > -900)
    {
        NSLog(@"WE STILL HAVE TIME TO PLAY AUDIO");
        [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(playAudioWav) userInfo:nil repeats:NO];
    }
    else{
        NSLog(@"TERMINATED SERVER AND BACKGROUND");
        [delegate.httpServer stop];
        [self stopAudio];
    }
}

-(void) stopAudio
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];

    if(timer != nil && [timer isValid])
        [timer invalidate];
    
    if(player != nil && [player isPlaying])
        [player stop];
    
    if(bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask=UIBackgroundTaskInvalid;
    }
}
-(BOOL) running
{
    if(bgTask == UIBackgroundTaskInvalid)
        return FALSE;
    return TRUE;
}
@end
