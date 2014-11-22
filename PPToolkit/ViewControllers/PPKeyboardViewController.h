//
//  PPKeyboardViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 07.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPViewController.h"

@interface PPKeyboardViewController : PPViewController <UITextFieldDelegate> {
@protected
    UITextField     * _currentFirstResponder;
}

@property (nonatomic, readonly, strong) UITextField * currentFirstResponder;

- (BOOL)shouldAcceptScrollView:(UIScrollView *)scrollView forKeyboardNotification:(NSNotification *)aNotification;

- (IBAction)dismissKeyboardAction:(id)sender;

- (void)keyboardWillShowNotification:(NSNotification *)aNotification;
- (void)keyboardWillHideNotification:(NSNotification *)aNotification;

@end
