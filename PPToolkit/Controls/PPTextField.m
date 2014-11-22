//
//  PPTextField.m
//  PPToolkit
//
//  Created by Joachim Kret on 16.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPTextField.h"

#import "PPDrawingUtilities.h"

@implementation PPTextField

@synthesize placeholderTextColor = _placeholderTextColor;
@synthesize textEdgeInsets = _textEdgeInsets;
@synthesize clearButtonEdgeInsets = _clearButtonEdgeInsets;

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)finishInitialize {
    _textEdgeInsets = UIEdgeInsetsZero;
    _clearButtonEdgeInsets = UIEdgeInsetsZero;
}

#pragma mark Accessors

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    if (placeholderTextColor != _placeholderTextColor) {
        _placeholderTextColor = placeholderTextColor;
        
        if (!self.text && self.placeholder) {
            [self setNeedsDisplay];
        }
    }
}

#pragma mark Rect

- (CGRect)textRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], self.textEdgeInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect rect = [super clearButtonRectForBounds:bounds];
    rect.origin.x = floorf(rect.origin.x + self.clearButtonEdgeInsets.right);
    rect.origin.y = floorf(rect.origin.y + self.clearButtonEdgeInsets.top);
    return rect;
}

#pragma mark Drawing

- (void)drawPlaceholderInRect:(CGRect)rect {
    if (self.placeholderTextColor) {
        [self.placeholderTextColor set];
        CGSize size = [self.placeholder sizeWithFont:self.font constrainedToSize:rect.size];
        CGFloat height = floorf((rect.size.height - size.height) * 0.5f);
        rect.origin.y = rect.origin.y + height;
        rect.size.height -= height;

        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
    }
    else {
        [super drawPlaceholderInRect:rect];
    }    
}

@end
