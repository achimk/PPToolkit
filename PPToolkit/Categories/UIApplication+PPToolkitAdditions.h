//
//  UIApplication+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 19.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (PPToolkitAdditions)

//Directories
- (NSURL *)pp_URLDirectoryDocuments;
- (NSURL *)pp_URLDirectoryCaches;
- (NSURL *)pp_URLDirectoryDownloads;
- (NSURL *)pp_URLDirectoryLibrary;
- (NSURL *)pp_URLDirectoryApplicationSupport;

//Utilities
- (BOOL)pp_isPirated;

@end
