//
//  PPSheetController.h
//  PPToolkit
//
//  Created by Joachim Kret on 13.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPViewController.h"

@class PPSheetController;
typedef void(^PPSheetControllerCompletion)(BOOL finished);
 
#pragma mark - PPSheetControllerDelegate

@protocol PPSheetControllerDelegate <NSObject>

@optional
- (UIEdgeInsets)containerMarginInsetsInSheetController:(PPSheetController *)sheetController forViewController:(UIViewController *)viewController;
- (UIEdgeInsets)containerPaddingInsetsInSheetController:(PPSheetController *)sheetController forViewController:(UIViewController *)viewController;
- (CGSize)containerSizeInSheetController:(PPSheetController *)sheetController forViewController:(UIViewController *)viewController;

- (void)sheetController:(PPSheetController *)sheetController willPresentViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)sheetController:(PPSheetController *)sheetController didPresentViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)sheetController:(PPSheetController *)sheetController willDismissViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)sheetController:(PPSheetController *)sheetController didDismissViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (BOOL)sheetController:(PPSheetController *)sheetController shouldDismissViewController:(UIViewController *)viewController;

@end

#pragma mark - PPSheetController

@interface PPSheetController : PPViewController {
@protected
    UIViewController        * _contentViewController;
    UITapGestureRecognizer  * _tapGestureRecognizer;
    UIScrollView            * _scrollView;
    UIView                  * _backgroundView;
    UIView                  * _containerView;
    BOOL                    _animating;
    BOOL                    _presented;
}

@property (nonatomic, readonly, strong) UIViewController * contentViewController;
@property (nonatomic, readonly, assign, getter = isAnimating) BOOL animating;
@property (nonatomic, readonly, assign, getter = isPresented) BOOL presented;
@property (nonatomic, readonly, strong) UIScrollView * scrollView;
@property (nonatomic, readonly, strong) UIView * backgroundView;
@property (nonatomic, readonly, strong) UIView * containerView;
@property (nonatomic, readonly, strong) UITapGestureRecognizer * tapGestureRecognizer;

@property (nonatomic, readwrite, assign) BOOL callAppearanceMethods;
@property (nonatomic, readwrite, assign) BOOL animates;
@property (nonatomic, readwrite, assign) NSTimeInterval animationDuration;
@property (nonatomic, readwrite, assign) UIEdgeInsets containerMarginInsets;
@property (nonatomic, readwrite, assign) UIEdgeInsets containerPaddingInsets;
@property (nonatomic, readwrite, assign) CGSize containerSize;

@property (nonatomic, readwrite, weak) id <PPSheetControllerDelegate> delegate;

+ (Class)defaultBackgroundViewClass;
+ (Class)defaultContainerViewClass;

- (id)initWithContentViewController:(UIViewController *)viewController;
- (void)finishInitialize;

- (void)present;
- (void)presentAnimated:(BOOL)animated;
- (void)presentAnimated:(BOOL)animated completion:(PPSheetControllerCompletion)completion;

- (void)presentWithViewController:(UIViewController *)viewController;
- (void)presentWithViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)presentWithViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(PPSheetControllerCompletion)completion;

- (void)presentInViewController:(UIViewController *)viewController;
- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(PPSheetControllerCompletion)completion;

- (void)presentInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController;
- (void)presentInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;
- (void)presentInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(PPSheetControllerCompletion)completion;

- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated completion:(PPSheetControllerCompletion)completion;

@end

#pragma mark - PPSheetController (SubclassOnly)

@interface PPSheetController (SubclassOnly)

- (void)configureViewForScrollView:(UIScrollView *)scrollView;
- (void)configureViewForBackgroundView:(UIView *)backgroundView;
- (void)configureViewForContainerView:(UIView *)containerView;
- (void)configureViewForContentView:(UIView *)contentView;

- (CGRect)backgroundFrameForBounds:(CGRect)bounds;
- (CGRect)contentFrameForBounds:(CGRect)bounds;
- (CGRect)containerFrameForBounds:(CGRect)bounds;
- (CGSize)scrollViewContentSizeForBounds:(CGRect)bounds;
- (CGPoint)scrollViewContentOffsetForBounds:(CGRect)bounds;

- (void)showTransitionInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController completion:(PPSheetControllerCompletion)completion;
- (void)hideTransitionInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController completion:(PPSheetControllerCompletion)completion;

- (IBAction)handleTapGesture:(id)sender;

@end
