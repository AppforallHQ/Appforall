//
//  APFAppDelegate.h
//  PROJECT
//
//  Created by PROJECT on 29/May/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APFBackgroundTask.h"
#import <HTTPServer.h>


@interface APFAppDelegate : UIResponder <UIApplicationDelegate> {
    APFBackgroundTask * bgTask;
}
- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HTTPServer *httpServer;
@property (strong, nonatomic) NSDate * lastUpdate;

@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();
-(void) retainBackground;

@end
