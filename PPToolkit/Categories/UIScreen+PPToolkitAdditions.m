//
//  UIScreen+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 19.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIScreen+PPToolkitAdditions.h"

#import "PPToolkitDefines.h"

@implementation UIScreen (PPToolkitAdditions)

+ (BOOL)pp_isRetina {
    static BOOL __isRetina;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __isRetina = IS_RETINA;
    });
    
    return __isRetina;
}

+ (BOOL)pp_isGiraffe {
    static BOOL __isGiraffe;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __isGiraffe = IS_IPHONE_5;
    });
    
    return __isGiraffe;
}

+ (CGRect)pp_screenBounds {
    return [[UIScreen mainScreen] pp_currentBounds];
}

+ (CGFloat)pp_statusBarHeight {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        return 0.0f;
    }
    else if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    else {
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
}

- (CGRect)pp_currentBounds {
    return [self pp_boundsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}


- (CGRect)pp_boundsForOrientation:(UIInterfaceOrientation)orientation {
    CGRect bounds = [self bounds];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat buffer = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = buffer;
    }
    
    return bounds;
}

@end
