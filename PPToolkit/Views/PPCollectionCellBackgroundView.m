//
//  PPCollectionCellBackgroundView.m
//  PPToolkit
//
//  Created by Joachim Kret on 12.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPCollectionCellBackgroundView.h"

#import "PPCollectionViewCell.h"

#define kDefaultCornerRadius            10.0f
#define kDefaultBorderWidth             2.0f

@interface PPCollectionCellBackgroundView () {
    NSMutableDictionary     * _borderColorDictionary;
    NSMutableDictionary     * _backgroundColorDictionary;
}

- (void)_setValue:(id)value inStateDictionary:(NSMutableDictionary *)stateDictionary forState:(UIControlState)state;
- (id)_valueInStateDictionary:(NSDictionary *)stateDictionary forState:(UIControlState)state;

@end

#pragma mark -

@implementation PPCollectionCellBackgroundView

@synthesize cornerRadius = _cornerRadius;

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
    self.opaque = NO;
    self.backgroundColor = nil;
    self.contentMode = UIViewContentModeRedraw; //needs redraw content on rotate
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _cornerRadius = kDefaultCornerRadius;
    _borderColorDictionary = [NSMutableDictionary new];
    _backgroundColorDictionary = [NSMutableDictionary new];
}

#pragma mark Accessors

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (isgreaterequal(cornerRadius, 0.0f) && islessgreater(cornerRadius, _cornerRadius)) {
        _cornerRadius = cornerRadius;
        [self setNeedsDisplay];
    }
}

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state {
    [self _setValue:borderColor inStateDictionary:_borderColorDictionary forState:state];
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self _setValue:backgroundColor inStateDictionary:_backgroundColorDictionary forState:state];
    [self setNeedsDisplay];
}

- (UIColor *)borderColorForState:(UIControlState)state {
    return [self _valueInStateDictionary:_borderColorDictionary forState:state];
}

- (UIColor *)backgroundColorForState:(UIControlState)state {
    return [self _valueInStateDictionary:_backgroundColorDictionary forState:state];
}

#pragma mark Drawing

- (void)drawRect:(CGRect)dirtyRect {
    id cell = self.superview;
    UIControlState controlState = UIControlStateNormal;
    
    if ([cell isKindOfClass:[PPCollectionViewCell class]]) {
        controlState = [(PPCollectionViewCell *)cell controlStateForBackgroundView:self];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    CGContextSaveGState(context);
    
    UIColor * borderColor = [self borderColorForState:controlState];
    UIColor * backgroundColor = [self backgroundColorForState:controlState];
    
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cornerRadius];
    
    if (backgroundColor) {
        [backgroundColor setFill];
        [bezierPath fill];
    }
    
    if (borderColor) {
        [borderColor setStroke];
        [bezierPath setLineWidth:kDefaultBorderWidth];
        [bezierPath stroke];
    }
    
    CGContextRestoreGState(context);
}

#pragma mark Private Methods

- (void)_setValue:(id)value inStateDictionary:(NSMutableDictionary *)stateDictionary forState:(UIControlState)state {
    NSAssert(UIControlStateNormal == state || UIControlStateHighlighted == state || UIControlStateSelected == state, @"Queried control states must not be bit masks");
    
    static NSArray * __stateNumbers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __stateNumbers = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected)];
    });
    
    for (NSNumber * stateNumber in __stateNumbers) {
        NSUInteger stateInteger = [stateNumber unsignedIntegerValue];
        BOOL statePresentInMask = (UIControlStateNormal == stateInteger) ? (UIControlStateNormal == state) : (stateInteger == (state & stateInteger));
        
        if (statePresentInMask) {
            stateDictionary[stateNumber] = value;
        }
    }
}

- (id)_valueInStateDictionary:(NSDictionary *)stateDictionary forState:(UIControlState)state {
    NSAssert(UIControlStateNormal == state || UIControlStateHighlighted == state || UIControlStateSelected == state, @"Queried control states must not be bit masks");
    
    id stateDictionaryValue = stateDictionary[@(state)];
    
    if (stateDictionaryValue) {
        return stateDictionaryValue;
    }
    else if (UIControlStateSelected == state && stateDictionary[@(UIControlStateHighlighted)]) {
        return stateDictionary[@(UIControlStateHighlighted)];
    }
    else {
        return stateDictionary[@(UIControlStateNormal)];
    }
}

@end
