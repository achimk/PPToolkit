//
//  PPSegmentedViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 17.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPSegmentedViewController.h"

#define kDefaultSegmentedControlHeight      49.0f

#pragma mark - PPSegmentedViewController

@interface PPSegmentedViewController ()

@end

#pragma mark -

@implementation PPSegmentedViewController

@synthesize segmentedControl = _segmentedControl;

+ (Class)defaultSegmentedControlClass {
    return [UISegmentedControl class];
}

+ (UIEdgeInsets)defaultSegmentedControlEdgeInsets {
    return UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
}

+ (PPSegmentedViewControllerPosition)defaultSegmentedViewControllerPosition {
    return PPSegmentedViewControllerPositionTop;
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!_segmentedControl) {
        CGRect frame = self.frameForSegmentedControl;
        self.segmentedControl = [[[[self class] defaultSegmentedControlClass] alloc] initWithFrame:frame];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if (!self.segmentedControl.superview) {
        self.segmentedControl.frame = self.frameForSegmentedControl;
        self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.segmentedControl];
    }
}

- (void)releaseViews {
    [super releaseViews];
    self.segmentedControl = nil;
}

#pragma mark Accessors

- (void)setSegmentedControl:(UISegmentedControl *)segmentedControl {
    if (segmentedControl != _segmentedControl) {
        if (_segmentedControl) {
            [_segmentedControl removeFromSuperview];
        }
        
        _segmentedControl = segmentedControl;
    }
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[[[self class] defaultSegmentedControlClass] alloc] initWithFrame:CGRectZero];
        _segmentedControl.selectedSegmentIndex = -1;
        [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentedControl;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [self.segmentedControl removeAllSegments];
    _viewControllers = [viewControllers copy];
    
    for (NSUInteger i = 0; i < _viewControllers.count; i++) {
        UIViewController * viewController = viewControllers[i];
        [self.segmentedControl insertSegmentWithTitle:viewController.title atIndex:i animated:NO];
    }
    
    if (_viewControllers.count && !self.appearsFirstTime) {
        self.selectedViewController = _viewControllers[0];
    }
    else {
        self.selectedViewController = nil;
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    [super setSelectedViewController:selectedViewController];
    
    self.segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:selectedViewController];
}

#pragma mark Actions

- (IBAction)segmentedControlValueChanged:(id)sender {
    self.selectedIndex = self.segmentedControl.selectedSegmentIndex;
}

@end

#pragma mark -

@implementation PPSegmentedViewController (SublassOnly)

- (CGRect)frameForContentView {
    CGRect rect = CGRectZero;
    
    if (PPSegmentedViewControllerPositionTop == [[self class] defaultSegmentedViewControllerPosition]) {
        rect = CGRectMake(0.0f, floorf(kDefaultSegmentedControlHeight), self.view.bounds.size.width, self.view.bounds.size.height - kDefaultSegmentedControlHeight);
    }
    else {
        rect = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - kDefaultSegmentedControlHeight);
    }
    
    return UIEdgeInsetsInsetRect(rect, [[self class] defaultContentViewEdgeInsets]);
}

- (CGRect)frameForSegmentedControl {
    CGRect rect = CGRectZero;
    CGSize size = [self.segmentedControl sizeThatFits:self.view.bounds.size];
    
    if (PPSegmentedViewControllerPositionTop == [[self class] defaultSegmentedViewControllerPosition]) {
        rect = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, size.height);
    }
    else {
        rect = CGRectMake(0.0f, floorf(self.view.bounds.size.height - kDefaultSegmentedControlHeight), self.view.bounds.size.width, size.height);
    }
    
    rect = UIEdgeInsetsInsetRect(rect, [[self class] defaultSegmentedControlEdgeInsets]);
    rect.origin.y = floorf((kDefaultSegmentedControlHeight - rect.size.height) * 0.5f + rect.origin.y);
    
    return rect;
}

@end
