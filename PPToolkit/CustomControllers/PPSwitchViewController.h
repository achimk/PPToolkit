//
//  PPSwitchViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 17.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPViewController.h"

#pragma mark - PPSwitchViewController

@interface PPSwitchViewController : PPViewController {
@protected
    UIView              * _contentView;
    UIViewController    * _selectedViewController;
    NSArray             * _viewControllers;
    NSUInteger          _selectedIndex;
}

@property (nonatomic, readwrite, strong) IBOutlet UIView * contentView;
@property (nonatomic, readwrite, strong) UIViewController * selectedViewController;
@property (nonatomic, readwrite, assign) NSUInteger selectedIndex;
@property (nonatomic, readwrite, copy) NSArray * viewControllers;

+ (Class)defaultContentViewClass;
+ (UIEdgeInsets)defaultContentViewEdgeInsets;

@end

#pragma mark - PPSwitchViewController (SubclassOnly)

@interface PPSwitchViewController (SublassOnly)

- (CGRect)frameForContentView;

@end
