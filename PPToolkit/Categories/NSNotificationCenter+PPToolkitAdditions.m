//
//  NSNotificationCenter+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 11.11.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "NSNotificationCenter+PPToolkitAdditions.h"

@implementation NSNotificationCenter (PPToolkitAdditions)

- (void)pp_postNotificationOnMainThread:(NSNotification *)aNotification {
    if ([NSThread isMainThread]) {
        [self postNotification:aNotification];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postNotification:aNotification];
        });
    }
}

- (void)pp_postNotificationNameOnMainThread:(NSString *)name object:(id)object {
    if ([NSThread isMainThread]) {
        [self postNotificationName:name object:object];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postNotificationName:name object:object];
        });
    }
}

- (void)pp_postNotificationNameOnMainThread:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    if ([NSThread isMainThread]) {
        [self postNotificationName:name object:object userInfo:userInfo];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postNotificationName:name object:object userInfo:userInfo];
        });
    }
}

@end
