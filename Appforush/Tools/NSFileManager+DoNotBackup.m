//
//  NSFileManager+DoNotBackup.m
//  PROJECT
//
//  Created by Nima Azimi on 2/August/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "NSFileManager+DoNotBackup.h"

@implementation NSFileManager (DoNotBackup)

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    return success;
}

@end
