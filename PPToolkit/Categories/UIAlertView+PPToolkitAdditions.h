//
//  UIAlertView+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 16.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PPAlertViewHandler)(UIAlertView *alertView, NSInteger buttonIndex);

#pragma mark -

@interface UIAlertView (PPToolkitAdditions)

+ (void)pp_showWithTitle:(NSString *)title message:(NSString *)message handler:(PPAlertViewHandler)handler;
+ (void)pp_showErrorWithMessage:(NSString *)message handler:(PPAlertViewHandler)handler;
+ (void)pp_showWarningWithMessage:(NSString *)message handler:(PPAlertViewHandler)handler;
+ (void)pp_showConfirmationDialogWithTitle:(NSString *)title message:(NSString *)message handler:(PPAlertViewHandler)handler;

- (void)pp_showWithHandler:(PPAlertViewHandler)handler;

@end
