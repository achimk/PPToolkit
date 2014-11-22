//
//  UIImage+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 05.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIImage+PPToolkitAdditions.h"

@implementation UIImage (PPToolkitAdditions)

+ (UIImage *)pp_imageWithColor:(UIColor *)color {
    return [self pp_imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)pp_imageWithColor:(UIColor *)color size:(CGSize)size {
    NSParameterAssert(color);
    NSAssert1(size.width && size.height, @"Invalid image size: %@", NSStringFromCGSize(size));
    
    CGRect rect = CGRectZero;
    rect.size = size;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)pp_imageNamed:(NSString *)name bundleName:(NSString *)bundleName {
    if (!bundleName) {
        return [UIImage imageNamed:name];
    }
    
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString * imagePath = [bundlePath stringByAppendingPathComponent:name];
    return [UIImage imageNamed:imagePath];
}

@end
