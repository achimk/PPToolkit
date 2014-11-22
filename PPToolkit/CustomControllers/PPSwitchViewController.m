//
//  PPSwitchViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 17.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPSwitchViewController.h"

#pragma mark - PPSwitchViewController

@interface PPSwitchViewController ()

@end

#pragma mark -

@implementation PPSwitchViewController

@synthesize contentView = _contentView;
@synthesize selectedViewController = _selectedViewController;
@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;

+ (Class)defaultContentViewClass {
    return [UIView class];
}

+ (UIEdgeInsets)defaultContentViewEdgeInsets {
    return UIEdgeInsetsZero;
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!_contentView) {
        CGRect frame = self.frameForContentView;
        self.contentView = [[[[self class] defaultContentViewClass] alloc] initWithFrame:frame];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if (!self.contentView.superview) {
        self.contentView.frame = self.frameForContentView;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.contentView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.appearsFirstTime) {
        if (self.viewControllers.count && !self.selectedViewController) {
            self.selectedViewController = self.viewControllers[0];
        }
    }
}

- (void)releaseViews {
    [super releaseViews];
    self.contentView = nil;
}

#pragma mark Accessors

- (void)setContentView:(UIView *)contentView {
    if (contentView != _contentView) {
        if (_contentView) {
            [_contentView removeFromSuperview];
        }
        
        _contentView = contentView;
    }
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[[[self class] defaultContentViewClass] alloc] initWithFrame:CGRectZero];
    }
    
    return _contentView;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = [viewControllers copy];
    
    if (_viewControllers.count && !self.appearsFirstTime) {
        self.selectedViewController = _viewControllers[0];
    }
    else {
        self.selectedViewController = nil;
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    if (selectedViewController != _selectedViewController &&
        [self.viewControllers containsObject:selectedViewController]) {
     
        if (_selectedViewController) {
            [_selectedViewController willMoveToParentViewController:nil];
            [_selectedViewController.view removeFromSuperview];
            [_selectedViewController removeFromParentViewController];
        }
        
        _selectedViewController = selectedViewController;
        
        if (selectedViewController) {
            [self addChildViewController:selectedViewController];
            selectedViewController.view.frame = self.contentView.bounds;
            [self.contentView addSubview:selectedViewController.view];
            [selectedViewController didMoveToParentViewController:self];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    self.selectedViewController = self.viewControllers[selectedIndex];
}

- (NSUInteger)selectedIndex {
    if (!self.selectedViewController) {
        return [self.viewControllers indexOfObject:self.selectedViewController];
    }
    
    return NSNotFound;
}

@end

#pragma mark -

@implementation PPSwitchViewController (SublassOnly)

- (CGRect)frameForContentView {
    return UIEdgeInsetsInsetRect(self.view.bounds, [[self class] defaultContentViewEdgeInsets]);
}

@end
