//
//  PPKeyboardViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 07.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPKeyboardViewController.h"

#import "PPToolkitDefines.h"
#import "UIScreen+PPToolkitAdditions.h"

@interface PPKeyboardViewController ()
@property (nonatomic, readwrite, strong) UITextField * currentFirstResponder;
- (UIScrollView *)_findScrollViewForView:(UIView *)view;
@end

#pragma mark -

@implementation PPKeyboardViewController {
    CGFloat         _animatedDistance;
    UIEdgeInsets    _scrollViewContentInset;
}

@synthesize currentFirstResponder = _currentFirstResponder;

#pragma mark View

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissKeyboardAction:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Actions

- (IBAction)dismissKeyboardAction:(id)sender {
    if (self.currentFirstResponder) {
        [self.currentFirstResponder resignFirstResponder];
    }
}

#pragma mark Keyboard

- (BOOL)shouldAcceptScrollView:(UIScrollView *)scrollView forKeyboardNotification:(NSNotification *)aNotification {
    return (nil != scrollView);
}

#pragma mark Notifications

- (void)keyboardWillShowNotification:(NSNotification *)aNotification {
    UIScrollView * scrollView = [self _findScrollViewForView:self.currentFirstResponder];

    if (![self shouldAcceptScrollView:scrollView forKeyboardNotification:aNotification]) {
        return;
    }
    else {
        [self keyboardWillHideNotification:nil];
        _animatedDistance = 0.0f;
        _scrollViewContentInset = scrollView.contentInset;
    }
    
    CGRect scrollViewRect = scrollView.frame;
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIView * topLevelView = [[self.view.window subviews] objectAtIndex:0];
    keyboardRect = [self.view.superview convertRect:keyboardRect fromView:topLevelView];
    
    if (keyboardRect.origin.y < (scrollViewRect.origin.y + scrollViewRect.size.height)) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _animatedDistance = scrollViewRect.origin.y + scrollViewRect.size.height - keyboardRect.origin.y - scrollViewRect.origin.y;
            _animatedDistance += [UIScreen pp_statusBarHeight];
            
            if (self.navigationController && !self.navigationController.isNavigationBarHidden && self.navigationController.navigationBar.isOpaque) {
                _animatedDistance += self.navigationController.navigationBar.frame.size.height;
            }
        }
        else {
            _animatedDistance = scrollViewRect.origin.y + scrollViewRect.size.height - keyboardRect.origin.y - scrollViewRect.origin.y;
        }
        
        scrollViewRect.size.height = keyboardRect.origin.y - scrollViewRect.origin.y;
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.bottom += _animatedDistance;
        
        UIViewAnimationCurve curve = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        CGFloat duration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDuration:duration];
        scrollView.scrollIndicatorInsets = scrollView.contentInset = contentInset;
        [UIView commitAnimations];
    }
    
    CGFloat height = (scrollViewRect.size.height - self.currentFirstResponder.frame.size.height) * 0.5f;
    CGRect textFieldRect = [scrollView convertRect:self.currentFirstResponder.bounds fromView:self.currentFirstResponder];
    CGPoint offset = CGPointMake(0.0f, textFieldRect.origin.y - height);
    
    if (0.0f > offset.y) {
        offset.y = 0.0f;
    }
    
    [scrollView setContentOffset:offset animated:YES];
}

- (void)keyboardWillHideNotification:(NSNotification *)aNotification {
    if (!_animatedDistance) {
        return;
    }

    UIScrollView * scrollView = [self _findScrollViewForView:self.currentFirstResponder];
    
    if (![self shouldAcceptScrollView:scrollView forKeyboardNotification:aNotification]) {
        return;
    }
    
    CGRect scrollViewRect = scrollView.frame;
    scrollViewRect.size.height += _animatedDistance;
    _animatedDistance = 0.0f;
    
    UIEdgeInsets contentInset = _scrollViewContentInset;
    _scrollViewContentInset = UIEdgeInsetsZero;
    
    UIViewAnimationCurve curve = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat duration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    scrollView.scrollIndicatorInsets = scrollView.contentInset = contentInset;
    [UIView commitAnimations];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIScrollView * scrollView = [self _findScrollViewForView:textField];
    BOOL shouldScrollToVisible = (scrollView && 0.0f != _animatedDistance && self.currentFirstResponder.inputView == textField.inputView);
    
    if (shouldScrollToVisible) {
        CGRect scrollViewRect = scrollView.frame;
        CGFloat height = (scrollViewRect.size.height - textField.frame.size.height - _animatedDistance) * 0.5f;
        CGRect textFieldRect = [scrollView convertRect:textField.bounds fromView:textField];
        CGPoint offset = CGPointMake(0.0f, textFieldRect.origin.y - height);
        
        if (0.0f > offset.y) {
            offset.y = 0.0f;
        }
        
        [scrollView setContentOffset:offset animated:YES];
    }
    
    self.currentFirstResponder = textField;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.currentFirstResponder) {
        self.currentFirstResponder = nil;
    }
}

#pragma mark Private Methods

- (UIScrollView *)_findScrollViewForView:(UIView *)view {
    while (view && ![view isKindOfClass:[UIScrollView class]]) {
        view = [view superview];
    }
    return (UIScrollView *)view;
}

@end
