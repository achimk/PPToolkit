//
//  PPTableCellBackgroundView.h
//  PPToolkit
//
//  Created by Joachim Kret on 06.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PPTableCellBackgroundViewPositionSingle = 0,
    PPTableCellBackgroundViewPositionTop,
    PPTableCellBackgroundViewPositionMiddle,
    PPTableCellBackgroundViewPositionBottom
} PPTableCellBackgroundViewPosition;

#pragma mark -

@interface PPTableCellBackgroundView : UIView

@property (nonatomic, readonly, assign) PPTableCellBackgroundViewPosition position;
@property (nonatomic, readwrite, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

- (void)finishInitialize;

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setHighlightColor:(UIColor *)highlightColor forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setSeparatorColor:(UIColor *)separatorColor forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIColor *)borderColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIColor *)highlightColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIColor *)separatorColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIColor *)backgroundColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
