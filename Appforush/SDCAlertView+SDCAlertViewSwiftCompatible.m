//
//  SDCAlertView+SDCAlertViewSwiftCompatible.m
//  PROJECT
//
//  Created by Sadjad Fouladi on 2/2/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

#import "SDCAlertView+SDCAlertViewSwiftCompatible.h"

@implementation SDCAlertView (SDCAlertViewSwiftCompatible)

-(instancetype)initWithTitle:(NSString *)title
                     message:(NSString *)message
                    delegate:(id)delegate
           cancelButtonTitle:(NSString *)cancelButtonTitle {
    
    SDCAlertView *alert = [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
    
//    NSString* arg = va_arg(args, NSString*);
//    
//    while(arg != nil) {
//        [alert addButtonWithTitle:arg];
//        arg = va_arg(args, NSString*);
//    }
    
    return alert;
}

@end