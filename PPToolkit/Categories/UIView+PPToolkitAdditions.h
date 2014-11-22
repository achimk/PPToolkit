//
//  UIView+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 06.04.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PPToolkitAdditions)

- (UIImage *)pp_screenshot;
- (UIImage *)pp_screenshotWithOptimization:(BOOL)optimized;

@end
