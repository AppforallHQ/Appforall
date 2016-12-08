//
//  NSFileManager+DoNotBackup.h
//  PROJECT
//
//  Created by Nima Azimi on 2/August/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DoNotBackup)

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
