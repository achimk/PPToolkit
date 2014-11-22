//
//  UIAlertView+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 16.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIAlertView+PPToolkitAdditions.h"
#import <objc/runtime.h>

static char const * const __handlerAssociatedKey = "handlerAssociatedKey";

@implementation UIAlertView (PPToolkitAdditions)

+ (void)pp_showWithTitle:(NSString *)title message:(NSString *)message handler:(PPAlertViewHandler)handler {
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] pp_showWithHandler:handler];
}

+ (void)pp_showErrorWithMessage:(NSString *)message handler:(PPAlertViewHandler)handler {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error title")
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] pp_showWithHandler:handler];
}

+ (void)pp_showWarningWithMessage:(NSString *)message handler:(PPAlertViewHandler)handler {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Warning title")
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] pp_showWithHandler:handler];
}

+ (void)pp_showConfirmationDialogWithTitle:(NSString *)title message:(NSString *)message handler:(PPAlertViewHandler)handler {
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"No", @"NO")
                      otherButtonTitles:NSLocalizedString(@"Yes", @"YES"), nil] pp_showWithHandler:handler];
}

#pragma mark Show With Handler

- (void)pp_showWithHandler:(PPAlertViewHandler)handler {
    objc_setAssociatedObject(self, __handlerAssociatedKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.delegate = self;
    [self show];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    PPAlertViewHandler completionHandler = objc_getAssociatedObject(self, __handlerAssociatedKey);
    
    if (completionHandler) {
        completionHandler(alertView, buttonIndex);
    }
}

@end
