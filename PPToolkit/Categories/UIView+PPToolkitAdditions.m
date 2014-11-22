//
//  UIView+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 06.04.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIView+PPToolkitAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (PPToolkitAdditions)

- (UIImage *)pp_screenshotWithOptimization:(BOOL)optimized {
    if (optimized) {
        // take screenshot of the view
        if ([self isKindOfClass:NSClassFromString(@"MKMapView")]) {
            if (6.0 <= [[[UIDevice currentDevice] systemVersion] floatValue]) {
                // in iOS6, there is no problem using a non-retina screenshot in a retina display screen
                UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0);
            }
            else {
                // if the view is a mapview in iOS5.0 and below, screenshot has to take the screen scale into consideration
                // else, the screen shot in retina display devices will be of a less detail map (note, it is not the size of the screenshot, but it is the level of detail of the screenshot
                UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
            }
        }
        else {
            // for performance consideration, everything else other than mapview will use a lower quality screenshot
            UIGraphicsBeginImageContext(self.frame.size);
        }
    }
    else {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    }

    if (nil == UIGraphicsGetCurrentContext()) {
        NSLog(@"UIGraphicsGetCurrentContext() is nil. You may have a UIView with CGRectZero");
        return nil;
    }
    else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        //        NSString *documentsDirectory = [paths objectAtIndex:0];
        //        NSString *testScreenshot = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
        //        NSData *imageData = UIImagePNGRepresentation(screenshot);
        //        [imageData writeToFile:testScreenshot atomically:YES];
        
        return screenshot;
    }
}

- (UIImage *)pp_screenshot {
    return [self pp_screenshotWithOptimization:YES];
}

@end
