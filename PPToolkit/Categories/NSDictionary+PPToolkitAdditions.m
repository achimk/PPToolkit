//
//  NSDictionary+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 07.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "NSDictionary+PPToolkitAdditions.h"

@implementation NSDictionary (PPToolkitAdditions)

- (id)pp_safeObjectForKey:(id)key {
    id value = [self valueForKey:key];
    if ([NSNull null] == value) {
        return nil;
    }
    return value;
}

@end
