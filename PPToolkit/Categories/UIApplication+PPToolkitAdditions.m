//
//  UIApplication+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 19.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIApplication+PPToolkitAdditions.h"

@implementation UIApplication (PPToolkitAdditions)

#pragma mark Directories

- (NSURL *)pp_URLDirectoryDocuments {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)pp_URLDirectoryCaches {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)pp_URLDirectoryDownloads {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)pp_URLDirectoryLibrary {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)pp_URLDirectoryApplicationSupport {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark Utilities

- (BOOL)pp_isPirated {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"] != nil;
}

@end
