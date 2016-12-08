//
//  APFBackgroundTask.h
//  PROJECT
//
//  Created by Nima Azimi on 30/July/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface APFBackgroundTask : NSObject {
    __block UIBackgroundTaskIdentifier bgTask;
    __block dispatch_block_t expirationHandler;
    __block NSTimer * timer;
    __block AVAudioPlayer *player;
    
    NSInteger timerInterval;
    id target;
    SEL selector;
}

@property (nonatomic, assign) BOOL isRunning;

-(BOOL) running;
-(void) playAudio;
-(void) startBackgroundTasks:(NSInteger)time_  target:(id)target_ selector:(SEL)selector_;
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end
