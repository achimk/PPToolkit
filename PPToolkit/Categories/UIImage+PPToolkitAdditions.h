//
//  UIImage+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 05.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PPToolkitAdditions)

+ (UIImage *)pp_imageWithColor:(UIColor *)color;
+ (UIImage *)pp_imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)pp_imageNamed:(NSString *)name bundleName:(NSString *)bundleName;

@end
