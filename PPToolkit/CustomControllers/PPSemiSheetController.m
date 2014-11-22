//
//  PPSemiSheetController.m
//  PPCatalog
//
//  Created by Joachim Kret on 18.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPSemiSheetController.h"

#define kDefaultContainerPositon        PPSheetContainerPositionTop

#define kDefaultShowAlphaFrom           0.0f
#define kDefaultShowAlphaTo             1.0f
#define kDefaultHideAlphaFrom           1.0f
#define kDefaultHideAlphaTo             0.0f

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

#pragma mark - PPSemiSheetController

@interface PPSemiSheetController ()
@end

#pragma mark -

@implementation PPSemiSheetController

@synthesize containerPosition = _containerPosition;

#pragma mark Initialize

- (void)finishInitialize {
    [super finishInitialize];
    
    self.containerPosition = kDefaultContainerPositon;
}

#pragma mark Accessors

- (void)setContainerPosition:(PPSheetContainerPosition)containerPosition {
    if (containerPosition != _containerPosition) {
        switch (containerPosition) {
            case PPSheetContainerPositionTop:
            case PPSheetContainerPositionLeft:
            case PPSheetContainerPositionBottom:
            case PPSheetContainerPositionRight: {
                _containerPosition = containerPosition;
                
                if (self.scrollView) {
                    [self configureViewForScrollView:self.scrollView];
                }
                
                break;
            }
            default: {
                NSAssert1(NO, @"Unsupported container position: %d", self.containerPosition);
                break;
            }
        }
    }
}

#pragma mark Subclass Methods

- (void)configureViewForScrollView:(UIScrollView *)scrollView {
    [super configureViewForScrollView:scrollView];
    
    switch (self.containerPosition) {
        case PPSheetContainerPositionTop:
        case PPSheetContainerPositionBottom: {
            scrollView.alwaysBounceVertical = YES;
            scrollView.alwaysBounceHorizontal = NO;
            break;
        }
        case PPSheetContainerPositionLeft:
        case PPSheetContainerPositionRight: {
            scrollView.alwaysBounceVertical = NO;
            scrollView.alwaysBounceHorizontal = YES;
            break;
        }
        default: {
            break;
        }
    }
}

- (void)configureViewForContentView:(UIView *)contentView {
    switch (self.containerPosition) {
        case PPSheetContainerPositionTop: {
            contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            break;
        }
        case PPSheetContainerPositionLeft: {
            contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            break;
        }
        case PPSheetContainerPositionBottom: {
            contentView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            break;
        }
        case PPSheetContainerPositionRight: {
            contentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            break;
        }
        default: {
            break;
        }
    }
}

- (CGRect)containerFrameForBounds:(CGRect)bounds {
    return [self showContainerFrameForBounds:bounds andContainerPosition:self.containerPosition];
}

- (CGRect)showContainerFrameForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition {
    UIEdgeInsets containerPaddingInsets = self.containerPaddingInsets;
    UIEdgeInsets containerMarginInsets = self.containerMarginInsets;
    CGSize containerSize = self.containerSize;
    
    if (CGSizeEqualToSize(containerSize, CGSizeZero)) {
        containerSize = bounds.size;
    }
    
    containerSize.width += containerPaddingInsets.left + containerPaddingInsets.right;
    containerSize.height += containerPaddingInsets.top + containerPaddingInsets.bottom;
    
    CGRect containerFrame = CGRectZero;
    containerFrame.size = containerSize;
    
    containerSize.width += containerMarginInsets.left + containerMarginInsets.right;
    containerSize.height += containerMarginInsets.top + containerMarginInsets.bottom;
    
    switch (containerPosition) {
        case PPSheetContainerPositionTop:
        case PPSheetContainerPositionBottom: {
            if (isless(containerSize.width, bounds.size.width)) {
                containerFrame.origin.x = floorf((bounds.size.width - containerSize.width) * 0.5f + containerMarginInsets.left);
            }
            else {
                containerFrame.origin.x = floorf(containerMarginInsets.left);
            }
            
            if (PPSheetContainerPositionTop == containerPosition) {
                containerFrame.origin.y = floorf(containerMarginInsets.top);
            }
            else {
                containerFrame.origin.y = floorf(MAX(containerMarginInsets.top, ([self scrollViewContentSizeForBounds:bounds].height - containerSize.height + containerMarginInsets.top)));
            }
            
            break;
        }
        case PPSheetContainerPositionLeft:
        case PPSheetContainerPositionRight: {
            if (isless(containerSize.height, bounds.size.height)) {
                containerFrame.origin.y = floorf((bounds.size.height - containerSize.height) * 0.5f + containerMarginInsets.top);
            }
            else {
                containerFrame.origin.y = floorf(containerMarginInsets.top);
            }
            
            if (PPSheetContainerPositionLeft == containerPosition) {
                containerFrame.origin.x = floorf(containerPaddingInsets.left);
            }
            else {
                containerFrame.origin.x = floorf(MAX(containerMarginInsets.left, ([self scrollViewContentSizeForBounds:bounds].width - containerSize.width) + containerMarginInsets.left));
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
    return containerFrame;
}

- (CGRect)hideContainerFrameForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition {
    UIEdgeInsets containerPaddingInsets = self.containerPaddingInsets;
    UIEdgeInsets containerMarginInsets = self.containerMarginInsets;
    CGSize containerSize = self.containerSize;
    
    if (CGSizeEqualToSize(containerSize, CGSizeZero)) {
        containerSize = bounds.size;
    }
    
    containerSize.width += containerPaddingInsets.left + containerPaddingInsets.right;
    containerSize.height += containerPaddingInsets.top + containerPaddingInsets.bottom;
    
    CGRect containerFrame = CGRectZero;
    containerFrame.size = containerSize;
    
    containerSize.width += containerMarginInsets.left + containerMarginInsets.right;
    containerSize.height += containerMarginInsets.top + containerMarginInsets.bottom;
    
    switch (containerPosition) {
        case PPSheetContainerPositionTop:
        case PPSheetContainerPositionBottom: {
            if (isless(containerSize.width, bounds.size.width)) {
                containerFrame.origin.x = floorf((bounds.size.width - containerSize.width) * 0.5f + containerMarginInsets.left);
            }
            else {
                containerFrame.origin.x = floorf(containerMarginInsets.left);
            }
            
            if (PPSheetContainerPositionTop == containerPosition) {
                containerFrame.origin.y = floorf(-containerFrame.size.height);
            }
            else {
                containerFrame.origin.y = floorf([self scrollViewContentSizeForBounds:bounds].height);
            }
            
            break;
        }
        case PPSheetContainerPositionLeft:
        case PPSheetContainerPositionRight: {
            if (isless(containerSize.height, bounds.size.height)) {
                containerFrame.origin.y = floorf((bounds.size.height - containerSize.height) * 0.5f + containerMarginInsets.top);
            }
            else {
                containerFrame.origin.y = floorf(containerMarginInsets.top);
            }
            
            if (PPSheetContainerPositionLeft == containerPosition) {
                containerFrame.origin.x = floorf(-containerFrame.size.width);
            }
            else {
                containerFrame.origin.x = floorf([self scrollViewContentSizeForBounds:bounds].width);
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
    return containerFrame;
}

- (CGPoint)scrollViewContentOffsetForBounds:(CGRect)bounds {
    return [self showContentOffsetForBounds:bounds andContainerPosition:self.containerPosition];
}

- (CGPoint)showContentOffsetForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition {
    CGPoint contentOffset = CGPointZero;
    CGSize contentSize = [self scrollViewContentSizeForBounds:bounds];
    
    switch (containerPosition) {
        case PPSheetContainerPositionTop: {
            if (isless(bounds.size.width, contentSize.width)) {
                contentOffset.x = floorf((contentSize.width - bounds.size.width) * 0.5f);
            }
            
            if (isless(bounds.size.height, contentSize.height)) {
                contentOffset.y = floorf(contentSize.height - bounds.size.height);
            }
            
            break;
        }
        case PPSheetContainerPositionLeft: {
            if (isless(bounds.size.width, contentSize.width)) {
                contentOffset.x = floorf(contentSize.width - bounds.size.width);
            }
            
            if (isless(bounds.size.height, contentSize.height)) {
                contentOffset.y = floorf((contentSize.height - bounds.size.height) * 0.5f);
            }
            
            break;
        }
        case PPSheetContainerPositionBottom: {
            if (isless(bounds.size.width, contentSize.width)) {
                contentOffset.x = floorf((contentSize.width - bounds.size.width) * 0.5f);
            }
            
            break;
        }
        case PPSheetContainerPositionRight: {
            if (isless(bounds.size.height, contentSize.height)) {
                contentOffset.y = floorf((contentSize.height - bounds.size.height) * 0.5f);
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
    return contentOffset;
}

- (CGPoint)hideContentOffsetForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition {
    CGPoint contentOffset = CGPointZero;
    
    CGRect containerFrame = [self containerFrameForBounds:bounds];
    CGSize contentSize = [self scrollViewContentSizeForBounds:bounds];
    
    switch (containerPosition) {
        case PPSheetContainerPositionTop: {
            if (isless(bounds.size.width, contentSize.width)) {
                contentOffset.x = floorf((contentSize.width - bounds.size.width) * 0.5f);
            }
            
            if (islessequal(bounds.size.height, contentSize.height)) {
                contentOffset.y = floorf(containerFrame.size.height);
            }
            else {
                contentOffset.y = floorf(contentSize.height + bounds.size.height);
            }
            
            break;
        }
        case PPSheetContainerPositionLeft: {
            if (islessequal(bounds.size.width, contentSize.width)) {
                contentOffset.x = floorf(containerFrame.size.width);
            }
            else {
                contentOffset.x = floorf(contentSize.width + bounds.size.width);
            }
            
            if (isless(bounds.size.height, contentSize.height)) {
                contentOffset.y = floorf((contentSize.height - bounds.size.height) * 0.5f);
            }
            
            break;
        }
        case PPSheetContainerPositionBottom: {
            if (isless(bounds.size.width, contentSize.width)) {
                contentOffset.x = floorf((contentSize.width - bounds.size.width) * 0.5f);
            }
            
            if (islessequal(bounds.size.height, contentSize.height)) {
                contentOffset.y = floorf(-containerFrame.size.height);
            }
            else {
                contentOffset.y = floorf(-bounds.size.height);
            }
            
            break;
        }
        case PPSheetContainerPositionRight: {
            if (islessequal(bounds.size.width, contentSize.width)) {
                contentOffset.x = floorf(-containerFrame.size.width);
            }
            else {
                contentOffset.x = floorf(-bounds.size.width);
            }
            
            if (isless(bounds.size.height, contentSize.height)) {
                contentOffset.y = floorf((contentSize.height - bounds.size.height) * 0.5f);
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
    return contentOffset;
}

- (void)showTransitionInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController completion:(PPSheetControllerCompletion)completion {
    CGPoint showContentOffset = [self showContentOffsetForBounds:self.view.bounds andContainerPosition:self.containerPosition];
    CGPoint hideContentOffset = [self hideContentOffsetForBounds:self.view.bounds andContainerPosition:self.containerPosition];
    
    self.backgroundView.alpha = kDefaultShowAlphaFrom;
    self.scrollView.contentOffset = hideContentOffset;
    
    [UIView animateWithDuration:self.animationDuration * 0.5f animations:^{
        self.backgroundView.alpha = kDefaultShowAlphaTo;
    } completion:NULL];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.scrollView.contentOffset = showContentOffset;
    } completion:completion];
}

- (void)hideTransitionInViewController:(UIViewController *)viewController withContentViewController:(UIViewController *)contentViewController completion:(PPSheetControllerCompletion)completion {
    CGPoint showContentOffset = [self showContentOffsetForBounds:self.view.bounds andContainerPosition:self.containerPosition];
    CGPoint hideContentOffset = [self hideContentOffsetForBounds:self.view.bounds andContainerPosition:self.containerPosition];
    self.backgroundView.alpha = kDefaultHideAlphaFrom;
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.backgroundView.alpha = kDefaultHideAlphaTo;
        self.scrollView.contentOffset = hideContentOffset;
    } completion:^(BOOL finished) {
        self.backgroundView.alpha = kDefaultShowAlphaTo;
        self.scrollView.contentOffset = showContentOffset;
        
        if (completion) {
            completion(finished);
        }
    }];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL needsLayout = NO;
    
    switch (self.containerPosition) {
        case PPSheetContainerPositionTop: {
            needsLayout = isless(scrollView.contentOffset.y, 0.0f);
            break;
        }
        case PPSheetContainerPositionLeft: {
            needsLayout = isless(scrollView.contentOffset.x, 0.0f);
            break;
        }
        case PPSheetContainerPositionBottom: {
            needsLayout = isless(scrollView.contentSize.height, scrollView.contentOffset.y + scrollView.frame.size.height);
            break;
        }
        case PPSheetContainerPositionRight: {
            needsLayout = isless(scrollView.contentSize.width, scrollView.contentOffset.x + scrollView.frame.size.width);
            break;
        }
        default: {
            break;
        }
    }
    
    if (needsLayout) {
        CGRect containerFrame = [self containerFrameForBounds:self.view.bounds];
        
        switch (self.containerPosition) {
            case PPSheetContainerPositionTop: {
                containerFrame.origin.y = floorf(containerFrame.origin.y - fabsf(scrollView.contentOffset.y));
                containerFrame.size.height += fabsf(scrollView.contentOffset.y);
                break;
            }
            case PPSheetContainerPositionLeft: {
                containerFrame.origin.x = floorf(containerFrame.origin.x - fabsf(scrollView.contentOffset.x));
                containerFrame.size.width += fabsf(scrollView.contentOffset.x);
                break;
            }
            case PPSheetContainerPositionBottom: {
                containerFrame.size.height += scrollView.contentOffset.y + 1.0f;
                break;
            }
            case PPSheetContainerPositionRight: {
                containerFrame.size.width += scrollView.contentOffset.x + 1.0f;
                break;
            }
            default: {
                break;
            }
        }
        
        self.containerView.frame = containerFrame;
    }
}

@end
