//
//  PPCollectionCellBackgroundView.h
//  PPToolkit
//
//  Created by Joachim Kret on 12.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPCollectionCellBackgroundView : UIView

@property (nonatomic, readwrite, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

- (void)finishInitialize;

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (UIColor *)borderColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIColor *)backgroundColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
