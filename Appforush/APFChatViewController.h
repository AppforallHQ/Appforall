//
//  APFChatViewController.h
//  PROJECT
//
//  Created by Nima Azimi on 14/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APFChatViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *chatView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, copy) NSString *chatUrl;

@end
