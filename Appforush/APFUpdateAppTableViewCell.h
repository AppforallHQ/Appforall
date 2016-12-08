//
//  APFUpdateAppTableViewCell.h
//  PROJECT
//
//  Created by Nima Azimi on 12/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APFPROJECTAPI.h"
#import <SWTableViewCell.h>

@interface APFUpdateAppTableViewCell : SWTableViewCell <APFPROJECTAPIDelegate, APFAppSignRequestDelegate>

@property (nonatomic, strong) IBOutlet UILabel *cellItemLabel;
@property (nonatomic, strong) IBOutlet UIImageView *cellItemImageView;
@property (nonatomic, strong) IBOutlet UILabel *cellDetailsLabel;
@property (nonatomic, strong) IBOutlet UILabel *cellDetailSize;
@property (nonatomic, strong) IBOutlet UILabel *cellDetailDownloads;
@property (weak, nonatomic) IBOutlet UILabel *cellDetailDownloadsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDetailSizeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseNote;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellInfoIcon;

@property (weak, nonatomic, readwrite) IBOutlet UIButton *installButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appiTunesId;
@property (nonatomic, strong) NSString *appIconUrl;

@property (weak, nonatomic) IBOutlet UIView *iconDownloadOverlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellHRuleConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *cellHRule;

- (void) processInstallAndProgressUI;
- (void) pauseDownload;

@end
