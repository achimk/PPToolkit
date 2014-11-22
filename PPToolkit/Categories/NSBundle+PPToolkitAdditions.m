//
//  NSBundle+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 05.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "NSBundle+PPToolkitAdditions.h"

@implementation NSBundle (PPToolkitAdditions)

+ (NSBundle *)pp_ToolkitBundle {
    static NSBundle * __toolkitBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PPToolkitResources.bundle"];
        __toolkitBundle = [[NSBundle alloc] initWithPath:bundlePath];
    });
    
    return __toolkitBundle;
}

@end
