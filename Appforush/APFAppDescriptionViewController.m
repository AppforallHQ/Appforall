//
//  APFAppDescriptionViewController.m
//  PROJECT
//
//  Created by PROJECT on 3/June/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <sys/stat.h>
#import "APFAppDescriptionViewController.h"
#import "APFDownloader.h"
#import "APFPROJECTAPI.h"
#import "APFScreenshotView.h"
#import "APFFileDownloadInfo.h"
#import "SVProgressHUD.h"
#import "SDSegmentedControl.h"
#import "FFCircularProgressView.h"
#import "APFUserInfo.h"
#import <Analytics/Analytics.h>
#import <SDCAlertView/SDCAlertView.h>
//#import <Crashlytics/Crashlytics.h>
#import "PROJECT-Swift.h"

#define kAppIconSize 70

@interface APFAppDescriptionViewController () {
    BOOL screenshotset;
    BOOL descriptionDownloadFailed;
    BOOL viewAppeared;
}

@property (assign, nonatomic) BOOL descriptionSet;
@property (assign, nonatomic) BOOL shouldAutoScroll;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) FFCircularProgressView *circularProgressView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *similarAppsButton;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;


@property (nonatomic, strong) NSURL *docDirectoryURL;
@property (nonatomic) BOOL isInstalled;
@property (nonatomic) BOOL isUpdateAvailable;
@property (nonatomic) BOOL isDownloaded;

@property (nonatomic, strong) NSURL *documentDirectoryURL;
@property (nonatomic, strong) APFAppSignRequest *appSignRequest;
@property (assign, nonatomic) BOOL isPreviouslyDownloaded;
@property (assign, nonatomic) BOOL resetCache;
@property(nonatomic, strong) UITapGestureRecognizer *tapBehindRecognizer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localizedDescriptionHeight;
@property (weak, nonatomic) IBOutlet UIView *localizedDescriptionContainer;
@property (weak, nonatomic) IBOutlet UILabel *localizedDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *localizedDescriptionMoreButton;
@property (weak, nonatomic) IBOutlet UIImageView *localizedDescriptionMoreImage;
@property (weak, nonatomic) IBOutlet UIView *localizedDescriptionSeparator;

@property (weak, nonatomic) IBOutlet UIView * relatedApps;


@end

@implementation APFAppDescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"دانلود برنامه"];
    self.loadingView.hidden = false;
    self.iPhoneView.hidden = true;
    
    //[self.appBuyMessageViewHeightConstraint setConstant:0.0]; // We don't know if the app is free or not, so don't show it.
    descriptionDownloadFailed = false;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = CGSizeMake(500, 625);
    }
    
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.sectionTitles = @[@"برنامه‌های مرتبط",@"توضیحات",@"تصاویر"];
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName:     [UIColor colorWithWhite:174.0/255.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"IRANSans" size:11.5]
                                                  };
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.segmentedControl.selectionIndicatorHeight = 3.0;
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor userBlue]};
    self.segmentedControl.selectedSegmentIndex =2;
    
    //apfSwitch.addTarget(self, action: Selector("apfStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    [[self segmentedControl] addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
    
    
    self.localizedDescriptionSeparator.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.localizedDescriptionSeparator.layer.borderColor = [UIColor colorWithWhite:204.0/255 alpha:1.0].CGColor;
    self.localizedDescriptionSeparator.hidden = TRUE;
    
    self.vRuleWidth.constant = 1 / [UIScreen mainScreen].scale;
    self.hRuleHeight.constant = 1 / [UIScreen mainScreen].scale;
    self.automaticallyAdjustsScrollViewInsets = false;
    

    CGFloat cornerRadius = 12.0;
    self.ApplicationDataBackground.layer.borderColor = [UIColor colorWithWhite:0.84375 alpha:1.0].CGColor;
    self.ApplicationDataBackground.layer.borderWidth = 1;
    
    CALayer *imageLayer = self.ApplicationIcon.layer;
    imageLayer.cornerRadius = cornerRadius;
    imageLayer.masksToBounds = YES;
    self.ApplicationIcon.clipsToBounds = YES;
    
    self.screenShotsScrollView = [[GCPagedScrollView alloc] initWithFrame:self.scrollUIView.frame];
    self.screenShotsScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.scrollUIView addSubview:self.screenShotsScrollView];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideSelected:)];
    [gr setNumberOfTapsRequired:1];
    [self.screenShotsScrollView addGestureRecognizer:gr];
    
    [self.relatedApps setHidden:YES];
    [self.descriptionView setHidden:YES];
    [self.scrollUIView setHidden:NO];

    screenshotset = NO;
    self.descriptionSet = NO;
    self.shouldAutoScroll = YES;
    
    CALayer *cancelButtonlayer = [self.cancelButton layer];
    cancelButtonlayer.cornerRadius = 3;
    cancelButtonlayer.masksToBounds = YES;
    
    self.cancelButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.cancelButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.cancelButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    

    CALayer *installButtonlayer = [self.installButton layer];
    installButtonlayer.cornerRadius = 3;
    installButtonlayer.masksToBounds = YES;
    
    self.installButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.installButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.installButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    CALayer *buyButtonlayer = [self.buyButton layer];
    buyButtonlayer.cornerRadius = 3;
    buyButtonlayer.masksToBounds = YES;
    
    self.buyButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.buyButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.buyButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    
    
    CALayer *similarAppsButtonlayer = [self.similarAppsButton layer];
    similarAppsButtonlayer.cornerRadius = 5;
    similarAppsButtonlayer.masksToBounds = YES;
    
    
    
    self.resetCache = NO;
    [self updateDescription];
    
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.documentDirectoryURL = [URLs objectAtIndex:0];
   
    [APFPROJECTAPI currentInstance].PROJECTApiDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processInstallAndProgressUI)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) { // iPhone Specific Tasks
        UIBarButtonItem* actions = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
        
        NSArray* navigationItems = @[actions];
        self.navigationItem.rightBarButtonItems = navigationItems;
        
    } else {
        // TODO implement the same thing for iPad
    }
}

-(void)tapBehind:(UITapGestureRecognizer*)sender {
    if(sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:self.view.superview];
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.superview] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void) actionButtonClicked:(id)sender {
    UIActionSheet *actionsMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"انصراف" destructiveButtonTitle:nil otherButtonTitles:@"مشاهده در اپ‌استور", nil];
    
    actionsMenu.tag = 1;
    [actionsMenu showFromBarButtonItem:(UIBarButtonItem*)sender animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(actionSheet.tag) {
        case 1:
            switch (buttonIndex) {
                case 0:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/apple-store/id%@?mt=8", self.appEntry.applicationiTunesIdentification]]];
                    break;
                
                default:
                    break;
            }
            
            break;
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    float width = 320;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        width = 500;
    }
    else {
        width = [UIScreen mainScreen].bounds.size.width;
    }
    
    float height = 0;
    
    float y = self.detailsViews.frame.origin.y;
    float h = self.detailsViews.frame.size.height;
    height = y + h;
    
    [self.iPhoneView setContentSize:CGSizeMake(width, height)];
    [self.iPhoneView layoutIfNeeded];
    
    if(descriptionDownloadFailed) {
        [SVProgressHUD showErrorWithStatus:@"خطا در دریافت اطلاعات برنامه"];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [self dismissViewControllerAnimated:TRUE completion:nil];
        }
        else {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }
    else {
        __weak APFAppDescriptionViewController *selfWeak = self;
        
        self.appEntry.descriptionDownloadFailedHandler = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                descriptionDownloadFailed = TRUE;
                
                [SVProgressHUD showErrorWithStatus:@"خطا در دریافت اطلاعات برنامه"];
                
                if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    [selfWeak dismissViewControllerAnimated:TRUE completion:nil];
                }
                else {
                    [selfWeak.navigationController popViewControllerAnimated:TRUE];
                }
            });
        };
    }
    
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        
    }
    else {
        self.tapBehindRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehind:)];
        self.tapBehindRecognizer.delegate = self;
        [self.tapBehindRecognizer setNumberOfTapsRequired:1];
        self.tapBehindRecognizer.cancelsTouchesInView = false;
        [self.view.window addGestureRecognizer:self.tapBehindRecognizer];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    if (self.appSignRequest != nil) {
        self.appSignRequest.delegate = self;
    }
    
    [self processInstallAndProgressUI];
    [APFPROJECTAPI currentInstance].PROJECTApiDelegate = self;
}

-(void) viewWillDisappear:(BOOL)animated {
    self.appSignRequest.delegate = nil;
    
    [APFPROJECTAPI currentInstance].PROJECTApiDelegate = nil;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.presentingViewController viewDidAppear:YES];
        
        if(self.tapBehindRecognizer) {
            [self.view.window removeGestureRecognizer:self.tapBehindRecognizer];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) processInstallAndProgressUI {
    //Check for downloaded file
    
    if(!self.appDescription.applicationCopies || self.appDescription.applicationCopies.count == 0)
        return;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appId = [[self.appDescription.applicationCopies lastObject] objectForKey:@"lid"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *destinationPathDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/%@/", appId]];
    
    NSString *destinationPathFile = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];
    
    self.isPreviouslyDownloaded = [fileManager fileExistsAtPath:destinationPathFile];
    
    self.deleteButton.hidden = YES; //!self.isPreviouslyDownloaded;
    
    //Create progress UI
    [self.circularProgressView removeFromSuperview];
    self.circularProgressView = nil;

    float dimension = 44.0;
    CGPoint center = self.iconDownloadOverlay.center;
    CGRect bounds = CGRectMake(center.x - dimension / 2, center.y - dimension / 2, dimension, dimension);
    
    self.circularProgressView = [[FFCircularProgressView alloc] initWithFrame:bounds];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(handlePauseResume:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.circularProgressView addGestureRecognizer:tapGestureRecognizer];
    [self.iPhoneView addSubview:self.circularProgressView];
    
    self.isInstalled = false;
    self.isUpdateAvailable = false;
    self.isDownloaded = self.isPreviouslyDownloaded || [[APFPROJECTAPI currentInstance] isNotMerged:appId];
    
    
    
    if(self.isDownloaded)
    {
        [self.installButton setTitle:@"نصب برنامه" forState:UIControlStateNormal];
    }
    
    
    if([[APFPROJECTAPI currentInstance] isApplicationInstalled:self.appEntry.applicationiTunesIdentification])
    {
        [self.installButton setTitle:@"اجرای برنامه" forState:UIControlStateNormal];
        self.isInstalled = true;
    }
    
    for(APFAppEntry * app in [APFPROJECTAPI currentInstance].updatesList)
    {
        if ([app.applicationiTunesIdentification isEqualToString:self.appEntry.applicationiTunesIdentification])
        {
            self.isUpdateAvailable = true;
        }
    }
    
    if(self.isUpdateAvailable) // & self.isInstalled
    {
        self.isInstalled = false;
        [self.installButton setTitle:@"بروزرسانی برنامه" forState:UIControlStateNormal];
    }
    
    if(self.appDescription.isUniqueInPROJECT)
    {
        [self.buyButton setEnabled:false];
    }
    
    NSUInteger index = [self downloadQueueIndex];
    if (index != -1) {
        [self.installButton setHidden:YES];
        [self.deleteButton setHidden:YES];
        [self.cancelButton setHidden:NO];
        [self.circularProgressView setHidden:NO];
        [self.iconDownloadOverlay setHidden:NO];
        
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
        
        if (fileDownloadInfo.downloadTask != nil) {
            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
        }
        NSLog(@"PROCESSING UI! PROBLEM HERE %lu",(unsigned long)fileDownloadInfo.fileDownloadStatus);
        switch (fileDownloadInfo.fileDownloadStatus) {
            case APFFileDownloadInfoStatusInit:
                break;
            case APFFileDownloadInfoStatusDownloading: {
                self.circularProgressView.isPaused = NO;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                break;
            }
            case APFFileDownloadInfoStatusCompleted:
                break;
            case APFFileDownloadInfoStatusPaused:{
                self.circularProgressView.isPaused = YES;
                if (fileDownloadInfo.taskResumeData != nil)
                    [self.circularProgressView  setProgress:fileDownloadInfo.downloadProgress];
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                break;
            }
            case APFFileDownloadInfoStatusCancelled: {
                self.circularProgressView.isPaused = YES;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                break;
            }
            default:
                break;
        }
    } else {
        [self.installButton setHidden:NO];
        self.deleteButton.hidden = YES; //!self.isPreviouslyDownloaded;
        [self.cancelButton setHidden:YES];
        [self.circularProgressView setHidden:YES];
        [self.iconDownloadOverlay setHidden:YES];
    }
}


- (IBAction)confirmInstallation:(id)sender {
    
    if (self.isInstalled)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"useriid-%@://",self.appDescription.applicationiTunesIdentification]]];
        return;
    }
    else if(self.isDownloaded)
    {
        APFAppDelegate * delegate = [UIApplication sharedApplication].delegate;
        [delegate retainBackground];
        if(!self.appDescription.applicationCopies || self.appDescription.applicationCopies.count == 0)
            return;
        NSString *appId = [[self.appDescription.applicationCopies lastObject] objectForKey:@"lid"];
        
        if ([[APFPROJECTAPI currentInstance] isNotMerged:appId])
        {
            [SVProgressHUD showProgress:-1];
            [[APFPROJECTAPI currentInstance] mergeZipFilesWithAppId:appId];
            [SVProgressHUD dismiss];
        }
        
        
        NSString *manifestPath = [NSString stringWithFormat:MANIFEST_DOWNLOAD_PATH, appId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", manifestPath]]];
        return;
    }
    if (self.appDescription.applicationCopies == nil || [self.appDescription.applicationCopies count]==0) {
        SDCAlertView * alert = [[SDCAlertView alloc] initWithTitle:nil message:@"این برنامه در حال حاضر روی سرورهای اپفورال وجود ندارد. آیا مایل هستید هرچه‌ زودتر توسط تیم اپفورال اضافه شود؟" delegate:nil cancelButtonTitle:@"خیر"];
        
        [alert addButtonWithTitle:@"بلی"];
        [alert showWithDismissHandler:^(NSInteger buttonIndex){
            if(buttonIndex == 1)
            {
                [[APFPROJECTAPI currentInstance] proposeAppWithId:self.appEntry.applicationiTunesIdentification];
            }
        }];
    } else {
        NSString *appId = [[self.appDescription.applicationCopies lastObject] objectForKey:@"lid"];
        
        /*if ([self isNotMerged])
        {
            [SVProgressHUD show];
        }*/
        
        if (self.isPreviouslyDownloaded) {
           
            return;
            
        } else {
            [self startDownloadAndInstallWithAppId:appId];
        }
    }
}

- (void) startDownloadAndInstallWithAppId:(NSString *)appId {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSString *comp = self.appDescription.applicationCompatibility;
        if([comp isEqualToString:@"ipad"]){
            SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                              message:@"این برنامه مخصوص آیپد است و قابل نصب روی دستگاه شما نیست."
                                                             delegate:nil
                                                    cancelButtonTitle:@"تایید"
                                                    otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    NSString *minOS = self.appDescription.applicationMinOS;
    if (![minOS isKindOfClass:[NSNull class]] && minOS.length > 0) {
        NSLog(@"Min OS: %@", minOS);
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(minOS)) {
            SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                              message:[NSString stringWithFormat:@"این برنامه برای نصب نیاز به iOS %@ یا بیشتر دارد.", minOS]
                                                             delegate:nil
                                                    cancelButtonTitle:@"تایید"
                                                    otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    NSString *maxOS = self.appDescription.applicationMaxOS;
    if (![maxOS isKindOfClass:[NSNull class]] && maxOS.length > 0) {
        NSLog(@"Max OS: %@", maxOS);
        if (SYSTEM_VERSION_GREATER_THAN(maxOS)) {
            SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                              message:[NSString stringWithFormat:@"این برنامه قابل نصب بر روی دستگاههای با iOS بالاتر از %@ نیست.", maxOS]
                                                             delegate:nil
                                                    cancelButtonTitle:@"تایید"
                                                    otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    self.appSignRequest = [[APFPROJECTAPI currentInstance] requestDownloadForAppID:appId];
    self.appSignRequest.delegate = self; // TODO isn't it unsafe?
    
    [self.circularProgressView startSpinProgressBackgroundLayer];
    [self.installButton setHidden:NO];
    [self.installButton setEnabled:false];
    [self.deleteButton setHidden:YES];
    [self.circularProgressView setHidden:NO];
    [self.iconDownloadOverlay setHidden:NO];
    
    [[SEGAnalytics sharedAnalytics] track:@"send_request_to_download_an_app" properties:
         @{ @"Application Name": self.appDescription.applicationName,
            @"Category" : self.appDescription.applicationCategory,
            @"Version" : self.appDescription.applicationVersion}];
}

- (IBAction)cancelInstallation:(id)sender {
    NSUInteger index = [self downloadQueueIndex];
    if (index != -1) {
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
        
        [fileDownloadInfo.downloadTask cancel];
        fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusCancelled;
        [[APFPROJECTAPI currentInstance].fileDownloadDataArray removeObjectAtIndex:index];
        [self processInstallAndProgressUI];
    }
}

- (IBAction)similarApps:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    APFPadAppCollectionViewController *destination = (APFPadAppCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AppSearch"];
    
    
    destination.collectionType = AppCollectionTypeSimilarApps;
    
    
    destination.isAppBuy = self.isAppBuy;
    
    destination.title = @"اپ های مرتبط";
    
    destination.getAppEntriesObjC = ^(NSInteger page){
        return [[APFPROJECTAPI currentInstance] getSimilarApps:self.appEntry.applicationiTunesIdentification category:self.appEntry.applicationCategory];
    };
    
    NSLog(@"Amir : %@",[self parent]);
    [[self.parent navigationController] pushViewController:destination animated:true];
    
}


- (IBAction)deleteDownloadedFile:(id)sender {
    
    SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:nil
                                                      message:@"فایل دانلود شده حذف شود؟"
                                                     delegate:nil
                                            cancelButtonTitle:@"انصراف"
                                            otherButtonTitles:@"تایید", nil];
    [alert showWithDismissHandler:^(NSInteger buttonIndex) {
        NSLog(@"Buton %li", (long)buttonIndex);
        if (buttonIndex == 1) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *appId = [[self.appDescription.applicationCopies lastObject] objectForKey:@"lid"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths firstObject];
            NSString *destinationPathDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/%@/", appId]];
            NSString *destinationPathFile = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];
            
            self.isPreviouslyDownloaded = [fileManager fileExistsAtPath:destinationPathFile];
            
            NSError *error;
            
            if (![[NSFileManager defaultManager] removeItemAtPath:destinationPathFile error:&error]) {
                NSLog(@"Delete directory error: %@", error);
                [SVProgressHUD showErrorWithStatus:@"خطا در حذف فایل. لطفا دوباره اقدام نمایید"];
            } else {
                self.isPreviouslyDownloaded = NO;
                [self.deleteButton setHidden:YES];
                [SVProgressHUD showSuccessWithStatus:@"فایل مورد نظر حذف شد"];
            }
            
        }
    }];

}


-(void) performAction
{
    if(self.userAction!=nil && [self.userAction isEqualToString:@"Download"])
    {
        [self confirmInstallation:self];
    }
    else if(self.userAction!=nil && [self.userAction isEqualToString:@"Purchase"])
    {
        [self performSegueWithIdentifier:@"AppBuy" sender:self];
    }
}


-(void) updateDescription{
    if (!self.appDescription) {
        if(self.appEntry.applicationDescription){
            self.appDescription = self.appEntry.applicationDescription;
        }else{
            __weak APFAppDescriptionViewController *selfWeak = self;
            self.appEntry.descriptionDownloadedHandler = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selfWeak updateDescription];
                    [selfWeak processInstallAndProgressUI];
                    [((APFPadAppCollectionViewController *)[[selfWeak childViewControllers] lastObject]) addContentToAppList];
                    [selfWeak performAction];
                });
            };
            
            self.appEntry.descriptionDownloadFailedHandler = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    descriptionDownloadFailed = TRUE;
                });
            };
            
            [self.appEntry startDownloadDescriptionForAppBuy:self.isAppBuy];
            return;
        }
    } else {
        [[SEGAnalytics sharedAnalytics] track:@"Viewed App Profile Screen"
                                   properties:@{ @"Application Name": self.appDescription.applicationName,
                                                 @"Category": self.appDescription.applicationCategory }];
        
        self.loadingView.hidden = true;
        self.iPhoneView.hidden = false;
        [self.iPhoneView layoutIfNeeded];
        [self viewDidLayoutSubviews];
    }
    
    if(!self.descriptionSet){
        self.loadingView.hidden = true;
        self.iPhoneView.hidden = false;
        [self.iPhoneView layoutIfNeeded];
        [self viewDidLayoutSubviews];
        
        NSString *comp = self.appDescription.applicationCompatibility;
        //NSMutableString *compatInfo = [[NSMutableString alloc] init];
        
        if ([comp isEqualToString:@"iphone"]) {
            [self.compatibilityIcon setImage:[UIImage imageNamed:@"iphone.png"]];
            //[compatInfo appendString:@"مخصوص آی‌فون\n"];
        }else if([comp isEqualToString:@"ipad"]){
            [self.compatibilityIcon setImage:[UIImage imageNamed:@"ipad.png"]];
            //[compatInfo appendString:@"مخصوص آی‌پد\n"];
        }else{
            [self.compatibilityIcon setImage:[UIImage imageNamed:@"universal.png"]];
            //[compatInfo appendString:@"آی‌فون و آی‌پد\n"];
        }
        
        if(self.appDescription.applicationMinOS) {
            //[compatInfo appendString:[NSString stringWithFormat:@"iOS %@+", self.appDescription.applicationMinOS]];
        }
        
        [self.ApplicationName setText:self.appDescription.applicationName];
        //[self.ApplicationGlobalDownload setText:
        //    [NSString stringWithFormat:@"%u",[self.appDescription.applicationDownloads unsignedIntValue]]];
        [self.ApplicationAFDownload setText:
            [NSString stringWithFormat:@"%u",[self.appDescription.applicationAFDownloads unsignedIntValue]]];
        [self.ApplicationCategory setText:self.appDescription.applicationCategory];
        [self.ApplicationDeveloper setText:self.appDescription.applicationDeveloper];
        [self.ApplicationSize setText:[[[self.appDescription.applicationSize stringByReplacingOccurrencesOfString:@"MiB" withString:@"مگابایت"] stringByReplacingOccurrencesOfString:@"GiB" withString:@"گیگابایت"] stringByReplacingOccurrencesOfString:@"KiB" withString:@"کیلوبایت"]];
        [self.ApplicationVersion setText:self.appDescription.applicationVersion];
        [self.descriptionView setText:self.appDescription.applicationDescriptionString];
        //[self.compatibilityInfo setText:compatInfo];
        self.AppStorePrice.text = self.appDescription.applicationPrice;
        if (self.appDescription.applicationPrice==nil) {
            self.AppStorePrice.text = @"نامعلوم";
        }
        else if([[self.appDescription.applicationPrice lowercaseString] isEqualToString:@"free"]) {
            [self.buyButton setTitle:@"دریافت از اپ‌استور" forState:UIControlStateNormal];
            [self.AppStorePrice setText:@"رایگان"];
            // TODO uncomment on MyApp release
            //[self.appBuyMessageViewHeightConstraint setConstant:0.0];
            [self viewDidLayoutSubviews];
        }
        else {
            [self.AppStorePrice setText:[[self.appDescription.applicationPrice stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByAppendingString:@" دلار"]];
            // TODO uncomment on MyApp release
            //[self.appBuyMessageViewHeightConstraint setConstant:38.0];
            [self viewDidLayoutSubviews];
        }
        
//      [self.appBuyMessageViewHeightConstraint setConstant:0.0];
        //[self viewDidLayoutSubviews];
        
        self.descriptionView.frame = self.descriptionView.frame;
        //self.descriptionView.textContainerInset = UIEdgeInsetsMake(20, 15, 20, 15);
        //[self.installButton setHidden:NO];
        
        if(self.appDescription.applicationLocalizedDescription) {
            self.localizedDescriptionLabel.text = self.appDescription.applicationLocalizedDescription;
            [self.localizedDescriptionLabel sizeToFit];
            
            CGFloat neededHeight = self.localizedDescriptionLabel.frame.origin.y + self.localizedDescriptionLabel.frame.size.height + 19.0;
            
            if(neededHeight <= 250) {
                self.localizedDescriptionMoreButton.hidden = YES;
                self.localizedDescriptionMoreImage.hidden = YES;
                self.localizedDescriptionSeparator.hidden = NO;
                self.localizedDescriptionHeight.constant = neededHeight;
            }
            else {
                
            }
            
        }
        else {
            self.localizedDescriptionHeight.constant = 0.0;
        }
        
        if(!self.appDescription.applicationCopies || self.appDescription.applicationCopies.count == 0) {
            //self.installButton.hidden = true;
            [self.installButton setTitle:@"پیشنهاد افزودن به اپفورال" forState:UIControlStateNormal];
        }
        
        [self viewDidLayoutSubviews];
        
        [self.ApplicationRelease setText:self.appDescription.applicationReleaseDateString];
        [self.ApplicationAdded setText:self.appDescription.applicationAddedDateString];
        
        //if(true && self.isAppBuy) {
        [self.ApplicationAFDownloadsLabel setText:@"سازنده:"];
        [self.ApplicationAFDownload setText:self.appDescription.applicationDeveloper];
        //}
        
        self.descriptionSet = YES;
    }
    
    if (self.appDescription.applicationLargeIcon != nil) {
        [self.ApplicationIcon setImage:self.appDescription.applicationLargeIcon];
    }
    else {
        [self.ApplicationIcon setImage:[UIImage imageNamed:@"noIconForApps"]];
        
        NSNumber *liftime = (self.resetCache == YES ? [NSNumber numberWithInt:0] : [NSNumber numberWithDouble:30*24*3600]);
        APFDownloader *dl = [[APFDownloader alloc] initWithDownloadURLString:self.appDescription.applicationLargeIconURL withLifeTime:liftime];
        
        __weak APFAppDescription *app  = self.appDescription;
        __weak APFAppDescriptionViewController *apdvu = self;
        
        dl.didFinishDownload = ^(NSData* data){
            UIImage *image = [[UIImage alloc] initWithData:data];
            image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            
            if (image == nil) {
                self.resetCache = YES;
            } else {
                self.resetCache = NO;
                app.applicationLargeIcon = image;
            }
            
            [apdvu performSelector:@selector(updateDescription) onThread:[NSThread mainThread] withObject:Nil waitUntilDone:NO];
        };
        
        [dl start];
    }
    
    if(!screenshotset){
        [self.screenShotsScrollView removeAllContentSubviews];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (![self handleiPhoneScreenshots]) {
                [self handleiPadScreenshots];
            }
        }else{
            if(![self handleiPadScreenshots]){
                [self handleiPhoneScreenshots];
            }
        }
        screenshotset = YES;
    }
}

- (IBAction)expandLocalizedDescription:(id)sender {
    [self.view layoutIfNeeded];
    self.localizedDescriptionHeight.constant = self.localizedDescriptionLabel.frame.origin.y + self.localizedDescriptionLabel.frame.size.height + 19.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
        self.localizedDescriptionMoreButton.hidden = true;
        self.localizedDescriptionMoreImage.hidden = true;
        self.localizedDescriptionSeparator.hidden = false;
    } completion:nil];
    
    // upading content size
    CGSize contentSize = self.iPhoneView.contentSize;
    contentSize.height = self.detailsViews.frame.origin.y + self.detailsViews.frame.size.height;
    self.iPhoneView.contentSize = contentSize;
}

-(BOOL) handleiPhoneScreenshots{
    if ([self.appDescription.applicationBigScreenshots isKindOfClass:[NSArray class]]) {
        for (NSString *icon in self.appDescription.applicationBigScreenshots) {
            APFScreenshotView *screenShotView = [[APFScreenshotView alloc] initWithImageURLString:icon];
            screenShotView.scrollView = self.screenShotsScrollView;
            [self.screenShotsScrollView addContentSubview:screenShotView];
        }
        if ([self.appDescription.applicationBigScreenshots count]>0) {
            return YES;
        }
    }else{
    }
    return NO;
}

-(BOOL) handleiPadScreenshots{
    if ([self.appDescription.applicationiPadBigScreenshots isKindOfClass:[NSArray class]]) {
        for (NSString *icon in self.appDescription.applicationiPadBigScreenshots) {
            APFScreenshotView *screenShotView = [[APFScreenshotView alloc] initWithImageURLString:icon];
            screenShotView.scrollView = self.screenShotsScrollView;
            [self.screenShotsScrollView addContentSubview:screenShotView];
        }
        if ([self.appDescription.applicationiPadBigScreenshots count]>0) {
            return YES;
        }
    }else{
    }
    return NO;
}

- (IBAction) segmentDidSelect:(id)sender{
    if(self.iPhoneView) {
        [self viewDidLayoutSubviews];
        CGPoint bottomOffset = CGPointMake(0, self.iPhoneView.contentSize.height - self.iPhoneView.bounds.size.height);
        [self.iPhoneView setContentOffset:bottomOffset animated:YES];
    }
}

- (IBAction)segmentDidChange:(id)sender{
    [self segmentDidSelect:sender];
    
    if ([self.segmentedControl selectedSegmentIndex]==2) {
        [self.descriptionView setHidden:YES];
        [self.scrollUIView setHidden:NO];
        [self.relatedApps setHidden:YES];
    }else if([self.segmentedControl selectedSegmentIndex]==1){
        [self.descriptionView setHidden:NO];
        [self.scrollUIView setHidden:YES];
        [self.relatedApps setHidden:YES];
    }
    else{
        [self.descriptionView setHidden:YES];
        [self.scrollUIView setHidden:YES];
        [self.relatedApps setHidden:NO];
    }
}

- (void) slideSelected:(id)sender{
    //    NSLog(@"OK :D");
    
    self.pics = [NSMutableArray array];
    NSArray* screenshots =[self.screenShotsScrollView contentViews];
    if ((screenshots == nil) || (screenshots.count == 0) || !((APFScreenshotView*)[screenshots objectAtIndex:self.screenShotsScrollView.page]).isReady) {
        return;
    }
    for (APFScreenshotView *svu in screenshots) {
        if (svu.isReady) {
            [self.pics addObject:[MWPhoto photoWithImage:[UIImage imageWithData:svu.imageData]]];
        }else{
            [self.pics addObject:[MWPhoto photoWithURL:[NSURL URLWithString:svu.imageURL]]];
        }
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.edgesForExtendedLayout = UIRectEdgeAll;
    // TODO Fix this.
    browser.displayActionButton = NO;
    
    [browser setCurrentPhotoIndex:self.screenShotsScrollView.page];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [self.navigationController pushViewController:browser animated:YES];
    } else{
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
//        nc.popoverPresentationController.sourceView = self.view;
//        self.popoverPresentationController.sourceView = self.view;
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.pics.count;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    return [self.pics objectAtIndex:index];
}

- (void)viewDidLayoutSubviews {
    float width = 320;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        width = 500;
    }
    else {
        width = [UIScreen mainScreen].bounds.size.width;
    }
    
    float height = 0;
    
    float y = self.detailsViews.frame.origin.y;
    float h = self.detailsViews.frame.size.height;
    height = y + h;
    
    [self.iPhoneView setContentSize:CGSizeMake(width, height)];
    //////////////////////////////////////////////////////////////////////////////////
    /*CALayer *borderTop = [[CALayer alloc] init];
    borderTop.backgroundColor = [UIColor colorWithRed:27.0/255 green:197.0/255 blue:27.0/255 alpha:1.0].CGColor;
    borderTop.frame = CGRectMake(0, 0, self.ApplicationBuyMessage.bounds.size.width, 0.5);
    
    CALayer *borderBottom = [[CALayer alloc] init];
    borderBottom.backgroundColor = [UIColor colorWithRed:27.0/255 green:197.0/255 blue:27.0/255 alpha:1.0].CGColor;
    borderBottom.frame = CGRectMake(0, self.ApplicationBuyMessage.bounds.size.height - 0.5, self.ApplicationBuyMessage.bounds.size.width, 0.5);
    
    [self.ApplicationBuyMessage.layer addSublayer:borderTop];
    [self.ApplicationBuyMessage.layer addSublayer:borderBottom];*/
    
    [super viewDidLayoutSubviews];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.view.superview.bounds = CGRectMake(0, 0, 500, 625);
        self.view.superview.layer.cornerRadius = 6.0;
        self.view.superview.layer.masksToBounds = true;
    }
}

-(int) downloadQueueIndex {
    int index = -1;
    NSString *appId = [[self.appDescription.applicationCopies lastObject] objectForKey:@"lid"];
    for (int i=0; i<[[APFPROJECTAPI currentInstance].fileDownloadDataArray count]; i++) {
        APFFileDownloadInfo *fdi = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:i];
        if ([fdi.appId isEqualToString:appId]) {
            index = i;
            break;
        }
    }
    
    return index;
}

-(void) didDownloadProgressForAppId:(NSString *)appId withProgress:(double)progress {
    NSLog(@"Progress: %f", progress);
    
    [self.circularProgressView stopSpinProgressBackgroundLayer];
    [self.circularProgressView setProgress:progress];
    //[self.circularProgressView setNeedsDisplay];
    //[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
}

- (void) didDownloadFail {
    self.circularProgressView.isPaused = YES;
    [self.circularProgressView setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
}

- (void) checkForInstallation
{
    if ([[APFPROJECTAPI currentInstance] isApplicationInstalled:self.appEntry.applicationiTunesIdentification])
    {
        [self.installButton setEnabled:true];
        self.isInstalled = true;
        [self.installButton setTitle:@"اجرای برنامه" forState:UIControlStateNormal];
    }
}

- (void) didDownloadFinish {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self processInstallAndProgressUI];
        [self.installButton setEnabled:NO];
        [self.installButton setTitle:@"در حال نصب..." forState:UIControlStateDisabled];
        [self.deleteButton setHidden:YES];
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(checkForInstallation)
                                       userInfo:nil
                                        repeats:YES];
    });
}

- (IBAction)handlePauseResume:(UITapGestureRecognizer *)tapRecognizer {

    NSUInteger index = [self downloadQueueIndex];
    if (index != -1) {
        APFFileDownloadInfo *fileDownloadInfo = [[APFPROJECTAPI currentInstance].fileDownloadDataArray objectAtIndex:index];
    
        if (fileDownloadInfo.downloadTask != nil) {
            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
        }
        
        NSString *stateString;
        NSLog(@"HANDLE PAUSE RESUME STATE : %d",fileDownloadInfo.fileDownloadStatus);
        switch (fileDownloadInfo.fileDownloadStatus) {
            case APFFileDownloadInfoStatusInit:
                stateString = @"Ready";
                break;
            case APFFileDownloadInfoStatusDownloading: {
                stateString = @"Downloading";
                NSLog(@"Downloading!!!!!!!!! %llu", fileDownloadInfo.downloadedBytes);
                [fileDownloadInfo.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                    if (resumeData != nil) {
                        fileDownloadInfo.taskResumeData = [[NSData alloc] initWithData:resumeData];
                        fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                    }
                }];
                
                self.circularProgressView.isPaused = YES;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusPaused;
                break;
            }
            case APFFileDownloadInfoStatusCompleted:
                stateString = @"Done";
                break;
            case APFFileDownloadInfoStatusPaused:{
                stateString = @"Cancelled";
                self.circularProgressView.isPaused = NO;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                
                fileDownloadInfo.downloadTask = [[APFPROJECTAPI currentInstance].session downloadTaskWithResumeData:fileDownloadInfo.taskResumeData];
                fileDownloadInfo.taskIdentifier = fileDownloadInfo.downloadTask.taskIdentifier;
                fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                [fileDownloadInfo.downloadTask resume];
                fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusDownloading;
                break;
            }
            case APFFileDownloadInfoStatusCancelled: {
                stateString = @"Failed";
                
                self.circularProgressView.isPaused = NO;
                [self.circularProgressView setNeedsDisplay];
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                [fileDownloadInfo.downloadTask cancel];
                fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                break;
            }
            default:
                break;
        }
    }

}

-(void) didFetchDownloadAppUrl:(id)sender {
    NSString *appID = [[self.appDescription.applicationCopies lastObject] objectForKey:@"lid"];
    APFAppSignRequest *signRequest = (APFAppSignRequest *)sender;
    
    NSString *downloadUrl = signRequest.downloadAppUrl;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destinationPathDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/%@/temp/", appID]];
    
    if (![fileManager fileExistsAtPath:destinationPathDirectory]) {
        [fileManager createDirectoryAtPath:destinationPathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *downloadPath;
    NSString *downloadExtraPath;
    
    APFFileDownloadInfo *fileDownloadInfo = [[APFFileDownloadInfo alloc] initWithFileAppId:appID
                                                                               andiTunesId:self.appDescription.applicationiTunesIdentification
                                                                                andAppName:self.appDescription.applicationName
                                                                            andAppCategory:self.appDescription.applicationCategory
                                                                             andAppVersion:self.appDescription.applicationVersion
                                                                         andDownloadSource:downloadUrl andAppIcon:self.appEntry.applicationIconURL];
    
    if(signRequest.twoStage) {
        fileDownloadInfo.twoStage = true;
        fileDownloadInfo.currentStage = 1;
        fileDownloadInfo.downloadExtraSource = signRequest.downloadExtraUrl;
        
        downloadPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.raw"];
        downloadExtraPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.patch"];
        NSString* finalPackageFilePath = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];
        
        if([fileManager fileExistsAtPath:downloadExtraPath isDirectory:false]) {
            [fileManager removeItemAtPath:downloadExtraPath error:nil];
        }
        
        if([fileManager fileExistsAtPath:finalPackageFilePath isDirectory:false]) {
            [fileManager removeItemAtPath:finalPackageFilePath error:nil];
        }
        
        fileDownloadInfo.downloadExtraPath = downloadExtraPath;
    }
    else {
        fileDownloadInfo.twoStage = false;
        downloadPath = [destinationPathDirectory stringByAppendingPathComponent:@"program.ipa"];
    }
    
    if([fileManager fileExistsAtPath:downloadPath isDirectory:false]) {
        [fileManager removeItemAtPath:downloadPath error:nil];
    }
    
    fileDownloadInfo.appEntry = self.appEntry;
    fileDownloadInfo.downloadTask = [[APFPROJECTAPI currentInstance].session downloadTaskWithURL:[NSURL URLWithString:downloadUrl]];
    fileDownloadInfo.taskIdentifier = fileDownloadInfo.downloadTask.taskIdentifier;
    
    

    //NSLog(@"FileName: %@", fileDownloadInfo.downloadTask.fileName);
    //NSLog(@"Directory: %@", fileDownloadInfo.downloadTask.pathToDownloadDirectory);
    
    NSURL *URL = [NSURL URLWithString:downloadUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"HEAD"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        long long size = [response expectedContentLength];
        
        if(!fileDownloadInfo.twoStage) {
            fileDownloadInfo.totalFileLength = size;

            NSLog(@"Total File Size: %llu", fileDownloadInfo.totalFileLength);
            
            [self.installButton setHidden:YES];
            [self.installButton setEnabled:YES];
            [self.cancelButton setHidden:NO];
            
            [fileDownloadInfo.downloadTask resume];
            fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
            fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusDownloading;
            [[APFPROJECTAPI currentInstance].fileDownloadDataArray addObject:fileDownloadInfo];
        }
        else {
            NSMutableURLRequest *requestExtra = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileDownloadInfo.downloadExtraSource]];
            [requestExtra setHTTPMethod:@"HEAD"];
            
            [NSURLConnection sendAsynchronousRequest:requestExtra queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                fileDownloadInfo.totalFileLength = size + [response expectedContentLength];
                
                [self.installButton setHidden:YES];
                [self.installButton setEnabled:YES];
                [self.cancelButton setHidden:NO];
                
                
                [fileDownloadInfo.downloadTask resume];
                fileDownloadInfo.fileDownloadStatus = APFFileDownloadInfoStatusDownloading;
                fileDownloadInfo.state = fileDownloadInfo.downloadTask.state;
                [[APFPROJECTAPI currentInstance].fileDownloadDataArray addObject:fileDownloadInfo];
            }];
        }
    }];
}

- (void) failedDownloadAppUrl:(id)sender {
    self.circularProgressView.isPaused = NO;
    [self.circularProgressView setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    [self.circularProgressView setHidden:YES];
    [self.iconDownloadOverlay setHidden:YES];
    [self.installButton setHidden:NO];
    [self.installButton setEnabled:YES];
}

#pragma mark - iPad version chat

//- (IBAction)startChat:(id)sender {
//    if ([APFPROJECTAPI currentInstance].chatURL == nil) {
//        [SVProgressHUD showErrorWithStatus:@"خطا در برقراری ارتباط با پشتیبانی"];
//        return;
//    }
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [self.navigationController pushViewController:self.chatViewController animated:YES];
//    } else {
//        NSURL *url = [NSURL URLWithString:[APFPROJECTAPI currentInstance].chatURL];
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//        [self.chatView loadRequest:request];
//        self.chatModalView = [[RNBlurModalView alloc] initWithParentView:self.parentViewController.view view:self.chatView];
//        [SVProgressHUD showWithStatus:@"برقراری ارتباط با پشتیبانی..." maskType:SVProgressHUDMaskTypeBlack];
//        
//        [self.chatView setAlpha:1.0];
//        [self.view setAlpha:0.0];
//        [self.chatModalView showWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:^{
//            
//        }];
//    }
//    
//}
//
//- (void) chatModalDidHide {
//    
//    void (^showDescriptionView)(void) = ^(void) {
//        [self.chatView setAlpha:0.0];
//        [self.view setAlpha:1.0];
//    };
//    
//    [UIView animateWithDuration:0.5
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:showDescriptionView
//                     completion:nil];
//}

-(void)viewDidDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"AppBuy"]) {
        APFAppBuyViewController *destination = [segue destinationViewController];
        destination.iTunesID = self.appEntry.applicationiTunesIdentification;
        destination.hidesBottomBarWhenPushed = true;
    }

    if([[segue identifier] isEqualToString:@"RelatedAppsEmbed"]) {
        APFPadAppCollectionViewController *destination = [segue destinationViewController];
        
        destination.collectionType = AppCollectionTypeSimilarApps;
        
        NSLog(@"WAAF");
        
        destination.isAppBuy = self.isAppBuy;
        
        destination.title = @"اپ های مرتبط";
        
        destination.getAppEntriesObjC = ^(NSInteger page){
            return [[APFPROJECTAPI currentInstance] getRecommendedApps:self.appDescription.recommended];
        };
        [destination.collectionView setBackgroundColor:(__bridge CGColorRef _Nullable)(self.view.backgroundColor)];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
