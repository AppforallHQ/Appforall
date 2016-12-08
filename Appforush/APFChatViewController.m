//
//  APFChatViewController.m
//  PROJECT
//
//  Created by Nima Azimi on 14/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFChatViewController.h"

@interface APFChatViewController ()

@end

@implementation APFChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"پشتیبانی"];
    
    [self.chatView setAlpha:0.0];
    [self.chatView setDelegate:self];
    
    [self.loadingView startAnimating];
    
    NSURL *url = [NSURL URLWithString:self.chatUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.chatView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    void (^showChatView)(void) = ^(void) {
        [self.chatView setAlpha:1.0];
        [self.loadingView setAlpha:0.0];
    };
    
    void (^stopIndicator)(BOOL) = ^(BOOL finished) {
        [self.loadingView stopAnimating];
    };
    
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:showChatView
                     completion:stopIndicator];
    
    NSString* js = @"var meta = document.createElement('meta');"
    @"meta.setAttribute( 'name', 'viewport' );"
    @"meta.setAttribute( 'content', 'width=%@; user-scalable=0; initial-scale=1.0; maximum-scale=1.0' );"
    @"document.getElementsByTagName('head')[0].appendChild(meta);";
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:js, @"device-width"]];
}


@end
