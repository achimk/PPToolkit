//
//  PPSheetController.m
//  PPToolkit
//
//  Created by Joachim Kret on 13.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPSheetController.h"

#define kDefaultAnimationDuration   0.25f

#define kDefaultShowAlphaFrom       0.0f
#define kDefaultShowAlphaTo         1.0f
#define kDefaultHideAlphaFrom       1.0f
#define kDefaultHideAlphaTo         0.0f

#define kDefaultShowScaleX          1.15f
#define kDefaultShowScaleY          1.15f
#define kDefaultHideScaleX          0.85f
#define kDefaultHideScaleY          0.85f

#pragma mark - PPSheetController

@interface PPSheetController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, strong) UIViewController * contentViewController;
@property (nonatomic, readwrite, assign, getter = isAnimating) BOOL animating;
@property (nonatomic, readwrite, assign, getter = isPresented) BOOL presented;
@property (nonatomic, readwrite, strong) UIScrollView * scrollView;
@property (nonatomic, readwrite, strong) UIView * backgroundView;
@property (nonatomic, readwrite, strong) UIView * containerView;
@property (nonatomic, readwrite, strong) UITapGestureRecognizer * tapGestureRecognizer;

@end

#pragma mark -

@implementation PPSheetController

@synthesize contentViewController = _contentViewController;
@synthesize animating = _animating;
@synthesize presented = _presented;
@synthesize scrollView = _scrollView;
@synthesize backgroundView = _backgroundView;
@synthesize containerView = _containerView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize callAppearanceMethods = _callAppearanceMethods;
@synthesize animates = _animates;
@synthesize animationDuration = _animationDuration;
@synthesize containerMarginInsets = _containerMarginInsets;
@synthesize containerPaddingInsets = _containerPaddingInsets;
@synthesize containerSize = _containerSize;
@synthesize delegate = _delegate;

+ (Class)defaultBackgroundViewClass {
    return [UIView class];
}

+ (Class)defaultContainerViewClass {
    return [UIView class];
}

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self finishInitialize];
    }
    
    return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.contentViewController = viewController;
    }
    
    return self;
}

- (void)finishInitialize {
    self.animates = YES;
    self.animationDuration = kDefaultAnimationDuration;
    self.callAppearanceMethods = YES;
    self.containerMarginInsets = UIEdgeInsetsZero;
    self.containerPaddingInsets = UIEdgeInsetsZero;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    _tapGestureRecognizer.delegate = self;
}

#pragma mark Accessors

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p animating: %@, presented: %@, content: %@ %p>",
            [self class],
            self,
            PPStringFromBool(self.isAnimating),
            PPStringFromBool(self.isPresented),
            [self.contentViewController class],
            self.contentViewController];
}

- (void)setView:(UIView *)view {
    if (self.isViewLoaded) {
        if (self.view) {
            [self.view removeGestureRecognizer:self.tapGestureRecognizer];
        }
        
        [super setView:view];
        
        if (view) {
            [view addGestureRecognizer:self.tapGestureRecognizer];
        }
    }
    else {
        [super setView:view];
        
        if (view) {
            [view addGestureRecognizer:self.tapGestureRecognizer];
        }
    }
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        if (_scrollView) {
            if (_scrollView.superview) {
                [_scrollView removeFromSuperview];
            }
            
            _scrollView.delegate = nil;
        }
        
        _scrollView = scrollView;
        
        if (scrollView) {
            scrollView.delegate = self;
            [self configureViewForScrollView:scrollView];
            
            if (!scrollView.superview) {
                [self.view addSubview:scrollView];
            }
        }
    }
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (backgroundView != _backgroundView) {
        if (_backgroundView && _backgroundView.superview) {
            [_backgroundView removeFromSuperview];
        }
        
        _backgroundView = backgroundView;
        
        if (backgroundView) {
            [self configureViewForBackgroundView:backgroundView];
            
            if (!backgroundView.superview) {
                [self.view addSubview:backgroundView];
            }
        }
    }
}

- (void)setContainerView:(UIView *)containerView {
    if (containerView != _containerView) {
        if (_containerView && _containerView.superview) {
            [_containerView removeFromSuperview];
        }
        
        _containerView = containerView;
        
        if (containerView) {
            [self configureViewForContainerView:containerView];
            
            if (!containerView.superview) {
                [self.scrollView addSubview:containerView];
            }
        }
    }
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!self.isViewLoaded) {
        self.view = [UIView new];
    }
    
    if (!_scrollView) {
        self.scrollView = [UIScrollView new];
    }
    
    if (!_backgroundView) {
        self.backgroundView = [[[self class] defaultBackgroundViewClass] new];
    }
    
    if (!_containerView) {
        self.containerView = [[[self class] defaultContainerViewClass] new];
    }
    
    [self.view bringSubviewToFront:self.scrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillLayoutSubviews {
    if ([self.delegate respondsToSelector:@selector(containerMarginInsetsInSheetController:forViewController:)]) {
        self.containerMarginInsets = [self.delegate containerMarginInsetsInSheetController:self forViewController:self.contentViewController];
    }
    
    if ([self.delegate respondsToSelector:@selector(containerPaddingInsetsInSheetController:forViewController:)]) {
        self.containerPaddingInsets = [self.delegate containerPaddingInsetsInSheetController:self forViewController:self.contentViewController];
    }
    
    if ([self.delegate respondsToSelector:@selector(containerSizeInSheetController:forViewController:)]) {
        self.containerSize = [self.delegate containerSizeInSheetController:self forViewController:self.contentViewController];
    }
    
    if (CGSizeEqualToSize(self.containerSize, CGSizeZero)) {
        self.containerSize = self.contentViewController.view.frame.size;
    }
    
    CGRect bounds = self.parentViewController.view.bounds;
    self.view.frame = bounds;
    self.backgroundView.frame = [self backgroundFrameForBounds:bounds];
    self.scrollView.frame = bounds;
    self.scrollView.contentSize = [self scrollViewContentSizeForBounds:bounds];
    self.scrollView.contentOffset = [self scrollViewContentOffsetForBounds:bounds];
    self.containerView.frame = [self containerFrameForBounds:bounds];
    self.contentViewController.view.frame = [self contentFrameForBounds:bounds];
}

#pragma mark Actions

- (IBAction)handleTapGesture:(id)sender {
    [self dismiss];
}

#pragma mark Present

- (void)present {
    [self presentAnimated:self.animates completion:NULL];
}

- (void)presentAnimated:(BOOL)animated {
    [self presentAnimated:animated completion:NULL];
}

- (void)presentAnimated:(BOOL)animated completion:(PPSheetControllerCompletion)completion {
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    [self presentInViewController:keyWindow.rootViewController
        withContentViewController:self.contentViewController
                         animated:animated
                       completion:completion];
}

- (void)presentWithViewController:(UIViewController *)viewController {
    [self presentWithViewController:viewController animated:self.animates completion:NULL];
}

- (void)presentWithViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self presentWithViewController:viewController animated:animated completion:NULL];
}

- (void)presentWithViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(PPSheetControllerCompletion)completion {
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    [self presentInViewController:keyWindow.rootViewController
        withContentViewController:viewController
                         animated:animated
                       completion:completion];
}

- (void)presentInViewController:(UIViewController *)viewController {
    [self presentInViewController:viewController animated:self.animates completion:NULL];
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self presentInViewController:viewController animated:animated completion:NULL];
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(PPSheetControllerCompletion)completion {
    [self presentInViewController:viewController
        withContentViewController:self.contentViewController
                         animated:animated
                       completion:completion];
}

- (void)presentInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController {
    [self presentInViewController:viewController
        withContentViewController:contentViewController
                         animated:self.animates
                       completion:NULL];
}

- (void)presentInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated {
    [self presentInViewController:viewController
        withContentViewController:contentViewController
                         animated:animated
                       completion:NULL];
}

- (void)presentInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(PPSheetControllerCompletion)completion {
    NSParameterAssert(viewController);
    NSParameterAssert(contentViewController);
    
    if (!viewController || !contentViewController) {
        return;
    }
    
    if (self.isAnimating || self.isPresented) {
        if (completion) {
            completion(NO);
        }
        
        return;
    }

    animated = (animated && isgreater(self.animationDuration, 0.0f));
    self.animating = animated;
    
    if (self.callAppearanceMethods) {
        [contentViewController beginAppearanceTransition:YES animated:animated];
    }
    
    if ([self.delegate respondsToSelector:@selector(sheetController:willPresentViewController:animated:)]) {
        [self.delegate sheetController:self willPresentViewController:contentViewController animated:animated];
    }
    
    [viewController addChildViewController:self];
    [self addChildViewController:contentViewController];
    
    self.contentViewController = contentViewController;
    [self configureViewForContentView:contentViewController.view];
    [viewController.view addSubview:self.view];
    [self.containerView addSubview:contentViewController.view];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    PPSheetControllerCompletion completionBlock = ^(BOOL finished) {
        [contentViewController didMoveToParentViewController:self];
        [self didMoveToParentViewController:viewController];
        
        if (self.callAppearanceMethods) {
            [contentViewController endAppearanceTransition];
        }
        
        if ([self.delegate respondsToSelector:@selector(sheetController:didPresentViewController:animated:)]) {
            [self.delegate sheetController:self didPresentViewController:contentViewController animated:animated];
        }
        
        self.animating = NO;
        self.presented = YES;
        
        if (completion) {
            completion(finished);
        }
    };
    
    if (animated) {
        [self showTransitionInViewController:viewController withContentViewController:contentViewController completion:completionBlock];
    }
    else {
        completionBlock(YES);
    }
}

#pragma mark Dismiss

- (void)dismiss {
    [self dismissAnimated:self.animates completion:NULL];
}

- (void)dismissAnimated:(BOOL)animated {
    [self dismissAnimated:animated completion:NULL];
}

- (void)dismissAnimated:(BOOL)animated completion:(PPSheetControllerCompletion)completion {
    NSAssert(self.contentViewController, @"Content view controller is empty");
    
    if (!self.contentViewController) {
        return;
    }
    
    if (self.isAnimating || !self.isPresented) {
        if (completion) {
            completion(NO);
        }
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(sheetController:shouldDismissViewController:)]) {
        if (![self.delegate sheetController:self shouldDismissViewController:self.contentViewController]) {
            if (completion) {
                completion(NO);
            }
            
            return;
        }
    }
    
    animated = (animated && isgreater(self.animationDuration, 0.0f));
    self.animating = animated;
    
    if (self.callAppearanceMethods) {
        [self.contentViewController beginAppearanceTransition:NO animated:animated];
    }
    
    if ([self.delegate respondsToSelector:@selector(sheetController:willDismissViewController:animated:)]) {
        [self.delegate sheetController:self willDismissViewController:self.contentViewController animated:animated];
    }
    
    [self willMoveToParentViewController:nil];
    [self.contentViewController willMoveToParentViewController:nil];
    
    PPSheetControllerCompletion completionBlock = ^(BOOL finished) {
        [self.contentViewController.view removeFromSuperview];
        [self.contentViewController removeFromParentViewController];
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        if (self.callAppearanceMethods) {
            [self.contentViewController endAppearanceTransition];
        }
        
        if ([self.delegate respondsToSelector:@selector(sheetController:didDismissViewController:animated:)]) {
            [self.delegate sheetController:self didDismissViewController:self.contentViewController animated:animated];
        }
        
        self.animating = NO;
        self.presented = NO;
        self.containerSize = CGSizeZero;
        
        if (completion) {
            completion(finished);
        }
    };
    
    if (animated) {
        [self hideTransitionInViewController:self.parentViewController withContentViewController:self.contentViewController completion:completionBlock];
    }
    else {
        completionBlock(YES);
    }
}

#pragma mark Subclass Methods

- (void)configureViewForScrollView:(UIScrollView *)scrollView {
    scrollView.bounces = YES;
    scrollView.pagingEnabled = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor clearColor];
}

- (void)configureViewForBackgroundView:(UIView *)backgroundView {
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)configureViewForContainerView:(UIView *)containerView {
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)configureViewForContentView:(UIView *)contentView {
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (CGRect)backgroundFrameForBounds:(CGRect)bounds {
    return bounds;
}

- (CGRect)contentFrameForBounds:(CGRect)bounds {
    UIEdgeInsets containerPaddingInsets = self.containerPaddingInsets;
    CGRect contentFrame = CGRectZero;
    contentFrame.origin.x = floorf(containerPaddingInsets.left);
    contentFrame.origin.y = floorf(containerPaddingInsets.top);
    contentFrame.size = self.containerSize;
    
    if (CGSizeEqualToSize(contentFrame.size, CGSizeZero)) {
        contentFrame.size = bounds.size;
    }
    
    return contentFrame;
}

- (CGRect)containerFrameForBounds:(CGRect)bounds {
    UIEdgeInsets containerPaddingInsets = self.containerPaddingInsets;
    UIEdgeInsets containerMarginInsets = self.containerMarginInsets;
    CGSize containerSize = self.containerSize;
    
    if (CGSizeEqualToSize(containerSize, CGSizeZero)) {
        containerSize = bounds.size;
    }
    
    containerSize.width += containerPaddingInsets.left + containerPaddingInsets.right;
    containerSize.height += containerPaddingInsets.top + containerPaddingInsets.bottom;
    
    CGRect containerFrame = CGRectZero;
    containerFrame.origin.x = floorf(containerMarginInsets.left);
    containerFrame.origin.y = floorf(containerMarginInsets.top);
    containerFrame.size = containerSize;
    
    containerSize.width += containerMarginInsets.left + containerMarginInsets.right;
    containerSize.height += containerMarginInsets.top + containerMarginInsets.bottom;
    
    if (isless(containerSize.width, bounds.size.width)) {
        containerFrame.origin.x = floorf((bounds.size.width - containerSize.width) * 0.5f + containerMarginInsets.left);
    }
    
    if (isless(containerSize.height, bounds.size.height)) {
        containerFrame.origin.y = floorf((bounds.size.height - containerSize.height) * 0.5f + containerMarginInsets.top);
    }
    
    return containerFrame;
}

- (CGSize)scrollViewContentSizeForBounds:(CGRect)bounds {
    UIEdgeInsets containerPaddingInsets = self.containerPaddingInsets;
    UIEdgeInsets containerMarginInsets = self.containerMarginInsets;
    CGSize containerSize = self.containerSize;
    
    if (CGSizeEqualToSize(containerSize, CGSizeZero)) {
        containerSize = bounds.size;
    }
    
    containerSize.width += containerPaddingInsets.left + containerPaddingInsets.right + containerMarginInsets.left + containerMarginInsets.right;
    containerSize.height += containerPaddingInsets.top + containerPaddingInsets.bottom + containerMarginInsets.top + containerMarginInsets.bottom;
    
    if (isless(containerSize.width, bounds.size.width)) {
        containerSize.width = bounds.size.width;
    }
    
    if (isless(containerSize.height, bounds.size.height)) {
        containerSize.height = bounds.size.height;
    }
    
    return containerSize;
}

- (CGPoint)scrollViewContentOffsetForBounds:(CGRect)bounds {
    return CGPointZero;
}

- (void)showTransitionInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController completion:(PPSheetControllerCompletion)completion {

    self.backgroundView.alpha = kDefaultShowAlphaFrom;
    self.containerView.alpha = kDefaultShowAlphaFrom;
    self.containerView.transform = CGAffineTransformMakeScale(kDefaultShowScaleX, kDefaultShowScaleY);
    
    [UIView animateWithDuration:self.animationDuration * 0.5f animations:^{
        self.backgroundView.alpha = kDefaultShowAlphaTo;
    } completion:NULL];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.containerView.alpha = kDefaultShowAlphaTo;
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:completion];
}

- (void)hideTransitionInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController completion:(PPSheetControllerCompletion)completion {

    self.backgroundView.alpha = kDefaultHideAlphaFrom;
    self.containerView.alpha = kDefaultHideAlphaFrom;
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.backgroundView.alpha = kDefaultHideAlphaTo;
        self.containerView.alpha = kDefaultHideAlphaTo;
        self.containerView.transform = CGAffineTransformMakeScale(kDefaultHideScaleX, kDefaultHideScaleY);
    } completion:^(BOOL finished) {
        self.backgroundView.alpha = kDefaultShowAlphaTo;
        self.containerView.alpha = kDefaultShowAlphaTo;
        self.containerView.transform = CGAffineTransformIdentity;
        
        if (completion) {
            completion(finished);
        }
    }];
}

#pragma mark Orientation Managment

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (self.contentViewController) {
        return [self.contentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    else {
        return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (BOOL)shouldAutorotate {
    if (self.contentViewController) {
        return [self.contentViewController shouldAutorotate];
    }
    else {
        return [super shouldAutorotate];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    if (self.contentViewController) {
        return [self.contentViewController supportedInterfaceOrientations];
    }
    else {
        return [super supportedInterfaceOrientations];
    }
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return !CGRectContainsPoint(self.containerView.frame, [touch locationInView:self.scrollView]);
}

@end
