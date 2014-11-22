//
//  UIScreen+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 19.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (PPToolkitAdditions)

+ (BOOL)pp_isRetina;
+ (BOOL)pp_isGiraffe;

+ (CGRect)pp_screenBounds;
+ (CGFloat)pp_statusBarHeight;

- (CGRect)pp_currentBounds;
- (CGRect)pp_boundsForOrientation:(UIInterfaceOrientation)orientation;

@end
