//
//  PPViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPViewController.h"

#import <objc/runtime.h>
#import "PPAutorotation.h"

/**
 * Initially, I intended to make the iOS 6 autorotation methods for UIViewController globally, not just for the
 * the PPViewController subhierarchy. The obvious way to achieve this result is to swizzle the deprecated
 * -shouldAutorotateToInterfaceOrientation: at the UIViewController level. This cannot work, though: When a
 * view controller is displayed modally or as the root of an application on iOS 4 and 5, the UIViewController
 * -shouldAutorotateToInterfaceOrientation: method is not called if the view controller subclass which is
 * being rotated does not actually override the -shouldAutorotateToInterfaceOrientation: method. We therefore
 * cannot rely on swizzling since there is no way for the swizzling implementation to be called in those two cases.
 *
 * This is confirmed when disassembling one of the UIViewController methods which gets called when rotation
 * occurs for a modal or root view controller: -_isSupportedInterfaceOrientation. This method internally
 * calls -_doesOverrideLegacyShouldAutorotateMethod, which inhibits the call to -shouldAutorotateToInterfaceOrientation:
 * if the displayed view controller subclass does not override it.
 *
 * After thinking a little bit more, making iOS 6 autorotation methods available for PPViewController and not
 * for all of UIViewController class hierarchy is the right thing to do, though:
 *  - if the -shoudlAutorotateToInterfaceOrientation: is swizzled at the UIViewController level, we have no
 *    guarantee that it will get actually be called. Users namely often forget to call the super method
 *    somewhere in the class hierarchy. For PPViewController, failing to do so is documented to lead to
 *    undefined behavior. There is sadly no simple way to enforce this constraint, but at least this is
 *    documented
 *  - swizzling at the UIViewController level would alter the behavior of view controller subclasses which you
 *    do not control the implementation of (e.g. view controller classes stemming from a static library). In
 *    such cases, we would require a parameter to be available so that the trick making iOS 6 methods available
 *    on iOS 4 and 5 can be disabled
 */
@interface PPViewController ()
@end

#pragma mark -

@implementation PPViewController

@dynamic appearsFirstTime;

#pragma mark Object creation and destruction

- (id)init {
    NSString *nibName = nil;
    if ([[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"nib"]) {
        nibName = NSStringFromClass([self class]);
    }
    
    return [self initWithNibName:nibName bundle:nil];
}

- (id)initWithBundle:(NSBundle *)nibBundleOrNil {
    NSString *nibName = nil;
    if ([[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"nib"]) {
        nibName = NSStringFromClass([self class]);
    }
    
    return [self initWithNibName:nibName bundle:nibBundleOrNil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _PPViewControllerFlags.appearsFirstTime = YES;
    }
    return self;
}

- (void)dealloc {
    [self releaseViews];
}

- (void)releaseViews {
}

#pragma mark View

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //reset flags
    _PPViewControllerFlags.appearsFirstTime = NO;
}

#pragma mark Accessors

- (void)setView:(UIView *)view {
    [super setView:view];
    
    if (! view) {
        [self releaseViews];
    }
}

- (BOOL)appearsFirstTime {
    return _PPViewControllerFlags.appearsFirstTime;
}
 
#pragma mark Orientation Management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    // Implement the old deprecated method in terms of the iOS 6 autorotation methods
    return [self shouldAutorotate] && ([self supportedInterfaceOrientations] & (1 << toInterfaceOrientation));
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
