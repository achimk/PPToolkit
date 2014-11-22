//
//  UIPopoverController+PPToolkitExtensions.m
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIPopoverController+PPToolkitExtensions.h"

/*
#import "PPRuntime.h"

// Associated object keys
static void *s_popoverControllerKey = &s_popoverControllerKey;

// Original implementation of the methods we swizzle
static id (*s_UIPopoverController__initWithContentViewController_Imp)(id, SEL, id) = NULL;
static void (*s_UIPopoverController__dealloc_Imp)(id, SEL) = NULL;
static void (*s_UIPopoverController__setContentViewController_animated_Imp)(id, SEL, id, BOOL) = NULL;

// Swizzled method implementations
static id swizzled_UIPopoverController__initWithContentViewController_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController);
static void swizzled_UIPopoverController__dealloc_Imp(UIPopoverController *self, SEL _cmd);
static void swizzled_UIPopoverController__setContentViewController_animated_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController, BOOL animated);

#pragma mark - PPToolkitExtensionsPrivate

@interface UIPopoverController (PPToolkitExtensionsPrivate)
// Currently empty. Just used for method swizzling
@end

@implementation UIPopoverController (PPToolkitExtensionsPrivate)

+ (void)load
{
    // initWithContentViewController: sadly does not rely on setContentViewController:animated: to set its content view controller. Must
    // swizzle it as well
    s_UIPopoverController__initWithContentViewController_Imp = (id (*)(id, SEL, id))PPSwizzleSelector(self,
                                                                                                      @selector(initWithContentViewController:),
                                                                                                      (IMP)swizzled_UIPopoverController__initWithContentViewController_Imp);
    s_UIPopoverController__dealloc_Imp = (void (*)(id, SEL))PPSwizzleSelector(self,
                                                                              @selector(dealloc),
                                                                              (IMP)swizzled_UIPopoverController__dealloc_Imp);
    s_UIPopoverController__setContentViewController_animated_Imp = (void (*)(id, SEL, id, BOOL))PPSwizzleSelector(self,
                                                                                                                  @selector(setContentViewController:animated:),
                                                                                                                  (IMP)swizzled_UIPopoverController__setContentViewController_animated_Imp);
}

@end

#pragma mark - PPToolkitExtensions

@implementation UIPopoverController (PPToolkitExtensions)

- (UIPopoverController *)popoverController
{
    UIPopoverController *popoverController = objc_getAssociatedObject(self, s_popoverControllerKey);
    if (popoverController) {
        return popoverController;
    }
    else {
        return self.parentViewController.popoverController;
    }
}

@end

static id swizzled_UIPopoverController__initWithContentViewController_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController)
{
    self = (*s_UIPopoverController__initWithContentViewController_Imp)(self, _cmd, viewController);
    if (self) {
        objc_setAssociatedObject(viewController, s_popoverControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    }
    return self;
}

static void swizzled_UIPopoverController__dealloc_Imp(UIPopoverController *self, SEL _cmd)
{
    objc_setAssociatedObject(self.contentViewController, s_popoverControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    (*s_UIPopoverController__dealloc_Imp)(self, _cmd);
}

static void swizzled_UIPopoverController__setContentViewController_animated_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController, BOOL animated)
{
    // Remove the old association before creating the new one
    objc_setAssociatedObject(self.contentViewController, s_popoverControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    (*s_UIPopoverController__setContentViewController_animated_Imp)(self, _cmd, viewController, animated);
    objc_setAssociatedObject(viewController, s_popoverControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
}

*/