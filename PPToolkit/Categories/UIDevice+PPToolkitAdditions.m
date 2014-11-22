//
//  UIDevice+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 19.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIDevice+PPToolkitAdditions.h"

#import "PPToolkitDefines.h"

@implementation UIDevice (PPToolkitAdditions)

- (BOOL)pp_isSimulator {
    static NSString * simulatorModel = @"iPhone Simulator";
    return [[self model] isEqualToString:simulatorModel];
}


- (BOOL)pp_isCrappy {
    static NSString * iPodTouchModel = @"iPod touch";
    static NSString * iPhoneModel = @"iPhone";
    static NSString * iPhone3GModel = @"iPhone 3G";
    static NSString * iPhone3GSModel = @"iPhone 3GS";
    
    NSString * model = [self model];
    
    return ([model isEqualToString:iPodTouchModel] || [model isEqualToString:iPhoneModel] ||
            [model isEqualToString:iPhone3GModel] || [model isEqualToString:iPhone3GSModel]);
}

@end
