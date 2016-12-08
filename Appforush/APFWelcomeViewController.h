//
//  APFWelcomeViewController.h
//  PROJECT
//
//  Created by Nima Azimi on 12/June/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EAIntroView/EAIntroView.h>
#import "APFPROJECTAPI.h"

@interface APFWelcomeViewController : UIViewController <APFPROJECTAPIDelegate, EAIntroDelegate>

@property (nonatomic, assign) NSUInteger availableUpdatesCount;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *loginView;

-(void) didRegisterSuccessful;

@end
