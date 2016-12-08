//
//  APFUpdateAppsViewController.m
//  PROJECT
//
//  Created by Nima Azimi on 12/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFUpdateAppsViewController.h"
#import "APFPROJECTAPI.h"
#import "APFAppEntry.h"
#import "APFUpdateAppTableViewCell.h"
#import "APFAppDescriptionViewController.h"
#import "UIViewController+ADFlipTransition.h"

@interface APFUpdateAppsViewController ()

@property (nonatomic, strong) UIView *noResultView;
@property (nonatomic) BOOL showMessage;

@property (nonatomic,weak) IBOutlet UIButton * delButton;

@end

@implementation APFUpdateAppsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showMessage = !([[NSUserDefaults standardUserDefaults] boolForKey:@"ShownUpdateSwipeMessage"]);
    
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [APFPROJECTAPI currentInstance].PROJECTApiDelegate = self;
    self.noResultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.parentViewController.view.bounds.size.width, self.parentViewController.view.bounds.size.height)];
    self.noResultView.backgroundColor = [UIColor whiteColor];
    
    // add en empty notes image placholder
    // when there is no data to display
    UIImageView *noResultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(((self.parentViewController.view.bounds.size.width - 160) / 2), 50, 160, 160)];
    noResultImageView.image = [UIImage imageNamed:@"NoSearchResult.png"];
    
    [self.noResultView addSubview:noResultImageView];
    
    UILabel *noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(((self.parentViewController.view.bounds.size.width - 250) / 2), 250, 250, 20)];

    noResultLabel.text = @"برنامه‌ای برای نمایش وجود ندارد";
    noResultLabel.font = [UIFont fontWithName:@"IRANSans" size:14.0f];
    noResultLabel.textAlignment = NSTextAlignmentCenter;
    noResultLabel.textColor = [UIColor lightGrayColor];
    noResultLabel.shadowColor = [UIColor whiteColor];
    noResultLabel.backgroundColor = [UIColor clearColor];
    
    [self.noResultView addSubview:noResultLabel];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchDataAndReloadTable];
    
    [APFPROJECTAPI currentInstance].PROJECTApiDelegate = self;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 8, 0, -8)];
    
    
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [APFPROJECTAPI currentInstance].PROJECTApiDelegate = nil;
}

- (void) fetchDataAndReloadTable {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSMutableArray *appEntries = [[APFPROJECTAPI currentInstance] getUpdateAppList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (appEntries.count > 0) {
                [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)appEntries.count]];
            }
            else {
                [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
            }
            
            [self setAppEntries:appEntries];
            [self.tableView reloadData];
            
            for (int i=0; i<[appEntries count]; i++) {
                APFAppEntry* app =[appEntries objectAtIndex:i];
                [app setIconDownloadedHandler:^{
                    [self.tableView reloadData];
                }];
                [app startDownloadIcon];
            }
        });
    });
    
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    /* Subject to change in the future
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 96 + 8;
    } else {
        return 96 + 8;
    } */
    if(self.showMessage && indexPath.section == 0)
        return 40;
    
    return 80.0 + 8.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.showMessage ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showMessage && section == 0)
    {
        if (self.AppEntries) {
            if([self.AppEntries count] != 0){
                return 1;
            }
        }
        return 0;
    }
    if (self.AppEntries) {
        if([self.AppEntries count] != 0){
            [self.noResultView removeFromSuperview];
            return [self.AppEntries count];
        }else{
            [self.view addSubview:self.noResultView];
            return 0;
        }
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.showMessage && indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"MessageViewCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
        
    }
    
    static NSString *CellIdentifier = @"AppListCell";
    
    APFUpdateAppTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (self.AppEntries) {
        if ([self.AppEntries count]>0) {
            self.tableView.hidden = NO;
            //cell.cellDetailDownloadsTitleLabel.hidden = NO;
            //cell.cellDetailSizeTitleLabel.hidden = NO;
            cell.versionTitleLabel.hidden = NO;
            //cell.cellDetailsLabel.hidden = YES;
            //cell.cellInfoIcon.hidden = NO;
            //cell.cellHRule.hidden = NO;
            [cell.loadingIndicator stopAnimating];
            
            if (indexPath.row < [self.AppEntries count]) {
                APFAppEntry *app = [self.AppEntries objectAtIndex:indexPath.row];
                //                [cell.cellDetailsLabel setText:[NSString stringWithFormat:@"Size: %@ | Download: %@", app.applicationDescription.applicationSize, [app applicationDownloads]]];
                cell.appName = app.applicationName;
                cell.appId =  [[app.applicationCopies lastObject] objectForKey:@"lid"];
                cell.appiTunesId = app.applicationiTunesIdentification;
                
                cell.appIconUrl = app.applicationIconURL;
                //[cell.versionLabel setText:[NSString stringWithFormat:@"%@  /  %@", [[app.applicationCopies lastObject] objectForKey:@"ver"], [[app.applicationCopies lastObject] objectForKey:@"siz"]]];
                
                //[cell.versionLabel setText:[[app.applicationCopies lastObject] objectForKey:@"ver"]];
                
                cell.releaseNote.text = app.applicationReleaseNote;
                [cell.releaseNote sizeToFit];
                
                UIImageView *uiv = [cell cellItemImageView];
                uiv.hidden = NO;
                
                [cell.cellItemLabel setText: [NSString stringWithFormat:@"%@", [app applicationName]]];
                if (app.applicationIcon != nil) {
                    [cell.cellItemImageView setImage:app.applicationIcon];
                    if (app.applicationDescription == nil) {
                        [app startDownloadDescriptionForAppBuy:false];
                    }
                }
                else {
                    //                [app startDownloadIconIndex];
                    [uiv setImage:[UIImage imageNamed:@"noIconForApps"]];
                }
                [cell processInstallAndProgressUI];
            }
            else {
                //            NSLog(@"Consider reloading!");
                [cell.cellItemLabel setText:@"Loading..."];
                //cell.cellInfoIcon.hidden = YES;
                UIImageView *uiv = [cell cellItemImageView];
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:12];
                for (int i=0; i<12; i++) {
                    [arr addObject:[UIImage imageNamed:[NSString stringWithFormat:@"frame_%02d.png", i]]];
                }
                uiv.animationImages = arr;
                uiv.animationDuration = 1.0f;
                uiv.animationRepeatCount = 120;
                [uiv startAnimating];
            }
        }else{
            //cell.versionTitleLabel.hidden = YES;
            //cell.cellInfoIcon.hidden = YES;
            //cell.cellDetailsLabel.hidden = NO;
            [cell.cellItemLabel setText:@"یافت نشد"];
            //[cell.cellDetailsLabel setText:@"برنامه‌ای برای نمایش وجود ندارد!"];
            cell.cellItemLabel.font = [UIFont fontWithName:@"IRANSans" size:14.0];
            //cell.cellDetailsLabel.font = [UIFont fontWithName:@"IRANSans" size:10.0];
            cell.cellItemLabel.textAlignment = NSTextAlignmentRight;
            //cell.cellDetailsLabel.textAlignment = NSTextAlignmentLeft;
            [cell.cellItemImageView setImage:nil];
        }
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        UIFont *font = [UIFont fontWithName:@"IRANSans" size:13.0];
        NSDictionary *attrsDictionary = @{ NSFontAttributeName :font, NSForegroundColorAttributeName : [UIColor whiteColor]};
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"حذف" attributes:attrsDictionary];
        
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: self.delButton];
        UIButton *buttonCopy = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
        [buttonCopy.titleLabel setAttributedText:attrString];
        [rightUtilityButtons addObject:buttonCopy];
        cell.rightUtilityButtons = rightUtilityButtons;
        cell.delegate = self;
    }else{
        //cell.versionTitleLabel.hidden = YES;
        //cell.cellDetailsLabel.hidden = YES;
        //cell.cellInfoIcon.hidden = YES;
        cell.installButton.hidden = YES;
        cell.cancelButton.hidden = YES;
        //cell.cellHRule.hidden = YES;
        [cell.loadingIndicator startAnimating];
        [cell.cellItemLabel setText:@""];
        
        UIImageView *uiv = [cell cellItemImageView];
        uiv.hidden = YES;
    }
    return cell;
}

#pragma mark SWTableCellDelegate
// click event on left utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    
}

// click event on right utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    APFUpdateAppTableViewCell * cellExt = (APFUpdateAppTableViewCell * )cell;
    [[APFPROJECTAPI currentInstance] hideAppUpdate:cellExt.appiTunesId andComplete:^(void){
        NSMutableArray * array = [NSMutableArray arrayWithArray:self.AppEntries];
        [array removeObjectAtIndex:[self.tableView indexPathForCell:cell].item];
        [self setAppEntries:array];
        [self.tableView reloadData];
        if (array.count > 0) {
            [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)array.count]];
        }
        else {
            [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
        }
    }];
}

// utility button open/close event
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    APFUpdateAppTableViewCell * cellExt = (APFUpdateAppTableViewCell * )cell;
    if (state == kCellStateRight)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShownUpdateSwipeMessage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [cellExt pauseDownload];
        [cellExt.installButton setHidden:YES];
        [cellExt.cancelButton setHidden:YES];
    }
    else
    {
        [cellExt processInstallAndProgressUI];
    }
}

// prevent multiple cells from showing utilty buttons simultaneously
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return false;
}

// prevent cell(s) from displaying left/right utility buttons
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return true;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
