//
//  SDCAlertView+SDCAlertViewSwiftCompatible.h
//  PROJECT
//
//  Created by Sadjad Fouladi on 2/2/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

#import "SDCAlertView.h"

@interface SDCAlertView (SDCAlertViewSwiftCompatible)

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle;

@end
