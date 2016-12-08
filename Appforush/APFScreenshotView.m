//
//  ScreenshotView.m
//  AppForush
//
//  Created by Alireza Shuserei on 7/23/13.
//  Copyright (c) 2013 AppForush. All rights reserved.
//

#import "APFScreenshotView.h"
#import "APFDownloader.h"

static UIImage *placeholder;

@interface APFScreenshotView ()
@end

#define IPAD_FRAME_WIDTH 638
#define IPAD_FRAME_HEIGHT 300

#define IPHONE_FRAME_WIDTH 300
#define IPHONE_FRAME_HEIGHT 260


#define FRAME_WIDTH frame_width
#define FRAME_HEIGHT frame_height

@implementation APFScreenshotView

- (id) initWithImageURLString:(NSString*)imageURL{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [self initWithFrame:CGRectMake(0, 0, IPHONE_FRAME_WIDTH, IPHONE_FRAME_HEIGHT)];
    }else{
        self = [self initWithFrame:CGRectMake(0, 0, IPAD_FRAME_WIDTH, IPAD_FRAME_HEIGHT)];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        frame_width = IPHONE_FRAME_WIDTH;
        frame_height = IPHONE_FRAME_HEIGHT;
    }else{
        frame_width = IPAD_FRAME_WIDTH;
        frame_height = IPAD_FRAME_HEIGHT;
    }

    self.isReady = NO;
    
    self.imageURL = imageURL;
    
        APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:imageURL withLifeTime:[NSNumber numberWithDouble:15*24*3600] useAppStoreUserAgent:true];
        
        __weak APFScreenshotView *link = self;
    
        dl.updateDownloadProgress = ^(float progress){
            dispatch_async(dispatch_get_main_queue(), ^{
                [link.progressView setProgress:progress animated:YES];
            });
        };

        dl.didFinishDownload = ^(NSData *data){
            link.imageData = data;
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            if(image==nil){
                NSLog(@"Error nil image!");
                return;
            }
            
            CGSize size = image.size;
            float ratio1 = (float)(FRAME_WIDTH) / image.size.width;
            float ratio2 = (float)(FRAME_HEIGHT) / image.size.height;
            
            float ratio = MIN(ratio1, ratio2);
            
            size.width *= ratio;
            size.height *= ratio;
            
            CGSize itemSize = size;
//            NSLog(@"%f %f %f %f %f %f %f %@", size.width, size.height, ratio, FRAME_WIDTH, FRAME_HEIGHT, image.size.width, image.size.height, image);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [image drawInRect:imageRect];
            //            [mask drawInRect:imageRect];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
                [link.progressView setHidden:YES];
                
                CGRect frame = link.imageView.frame;
                frame.size = size;
                frame.origin.x = (FRAME_WIDTH - frame.size.width)/2;
                frame.origin.y = (FRAME_HEIGHT - frame.size.height)/2;
                [link.imageView setFrame:frame];
                
                
                [link.imageView setImage:newImage];
            link.isReady = YES;
        };
        
        [dl start];
    
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!placeholder) {
            placeholder = [UIImage imageNamed:@"placeholder.png"];
        }
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        [self.imageView setImage:placeholder];
        [self addSubview:self.imageView];
        
        CGRect progressRect = frame;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            progressRect.origin.y = 140.0f+54;
            progressRect.origin.x = (230)/2;
            progressRect.size.width = 70;
        }else{
            progressRect.origin.y = 200.0f;
            progressRect.origin.x = (488)/2;
            progressRect.size.width = 150;
        }
        
        self.progressView = [[UIProgressView alloc] initWithFrame:progressRect];
        [self.progressView setProgressTintColor:[UIColor lightGrayColor]];
        [self.progressView setProgressViewStyle:UIProgressViewStyleBar];
        [self.progressView setProgress:0.0f];
        
        [self addSubview:self.progressView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
