//
//  APFAppDescriptionViewController.h
//  PROJECT
//
//  Created by PROJECT on 3/June/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APFAppDescription.h"
#import "APFAppEntry.h"
#import "APFPROJECTAPI.h"
#import "APFAppSignRequest.h"
#import "MWPhotoBrowser.h"
#import "GCPagedScrollView.h"
#import "APFLabel.h"
#import "HMSegmentedControl.h"



@interface APFAppDescriptionViewController : UIViewController <MWPhotoBrowserDelegate, APFAppSignRequestDelegate, APFPROJECTAPIDelegate, UIWebViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) UIViewController* parent;

@property (weak, nonatomic) IBOutlet UIView   *ApplicationDataBackground;
@property (weak, nonatomic) IBOutlet UIView *ApplicationBuyMessage;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationName;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationRelease;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationAdded;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationVersion;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationCategory;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationGlobalDownload;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationAFDownload;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationSize;
@property (weak, nonatomic) IBOutlet UILabel  *ApplicationDeveloper;
@property (weak, nonatomic) IBOutlet UILabel  *AppStorePrice;
@property (weak, nonatomic) IBOutlet UIImageView *ApplicationIcon;
@property (weak, nonatomic) IBOutlet UILabel *compatibilityInfo;
@property (weak, nonatomic) IBOutlet UIImageView  *compatibilityIcon;
@property (weak, nonatomic) IBOutlet HMSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIView  *detailsViews;
@property (weak, nonatomic) IBOutlet UIView  *scrollUIView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;

@property (weak, nonatomic) IBOutlet UIButton *progressView;
@property (strong, nonatomic) GCPagedScrollView* screenShotsScrollView;
@property (strong, nonatomic) NSMutableArray* pics;

@property (weak, nonatomic) IBOutlet UIScrollView  *iPhoneView;
@property (weak, nonatomic) IBOutlet UIView *appBuyMessageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appBuyMessageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vRuleWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hRuleHeight;

@property (strong, nonatomic) APFAppDescription *appDescription;
@property (strong, nonatomic) APFAppEntry *appEntry;
@property (weak, nonatomic) IBOutlet UIView *iconDownloadOverlay;

@property (weak, nonatomic) IBOutlet APFLabel *ApplicationAFDownloadsLabel;

@property (nonatomic, assign) BOOL isAppBuy;

@property (nonatomic, strong) NSString * userAction;
@property (weak, nonatomic) IBOutlet UIButton *installButton;

@end
