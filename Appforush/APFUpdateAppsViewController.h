//
//  APFUpdateAppsViewController.h
//  PROJECT
//
//  Created by Nima Azimi on 12/October/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APFPROJECTAPI.h"
#import <SWTableViewCell.h>

@interface APFUpdateAppsViewController : UITableViewController <APFPROJECTAPIDelegate,SWTableViewCellDelegate>

@property (strong, nonatomic) NSArray* AppEntries;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *relatedAppCategory;

- (void) fetchDataAndReloadTable;

@end
