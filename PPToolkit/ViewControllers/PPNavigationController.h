//
//  PPNavigationController.h
//  PPToolkit
//
//  Created by Joachim Kret on 07.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPNavigationController;

#pragma mark - PPNavigationBar

@interface PPNavigationBar : UINavigationBar

@property (nonatomic, readonly, strong) CALayer * colorLayer;
@property (nonatomic, readonly, strong) CAGradientLayer * gradientLayer;

- (void)setCustomBarTintColor:(UIColor *)barTintColor;
- (void)setCustomBarTintGradientColors:(NSArray *)gradientColors;

@end

#pragma mark - PPNavigationControllerDelegate

@protocol PPNavigationControllerDelegate <UINavigationControllerDelegate>

@optional
- (void)navigationController:(PPNavigationController *)navigationController didPushToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(PPNavigationController *)navigationController didPopToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(PPNavigationController *)navigationController didSetViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end

#pragma mark - PPNavigationController

@interface PPNavigationController : UINavigationController {
@protected
    struct {
        unsigned int appearsFirstTime           : 1;    //navigation controller appears first time
    } _PPNavigationControllerFlags;
}

@property (nonatomic, readonly, assign) BOOL appearsFirstTime;
@property (nonatomic, readwrite, assign) id <PPNavigationControllerDelegate> delegate;

+ (Class)defaultNavigationBarClass;

@end
