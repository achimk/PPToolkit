//
//  UINavigationController+PPToolkitExtensions.m
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UINavigationController+PPToolkitExtensions.h"

#import "PPAutorotationCompatibility.h"
#import "PPRuntime.h"

// Associated object keys
static void *s_autorotationModeKey = &s_autorotationModeKey;

// Original implementation of the methods we swizzle
static BOOL (*s_UINavigationController__shouldAutorotate_Imp)(id, SEL) = NULL;
static NSUInteger (*s_UINavigationController__supportedInterfaceOrientations_Imp)(id, SEL) = NULL;
static BOOL (*s_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp)(id, SEL, NSInteger) = NULL;

// Swizzled method implementations
static BOOL swizzled_UINavigationController__shouldAutorotate_Imp(UINavigationController *self, SEL _cmd);
static NSUInteger swizzled_UINavigationController__supportedInterfaceOrientations_Imp(UINavigationController *self, SEL _cmd);
static BOOL swizzled_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp(UINavigationController *self, SEL _cmd, NSInteger toInterfaceOrientation);

#pragma mark - PPToolkitExtensions

@implementation UINavigationController (PPToolkitExtensions)

#pragma mark Class methods

+ (void)load
{
    // No swizzling occurs on iOS < 6 since those two methods do not exist
    s_UINavigationController__shouldAutorotate_Imp = (BOOL (*)(id, SEL))PPSwizzleSelector(self,
                                                                                          @selector(shouldAutorotate),
                                                                                          (IMP)swizzled_UINavigationController__shouldAutorotate_Imp);
    s_UINavigationController__supportedInterfaceOrientations_Imp = (NSUInteger (*)(id, SEL))PPSwizzleSelector(self,
                                                                                                              @selector(supportedInterfaceOrientations),
                                                                                                              (IMP)swizzled_UINavigationController__supportedInterfaceOrientations_Imp);
    
    // Swizzled both on iOS < 6 and iOS 6
    s_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp = (BOOL (*)(id, SEL, NSInteger))PPSwizzleSelector(self,
                                                                                                                           @selector(shouldAutorotateToInterfaceOrientation:),
                                                                                                                           (IMP)swizzled_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp);
}

#pragma mark Accessors and mutators

- (PPAutorotationMode)autorotationMode
{
    NSNumber *autorotationModeNumber = objc_getAssociatedObject(self, s_autorotationModeKey);
    if (! autorotationModeNumber) {
        return PPAutorotationModeContainer;
    }
    else {
        return [autorotationModeNumber integerValue];
    }
}

- (void)setAutorotationMode:(PPAutorotationMode)autorotationMode
{
    objc_setAssociatedObject(self, s_autorotationModeKey, [NSNumber numberWithInteger:autorotationMode], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


// Swizzled on iOS 6 only, never called on iOS 4 and 5
static BOOL swizzled_UINavigationController__shouldAutorotate_Imp(UINavigationController *self, SEL _cmd)
{
    // On iOS 6, the container always decides first (does not look at children)
    if (! (*s_UINavigationController__shouldAutorotate_Imp)(self, _cmd)) {
        return NO;
    }
    
    switch (self.autorotationMode) {
        case PPAutorotationModeContainerAndAllChildren: {
            for (UIViewController<PPAutorotationCompatibility> *viewController in [self.viewControllers reverseObjectEnumerator]) {
                if (! [viewController shouldAutorotate]) {
                    return NO;
                }
            }
            break;
        }
            
        case PPAutorotationModeContainerAndTopChildren: {
            UIViewController<PPAutorotationCompatibility> *topViewController = (UIViewController<PPAutorotationCompatibility> *)self.topViewController;
            if (! [topViewController shouldAutorotate]) {
                return NO;
            }
            break;
        }
            
        case PPAutorotationModeContainerAndNoChildren:
        case PPAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return YES;
}

// Swizzled on iOS 6 only, never called on iOS 4 and 5 by UIKit (can be called by client code, though)
static NSUInteger swizzled_UINavigationController__supportedInterfaceOrientations_Imp(UINavigationController *self, SEL _cmd)
{
    // On iOS 6, the container always decides first (does not look at children)
    NSUInteger containerSupportedInterfaceOrientations = (*s_UINavigationController__supportedInterfaceOrientations_Imp)(self, _cmd);
    
    switch (self.autorotationMode) {
        case PPAutorotationModeContainerAndAllChildren: {
            for (UIViewController<PPAutorotationCompatibility> *viewController in [self.viewControllers reverseObjectEnumerator]) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
            break;
        }
            
        case PPAutorotationModeContainerAndTopChildren: {
            UIViewController<PPAutorotationCompatibility> *topViewController = (UIViewController<PPAutorotationCompatibility> *)self.topViewController;
            containerSupportedInterfaceOrientations &= [topViewController supportedInterfaceOrientations];
            break;
        }
            
        case PPAutorotationModeContainerAndNoChildren:
        case PPAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return containerSupportedInterfaceOrientations;
}

// Swizzled on iOS 6 as well, but never called by UIKit (can be called by client code, though)
static BOOL swizzled_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp(UINavigationController *self, SEL _cmd, NSInteger toInterfaceOrientation)
{
    switch (self.autorotationMode) {
        case PPAutorotationModeContainerAndAllChildren: {
            for (UIViewController *viewController in [self.viewControllers reverseObjectEnumerator]) {
                if (! [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
                    return NO;
                }
            }
            break;
        }
            
        case PPAutorotationModeContainerAndTopChildren: {
            if (self.topViewController && ! [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
                return NO;
            }
            break;
        }
            
        case PPAutorotationModeContainerAndNoChildren: {
            break;
        }
            
            
        case PPAutorotationModeContainer:
        default: {
            return (*s_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp)(self, _cmd, toInterfaceOrientation);
            break;
        }
    }
    
    return YES;
}

