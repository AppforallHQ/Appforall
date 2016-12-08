//
//  APFWelcomeViewController.m
//  PROJECT
//
//  Created by Nima Azimi on 12/June/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "APFWelcomeViewController.h"
#import "APFPROJECTAPI.h"
#import "LazyFadeInView.h"
#import <SDCAlertView/SDCAlertView.h>
#import <SSKeychain/SSKeychain.h>
#import "PROJECT-Swift.h"

@interface APFWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;
@property (assign, nonatomic) BOOL isDownloadCompleted;
@property (strong, nonatomic) NSString* welcomeMessage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UILabel *clickMessage;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameHRuleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordHRuleHeightConstraint;

@end

#define REGISTER_URL @"https://REGISTER_URL"
#define PASSWORD_RESET_URL @"https://PASSWORD_RESET_URL"

@implementation APFWelcomeViewController


-(void) PROJECTAPILoadingWasCompleted:(id)sender withState:(APFLoginState)state {
    if(state == APFLoginStateInvalidUsernameOrPassword) {
        SDCAlertView* alert = [[SDCAlertView alloc] initWithTitle:@"خطا در ورود" message:@"نام کاربری یا رمز عبور وارد شده معتبر نمی‌باشد." delegate:nil cancelButtonTitle:@"تایید"];
        
        self.loginView.hidden = false;
        self.sloganLabel.hidden = true;
        
        [alert show];
        return;
    }
    else {
        
    }
    
    APFPROJECTAPI *PROJECTAPI = sender;
    NSString *userFirstName = PROJECTAPI.userFirstName;
    self.availableUpdatesCount = PROJECTAPI.availableUpdatesCount;
    
    if (userFirstName != nil) {
        self.welcomeMessage = [NSString stringWithFormat:@"سلام، %@ :)\nبه اپفورال خوش آمدی!", userFirstName];
    }
    else {
        self.welcomeMessage = @"سلام :)\nبه اپفورال خوش آمدی!";
    }
    
    self.isDownloadCompleted = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
}

-(void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHid:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void) unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void) keyboardWasHid:(NSNotification*)aNotification {
    NSDictionary* info = aNotification.userInfo;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] doubleValue]];
    [UIView setAnimationBeginsFromCurrentState:true];
    
    self.backgroundViewBottomConstraint.constant = 0.0;
    self.loginViewBottomConstraint.constant = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 25.0 : 50.0;
    [self.backgroundView layoutIfNeeded];
    [self.loginView layoutIfNeeded];
    
    [UIView commitAnimations];
}

-(void) keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = aNotification.userInfo;
    CGFloat kbdHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat deviceHeight = [UIScreen mainScreen].bounds.size.height;
//    self.backgroundViewBottomConstraint.constant = kbdHeight;
//    self.loginViewBottomConstraint.constant = kbdHeight;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] doubleValue]];
    [UIView setAnimationBeginsFromCurrentState:true];
    
    self.backgroundViewBottomConstraint.constant = kbdHeight;
    //self.loginViewBottomConstraint.constant = kbdHeight + (deviceHeight - kbdHeight) / 2 - self.loginView.bounds.size.height / 2;
    self.loginViewBottomConstraint.constant = kbdHeight + (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 25.0 : 50.0);
    
    [self.backgroundView layoutIfNeeded];
    [self.loginView layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (IBAction)loginTextFieldChanged:(id)sender {
    if([self.usernameTextField.text length] == 0 || [self.passwordTextField.text length] == 0) {
        self.loginButton.enabled = false;
    }
    else {
        self.loginButton.enabled = true;
    }
    
    if([self.usernameTextField.text length] == 0) {
        self.emailLabel.hidden = false;
    }
    else {
        self.emailLabel.hidden = true;
    }
    
    if([self.passwordTextField.text length] == 0) {
        self.passwordLabel.hidden = false;
    }
    else {
        self.passwordLabel.hidden = true;
    }
}

- (IBAction)doLogin:(id)sender {
    if([self.usernameTextField.text length] == 0 || [self.passwordTextField.text length] == 0) {
        return;
    }
    
    [self.usernameTextField endEditing:true];
    [self.passwordTextField endEditing:true];
    
    self.loginView.hidden = true;
    self.sloganLabel.hidden = false;
    
    [[APFPROJECTAPI currentInstance] loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
}

- (IBAction)registerButtonClicked:(id)sender {
    [self.usernameTextField setText:@""];
    [self.passwordTextField setText:@""];
    APFRegisterViewController *viewController = (APFRegisterViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
    
    [viewController setParent:self];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window.rootViewController presentViewController:viewController animated:true completion:nil];
}

- (IBAction)forgotPasswordButtonClicked:(id)sender {
    [self.usernameTextField setText:@""];
    [self.passwordTextField setText:@""];
    APFForgotPasswordViewController *viewController = (APFForgotPasswordViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPassword"];
    
    [viewController setParent:self];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window.rootViewController presentViewController:viewController animated:true completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"VIEW DID LOAD");
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    [APFPROJECTAPI currentInstance].PROJECTApiDelegate = self;
    
    //NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    //NSString *version = infoDictionary[(NSString*)kCFBundleVersionKey];
    //self.versionLabel.text = [NSString stringWithFormat:@"Version %@", version];
    
    self.isDownloadCompleted = NO;
    
    self.sloganLabel.alpha = 0;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        if(fabs((double)height - (double)568.0) < DBL_EPSILON) { // iPhone 5/5C/5S
            self.backgroundView.image = [UIImage imageNamed:@"LaunchImage-700-568h@2x.png"];
        }
        else if(fabs((double)height - (double)667.0) < DBL_EPSILON) { // iPhone 6
            self.backgroundView.image = [UIImage imageNamed:@"LaunchImage-800-667h@2x.png"];
        }
        else if(fabs((double)height - (double)736.0) < DBL_EPSILON) { // iPhone 6+
            self.backgroundView.image = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h@3x.png"];
        }
        else { // iPhone 4S
            self.backgroundView.image = [UIImage imageNamed:@"LaunchImage-700@2x.png"];
        }
    }
}



-(void) didRegisterSuccessful
{
    [[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController]
     dismissViewControllerAnimated:false completion:^{
         APFRegisterDoneViewController *viewController = (APFRegisterDoneViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RegisterDone"];
         
         [viewController setParent:self];
         
         UIWindow *window = [[UIApplication sharedApplication] keyWindow];
         [window.rootViewController presentViewController:viewController animated:true completion:nil];
     }];
}


-(void) viewWillAppear:(BOOL)animated {
    [self animateSloganIn];
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        recognizer.enabled = true;
    }
    
    if ([APFPROJECTAPI currentInstance].compulsaryUpdate)
    {
        self.sloganLabel.hidden = false;
        self.clickMessage.hidden = true;
        self.loginView.hidden = true;
        self.sloganLabel.text = @"نامحدود دانلود کنید...";
        [APFPROJECTAPI currentInstance].PROJECTApiDelegate = self;
        self.isDownloadCompleted = NO;
        self.sloganLabel.alpha = 0;
        if([APFPROJECTAPI currentInstance].version == APFVersionBasic)
        {
            NSString* appID = [[NSBundle mainBundle] bundleIdentifier];
            NSString *username = [SSKeychain passwordForService:appID account:@"basicUsername"];
            NSString *password = [SSKeychain passwordForService:appID account:@"basicPassword"];
            [[APFPROJECTAPI currentInstance] loginWithUsername:username password:password];
        }
        else
        {
            [[APFPROJECTAPI currentInstance] login];
        }
        [APFPROJECTAPI currentInstance].compulsaryUpdate = NO;
        return;
    }
    
    if([APFPROJECTAPI currentInstance].version == APFVersionBasic) {
        NSString* appID = [[NSBundle mainBundle] bundleIdentifier];
        
        NSString *username = [SSKeychain passwordForService:appID account:@"basicUsername"];
        NSString *password = [SSKeychain passwordForService:appID account:@"basicPassword"];
        
        if([username length] > 0 && [password length] > 0) {
            self.loginView.hidden = true;
            self.sloganLabel.hidden = false;
            self.clickMessage.hidden = true;
            
            [[APFPROJECTAPI currentInstance] loginWithUsername:username password:password];
        }
        else {
            self.loginView.hidden = false;
            self.sloganLabel.hidden = true;
            self.clickMessage.hidden = true;
            
            self.loginButton.layer.cornerRadius = 4.0;
            self.registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.registerButton.layer.borderWidth = 1.5;
            self.registerButton.layer.cornerRadius = 4.0;
            
            self.usernameTextField.tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            self.passwordTextField.tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            
            self.usernameHRuleHeightConstraint.constant = 1 / [UIScreen mainScreen].scale;
            self.passwordHRuleHeightConstraint.constant = 1 / [UIScreen mainScreen].scale;
        }
    }
    else {
        self.loginView.hidden = true;
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self registerForKeyboardNotifications];
}

-(void) viewDidDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
}

-(void)animateSloganOut {
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.sloganLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(self.isDownloadCompleted) {
            self.sloganLabel.text = self.welcomeMessage;
            [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.sloganLabel.alpha = 1.0;
                self.clickMessage.alpha = 0.5;
            } completion:nil];
        }
        else {
            [self animateSloganIn];
        }
    }];
}

-(void)animateSloganIn {
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.sloganLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self animateSloganOut];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)tapToDismissView:(id)sender {
    if(!self.isDownloadCompleted) {
        //[self.usernameTextField endEditing:true];
        //[self.passwordTextField endEditing:true];
        return;
    }
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        recognizer.enabled = false;
    }
    
    NSString* introKey = @"myapp-intro-2";
    
    BOOL alreadySeen = [[NSUserDefaults standardUserDefaults] boolForKey:introKey];
    
    if(alreadySeen) {
        [self dismissWelcomeScreen];
        return;
    }
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"نامحدود دانلود کنید!";
    page1.desc = @"با داشتن اشتراک اپفورال، به صورت نامحدود به ۱۳۰۰۰ برنامه‌ی محبوب iOS دسترسی خواهید داشت.";
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyAppSlide01"]];
    page1.bgColor = [UIColor colorWithRed:6.0/255 green:113.0/255 blue:212.0/255 alpha:1.0];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"خرید ریالی برنامه از اپ‌استور";
    page2.desc = @"برنامه‌های موجود در اپ‌استور آمریکا را با پرداخت ریالی و توسط اپل‌آیدی خودتان بخرید.";
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyAppSlide02"]];
    page2.bgColor = [UIColor colorWithRed:90.0/255 green:175.0/255 blue:100.0/255 alpha:1.0];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"جستجو در برنامه‌های اپ‌استور";
    page3.desc = @"برنامه دلخواهتان را از بین تمام برنامه های اپ‌استور به آسانی جستجو کنید.";
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyAppSlide03"]];
    page3.bgColor = [UIColor colorWithRed:154.0/255 green:90.0/255 blue:175.0/255 alpha:1.0];
    
    NSArray* pages = @[page1, page2, page3];
    
    for (EAIntroPage* page in pages) {
        page.titleColor = [UIColor whiteColor];
        page.descColor = [UIColor whiteColor];
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            page.titleFont = [UIFont fontWithName:@"IRANSans-Bold" size:14.0];
            page.descFont = [UIFont fontWithName:@"IRANSans" size:12.0];
            page.descWidth = [UIScreen mainScreen].bounds.size.width - 45.0;
            
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            
            if(fabs((double)height - (double)480.0) < DBL_EPSILON) { // iPhone 4S
                page.titleIconPositionY = 25.0;
                page.titleIconView.frame = CGRectMake(0, 0, 275, 275);
            }
            else if(fabs((double)height - (double)736.0) < DBL_EPSILON) { // iPhone 6+
                page.titleFont = [UIFont fontWithName:@"IRANSans-Bold" size:20.0];
                page.descFont = [UIFont fontWithName:@"IRANSans" size:16.0];
                page.titlePositionY = 200.0;
                page.descPositionY = 170.0;
                
                page.titleIconPositionY = 125.0;
            }
        }
        else {
            page.titleFont = [UIFont fontWithName:@"IRANSans-Bold" size:20.0];
            page.descFont = [UIFont fontWithName:@"IRANSans" size:16.0];
            page.descWidth = 360.0;
            
            page.titlePositionY = 200.0;
            page.descPositionY = 160.0;
            //page.titleIconPositionY = 150.0;
        }
    }
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3]];
    intro.delegate = self;
    
    intro.skipButton.hidden = true;
    intro.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    intro.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    
    [intro showInView:self.view animateDuration:0.25];
}

-(void)dismissWelcomeScreen {
    if (self.isDownloadCompleted) {
        UITabBarController *rootTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"RootTabBarController"];
        if (self.availableUpdatesCount > 0) {
            [[rootTabBarController.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)self.availableUpdatesCount]];
        }
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window.rootViewController presentViewController:rootTabBarController animated:true completion:^{
            APFDeepLinker.sharedInstance.enteredTheApp = true;
        }];
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"myapp-intro-2"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)introDidFinish:(EAIntroView *)introView {
    [self dismissWelcomeScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
