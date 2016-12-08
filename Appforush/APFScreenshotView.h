//
//  ScreenshotView.h
//  AppForush
//
//  Created by Alireza Shuserei on 7/23/13.
//  Copyright (c) 2013 AppForush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APFAppDescriptionViewController.h"
#import "GCPagedScrollView.h"

@interface APFScreenshotView : UIView{
    CGFloat frame_width, frame_height;
}

@property (weak, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, atomic) GCPagedScrollView *scrollView;
@property (strong, atomic) NSData *imageData;
@property (assign, atomic) BOOL isReady;

- (id) initWithImageURLString:(NSString*)imageURL;

@end
