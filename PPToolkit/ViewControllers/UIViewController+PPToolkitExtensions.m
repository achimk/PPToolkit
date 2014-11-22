//
//  UIViewController+PPToolkitExtensions.m
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "UIViewController+PPToolkitExtensions.h"

#import <objc/runtime.h>
#import "PPAutorotationCompatibility.h"
#import "PPRuntime.h"

// Associated object keys
static void *s_lifeCyclePhaseKey = &s_lifeCyclePhaseKey;
static void *s_originalViewSizeKey = &s_originalViewSizeKey;

// Original implementation of the methods we swizzle
static id (*s_UIViewController__initWithNibName_bundle_Imp)(id, SEL, id, id) = NULL;
static id (*s_UIViewController__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UIViewController__viewDidLoad_Imp)(id, SEL) = NULL;
static void (*s_UIViewController__viewWillAppear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewDidAppear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewWillDisappear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewDidDisappear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewWillUnload_Imp)(id, SEL) = NULL;
static void (*s_UIViewController__viewDidUnload_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static id swizzled_UIViewController__initWithNibName_bundle_Imp(UIViewController *self, SEL _cmd, NSString *nibName, NSBundle *bundle);
static id swizzled_UIViewController__initWithCoder_Imp(UIViewController *self, SEL _cmd, NSCoder *aDecoder);
static void swizzled_UIViewController__viewDidLoad_Imp(UIViewController *self, SEL _cmd);
static void swizzled_UIViewController__viewWillAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewDidAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewWillDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewDidDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewWillUnload_Imp(UIViewController *self, SEL _cmd);
static void swizzled_UIViewController__viewDidUnload_Imp(UIViewController *self, SEL _cmd);

#pragma mark - PPToolkitExtensionsPrivate

@interface UIViewController (PPToolkitExtensionsPrivate) <PPAutorotationCompatibility>

- (void)uiViewControllerPPToolkitExtensionsInit;
- (void)setLifeCyclePhase:(PPViewControllerLifeCyclePhase)lifeCyclePhase;
- (void)setOriginalViewSize:(CGSize)originalViewSize;

@end

@implementation UIViewController (PPToolkitExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UIViewController__initWithNibName_bundle_Imp = (id (*)(id, SEL, id, id))PPSwizzleSelector(self,
                                                                                                @selector(initWithNibName:bundle:),
                                                                                                (IMP)swizzled_UIViewController__initWithNibName_bundle_Imp);
    s_UIViewController__initWithCoder_Imp = (id (*)(id, SEL, id))PPSwizzleSelector(self,
                                                                                   @selector(initWithCoder:),
                                                                                   (IMP)swizzled_UIViewController__initWithCoder_Imp);
    s_UIViewController__viewDidLoad_Imp = (void (*)(id, SEL))PPSwizzleSelector(self,
                                                                               @selector(viewDidLoad),
                                                                               (IMP)swizzled_UIViewController__viewDidLoad_Imp);
    s_UIViewController__viewWillAppear_Imp = (void (*)(id, SEL, BOOL))PPSwizzleSelector(self,
                                                                                        @selector(viewWillAppear:),
                                                                                        (IMP)swizzled_UIViewController__viewWillAppear_Imp);
    s_UIViewController__viewDidAppear_Imp = (void (*)(id, SEL, BOOL))PPSwizzleSelector(self,
                                                                                       @selector(viewDidAppear:),
                                                                                       (IMP)swizzled_UIViewController__viewDidAppear_Imp);
    s_UIViewController__viewWillDisappear_Imp = (void (*)(id, SEL, BOOL))PPSwizzleSelector(self,
                                                                                           @selector(viewWillDisappear:),
                                                                                           (IMP)swizzled_UIViewController__viewWillDisappear_Imp);
    s_UIViewController__viewDidDisappear_Imp = (void (*)(id, SEL, BOOL))PPSwizzleSelector(self,
                                                                                          @selector(viewDidDisappear:),
                                                                                          (IMP)swizzled_UIViewController__viewDidDisappear_Imp);
    s_UIViewController__viewWillUnload_Imp = (void (*)(id, SEL))PPSwizzleSelector(self,
                                                                                  @selector(viewWillUnload),
                                                                                  (IMP)swizzled_UIViewController__viewWillUnload_Imp);
    s_UIViewController__viewDidUnload_Imp = (void (*)(id, SEL))PPSwizzleSelector(self,
                                                                                 @selector(viewDidUnload),
                                                                                 (IMP)swizzled_UIViewController__viewDidUnload_Imp);
}

#pragma mark Object creation and destruction

- (void)uiViewControllerPPToolkitExtensionsInit
{
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseInitialized];
    [self setOriginalViewSize:CGSizeZero];
}

#pragma mark Accessors and mutators

- (void)setLifeCyclePhase:(PPViewControllerLifeCyclePhase)lifeCyclePhase
{
    objc_setAssociatedObject(self, s_lifeCyclePhaseKey, [NSNumber numberWithInt:lifeCyclePhase], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setOriginalViewSize:(CGSize)originalViewSize
{
    objc_setAssociatedObject(self, s_originalViewSizeKey, [NSValue valueWithCGSize:originalViewSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - PPToolkitExtensions

@implementation UIViewController (PPToolkitExtensions)

#pragma mark View management

/**
 * Remark: We have NOT overridden the view property to perform the viewDidUnload, and on purpose. This would have been
 *         very convenient, but this would have been unusual and in most cases the viewDidUnload would have
 *         been sent twice (when a container controller nils a view it manages, it is likely it will set the view
 *         to nil and send it the viewDidUnload afterwards. If all view controller containers of the world knew
 *         about PPViewController, this would work, but since they don't this would lead to viewDidUnload be
 *         called twice in most cases)!
 */
- (void)unloadViews
{
    if ([self isViewLoaded]) {
        BOOL isRunningIOS6 = (class_getInstanceMethod([UIViewController class], @selector(shouldAutorotate)) != NULL);
        
        if (! isRunningIOS6) {
            // The -viewWillUnload method is available starting with iOS 5 and deprecated starting with iOS 6, but was
            // in fact already privately implemented on iOS 4 (with empty implementation). Does not harm to call it here
            [self viewWillUnload];
        }
        self.view = nil;
        if (! isRunningIOS6) {
            [self viewDidUnload];
        }
    }
}

#pragma mark Accessors and mutators

- (PPViewControllerLifeCyclePhase)lifeCyclePhase
{
    return [objc_getAssociatedObject(self, s_lifeCyclePhaseKey) intValue];
}

- (UIView *)viewIfLoaded
{
    return [self isViewLoaded] ? self.view : nil;
}

- (BOOL)isViewVisible
{
    PPViewControllerLifeCyclePhase lifeCyclePhase = [self lifeCyclePhase];
    return PPViewControllerLifeCyclePhaseViewWillAppear <= lifeCyclePhase
        && lifeCyclePhase <= PPViewControllerLifeCyclePhaseViewWillDisappear;
}

- (BOOL)isViewDisplayed
{
    PPViewControllerLifeCyclePhase lifeCyclePhase = [self lifeCyclePhase];
    return PPViewControllerLifeCyclePhaseViewWillAppear <= lifeCyclePhase
        && lifeCyclePhase < PPViewControllerLifeCyclePhaseViewDidUnload;
}

- (CGSize)originalViewSize
{
    if ([self lifeCyclePhase] < PPViewControllerLifeCyclePhaseViewDidLoad) {
        NSLog(@"The view has not been created. Size is unknown yet");
        return CGSizeZero;
    }
    
    return [objc_getAssociatedObject(self, s_originalViewSizeKey) CGSizeValue];
}

- (BOOL)isReadyForLifeCyclePhase:(PPViewControllerLifeCyclePhase)lifeCyclePhase
{
    PPViewControllerLifeCyclePhase currentLifeCyclePhase = [self lifeCyclePhase];
    switch (lifeCyclePhase) {
        case PPViewControllerLifeCyclePhaseViewDidLoad: {
            return currentLifeCyclePhase == PPViewControllerLifeCyclePhaseInitialized
                || currentLifeCyclePhase  == PPViewControllerLifeCyclePhaseViewDidUnload;
            break;
        }
            
        case PPViewControllerLifeCyclePhaseViewWillAppear: {
            return currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewDidLoad
                || currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewDidDisappear;
            break;
        }
            
        case PPViewControllerLifeCyclePhaseViewDidAppear: {
            return currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewWillAppear;
            break;
        }
            
        case PPViewControllerLifeCyclePhaseViewWillDisappear: {
            // Having a view controller transition from ViewWillAppear to ViewWillDisappear directly is quite rare (in
            // general we expect it to transition to ViewDidAppear first), but this can still happen if two container
            // animations are played simultaneously (i.e. if two containers are nested). If the first container is
            // revealing the view controller while this view controller is being replaced in the second, and depending
            // on the timing of the animations, the view controller might have disappeared before it actually appeared
            return currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewDidAppear        // <-- usual case
                || currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewWillAppear;      // <-- rare (see above)
            break;
        }
            
        case PPViewControllerLifeCyclePhaseViewDidDisappear: {
            return currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewWillDisappear;
            break;
        }
            
        case PPViewControllerLifeCyclePhaseViewWillUnload: {
            return currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewDidLoad
                || currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewDidDisappear;
            break;
        }
            
        case PPViewControllerLifeCyclePhaseViewDidUnload: {
            return currentLifeCyclePhase == PPViewControllerLifeCyclePhaseViewWillUnload;
            break;
        }
            
        default: {
            NSLog(@"Invalid lifecycle phase, or testing for initialization");
            return NO;
            break;
        }
    }
}

#pragma mark Rotations

- (BOOL)implementsNewAutorotationMethods
{
    return [self respondsToSelector:@selector(shouldAutorotate)]
        && [self respondsToSelector:@selector(supportedInterfaceOrientations)];
}

- (BOOL)shouldAutorotateForOrientations:(UIInterfaceOrientationMask)orientations
{
    if ([self implementsNewAutorotationMethods]) {
        return [self shouldAutorotate] && (orientations & [self supportedInterfaceOrientations]);
    }
    else {
        if (orientations & UIInterfaceOrientationMaskPortrait
            && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]) {
            return YES;
        }
        else if (orientations & UIInterfaceOrientationMaskLandscapeLeft
                 && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]) {
            return YES;
        }
        else if (orientations & UIInterfaceOrientationMaskLandscapeRight
                 && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]) {
            return YES;
        }
        else if (orientations & UIInterfaceOrientationMaskPortraitUpsideDown
                 && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)isOrientationCompatibleWithViewController:(UIViewController *)viewController
{
    if (! viewController) {
        return NO;
    }
    
    if ([viewController implementsNewAutorotationMethods]) {
        return [self shouldAutorotateForOrientations:[viewController supportedInterfaceOrientations]];
    }
    else {
        if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]
            && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]) {
            return YES;
        }
        else if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]
                 && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]) {
            return YES;
        }
        else if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]
                 && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]) {
            return YES;
        }
        else if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]
                 && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)autorotatesToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self implementsNewAutorotationMethods]) {
        return [self shouldAutorotate] && ([self supportedInterfaceOrientations] & (1 << interfaceOrientation));
    }
    else {
        return [self shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
}

- (UIInterfaceOrientation)compatibleOrientationWithOrientations:(UIInterfaceOrientationMask)orientations
{
    if (orientations & UIInterfaceOrientationMaskPortrait) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait))
            || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]) {
            return UIInterfaceOrientationPortrait;
        }
    }
    if (orientations & UIInterfaceOrientationMaskLandscapeRight) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeRight))
            || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]) {
            return UIInterfaceOrientationLandscapeRight;
        }
    }
    if (orientations & UIInterfaceOrientationMaskLandscapeLeft) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft))
            || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]) {
            return UIInterfaceOrientationLandscapeLeft;
        }
    }
    if (orientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortraitUpsideDown))
            || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
            return UIInterfaceOrientationPortraitUpsideDown;
        }
    }
    return 0;
}

- (UIInterfaceOrientation)compatibleOrientationWithViewController:(UIViewController *)viewController
{
    if (! viewController) {
        return 0;
    }
    
    return [self compatibleOrientationWithOrientations:[viewController supportedInterfaceOrientations]];
}

@end

#pragma mark Swizzled method implementations

static id swizzled_UIViewController__initWithNibName_bundle_Imp(UIViewController *self, SEL _cmd, NSString *nibName, NSBundle *bundle)
{
    if ((self = (*s_UIViewController__initWithNibName_bundle_Imp)(self, _cmd, nibName, bundle))) {
        [self uiViewControllerPPToolkitExtensionsInit];
    }
    return self;
}

static id swizzled_UIViewController__initWithCoder_Imp(UIViewController *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UIViewController__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        [self uiViewControllerPPToolkitExtensionsInit];
    }
    return self;
}

static void swizzled_UIViewController__viewDidLoad_Imp(UIViewController *self, SEL _cmd)
{
    if (! [self isViewLoaded]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The view controller's view has not been loaded"
                                     userInfo:nil];
    }
    
    (*s_UIViewController__viewDidLoad_Imp)(self, _cmd);
    
    /*
    if (! [self isReadyForLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidLoad]) {
        NSLog(@"The viewDidLoad method has been called on %@, but its current view lifecycle state is not compatible. "
              "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
              "or maybe [super viewDidLoad] has not been called by class %@ or one of its parents", self, [self class]);
    }
     */
    
    [self setOriginalViewSize:self.view.bounds.size];
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidLoad];
}

static void swizzled_UIViewController__viewWillAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewWillAppear_Imp)(self, _cmd, animated);
    
    /*
    if (! [self isReadyForLifeCyclePhase:PPViewControllerLifeCyclePhaseViewWillAppear]) {
        NSLog(@"The viewWillAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
              "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
              "or maybe [super viewWillAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    */
     
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseViewWillAppear];
}

static void swizzled_UIViewController__viewDidAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewDidAppear_Imp)(self, _cmd, animated);
    
    /*
    if (! [self isReadyForLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidAppear]) {
        NSLog(@"The viewDidAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
              "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
              "or maybe [super viewDidAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
     */
    
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidAppear];
}

static void swizzled_UIViewController__viewWillDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewWillDisappear_Imp)(self, _cmd, animated);
 
    /*
    if (! [self isReadyForLifeCyclePhase:PPViewControllerLifeCyclePhaseViewWillDisappear]) {
        NSLog(@"The viewWillDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
              "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
              "or maybe [super viewWillDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
     */
    
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseViewWillDisappear];
    
#warning Automatic keyboard dismissal ignored
    /*
    // Automatic keyboard dismissal when the view disappears. We test that the view has been loaded to account for the possibility
    // that the view lifecycle has been incorrectly implemented
    if ([self isViewLoaded]) {
        UITextField *currentTextField = [UITextField currentTextField];
        if ([currentTextField isDescendantOfView:self.view]) {
            [currentTextField resignFirstResponder];
        }
        
        UITextView *currentTextView = [UITextView currentTextView];
        if ([currentTextView isDescendantOfView:self.view]) {
            [currentTextView resignFirstResponder];
        }
    }
     */
}

static void swizzled_UIViewController__viewDidDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewDidDisappear_Imp)(self, _cmd, animated);
    
    /*
    if (! [self isReadyForLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidDisappear]) {
        NSLog(@"The viewDidDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
              "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
              "or maybe [super viewDidDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
     */
    
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidDisappear];
}

static void swizzled_UIViewController__viewWillUnload_Imp(UIViewController *self, SEL _cmd)
{
    (s_UIViewController__viewWillUnload_Imp)(self, _cmd);
    
    /*
    if (! [self isReadyForLifeCyclePhase:PPViewControllerLifeCyclePhaseViewWillUnload]) {
        NSLog(@"The viewWillUnload method has been called on %@, but its current view lifecycle state is not compatible. "
              "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
              "or maybe [super viewWillUnload] has not been called by class %@ or one of its parents", self, [self class]);
    }
     */
    
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseViewWillUnload];
}

static void swizzled_UIViewController__viewDidUnload_Imp(UIViewController *self, SEL _cmd)
{
    (s_UIViewController__viewDidUnload_Imp)(self, _cmd);
    
    /*
    if (! [self isReadyForLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidUnload]) {
        NSLog(@"The viewDidUnload method has been called on %@, but its current view lifecycle state is not compatible. "
              "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
              "or maybe [super viewDidUnload] has not been called by class %@ or one of its parents", self, [self class]);
    }
     */
    
    [self setLifeCyclePhase:PPViewControllerLifeCyclePhaseViewDidUnload];
}

