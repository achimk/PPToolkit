//
//  NSNotificationCenter+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 11.11.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (PPToolkitAdditions)

- (void)pp_postNotificationOnMainThread:(NSNotification *)aNotification;
- (void)pp_postNotificationNameOnMainThread:(NSString *)name object:(id)object;
- (void)pp_postNotificationNameOnMainThread:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end
