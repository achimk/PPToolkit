//
//  PPTableCellBackgroundView.m
//  PPToolkit
//
//  Created by Joachim Kret on 06.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPTableCellBackgroundView.h"

#import "PPTableViewCell.h"

#define kDefaultCornerRadius            5.0f
#define kDefaultBorderWidth             2.0f
#define kDefaultSeparatorHeight         1.0f

@interface PPTableCellBackgroundView () {
    NSMutableDictionary     * _borderColorDictionary;
    NSMutableDictionary     * _highlightColorDictionary;
    NSMutableDictionary     * _separatorColorDictionary;
    NSMutableDictionary     * _backgroundColorDictionary;
}

@property (nonatomic, readwrite, assign) PPTableCellBackgroundViewPosition position;

- (CGPathRef)_createPathInRect:(CGRect)rect withCellBackgroundViewPosition:(PPTableCellBackgroundViewPosition)position;
- (void)_setValue:(id)value inStateDictionary:(NSMutableDictionary *)stateDictionary forState:(UIControlState)state;
- (id)_valueInStateDictionary:(NSDictionary *)stateDictionary forState:(UIControlState)state;

@end

#pragma mark -

@implementation PPTableCellBackgroundView

@synthesize position = _position;
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
    _highlightColorDictionary = [NSMutableDictionary new];
    _separatorColorDictionary = [NSMutableDictionary new];
    _backgroundColorDictionary = [NSMutableDictionary new];
}

#pragma mark Accessors

- (void)setPosition:(PPTableCellBackgroundViewPosition)position {
    if (position != _position) {
        _position = position;
        [self setNeedsDisplay];
    }
}

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

- (void)setHighlightColor:(UIColor *)highlightColor forState:(UIControlState)state {
    [self _setValue:highlightColor inStateDictionary:_highlightColorDictionary forState:state];
    [self setNeedsDisplay];
}

- (void)setSeparatorColor:(UIColor *)separatorColor forState:(UIControlState)state {
    [self _setValue:separatorColor inStateDictionary:_separatorColorDictionary forState:state];
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self _setValue:backgroundColor inStateDictionary:_backgroundColorDictionary forState:state];
    [self setNeedsDisplay];
}

- (UIColor *)borderColorForState:(UIControlState)state {
    return [self _valueInStateDictionary:_borderColorDictionary forState:state];
}

- (UIColor *)highlightColorForState:(UIControlState)state {
    return [self _valueInStateDictionary:_highlightColorDictionary forState:state];
}

- (UIColor *)separatorColorForState:(UIControlState)state {
    return [self _valueInStateDictionary:_separatorColorDictionary forState:state];
}

- (UIColor *)backgroundColorForState:(UIControlState)state {
    return [self _valueInStateDictionary:_backgroundColorDictionary forState:state];
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];

    UITableView * tableView = nil;
    NSIndexPath * indexPath = nil;
   
#if IS_iOS7_SDK
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        tableView = (UITableView *)self.superview.superview.superview.superview;
        indexPath = [tableView indexPathForCell:(UITableViewCell *)self.superview.superview];
    }
    else {
        tableView = (UITableView *)self.superview.superview;
        indexPath = [tableView indexPathForCell:(UITableViewCell *)self.superview];
    }
#else
    tableView = (UITableView *)self.superview.superview;
    indexPath = [tableView indexPathForCell:(UITableViewCell *)self.superview];
#endif
    
    if (1 == [tableView numberOfRowsInSection:indexPath.section]) {
        self.position = PPTableCellBackgroundViewPositionSingle;
    }
    else if (0 == indexPath.row) {
        self.position = PPTableCellBackgroundViewPositionTop;
    }
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        self.position = PPTableCellBackgroundViewPositionBottom;
    }
    else {
        self.position = PPTableCellBackgroundViewPositionMiddle;
    }
}

#pragma mark Drawing

- (void)drawRect:(CGRect)aRect {
    UITableView * tableView = nil;
    UITableViewCell * cell = nil;
    UIControlState controlState = UIControlStateNormal;
    
#if IS_iOS7_SDK
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        tableView = (UITableView *)self.superview.superview.superview.superview;
        cell = (UITableViewCell *)self.superview.superview;
    }
    else {
        tableView = (UITableView *)self.superview.superview;
        cell = (UITableViewCell *)self.superview;
    }
#else
    tableView = (UITableView *)self.superview.superview;
    cell = (UITableViewCell *)self.superview;
#endif
    
    if ([cell isKindOfClass:[PPTableViewCell class]]) {
        controlState = [(PPTableViewCell *)cell controlState];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    CGContextSaveGState(context);
    
    if (UITableViewStyleGrouped == tableView.style) {
        UIColor * borderColor = [self borderColorForState:controlState];
        UIColor * backgroundColor = [self backgroundColorForState:controlState];

        CGPathRef path = [self _createPathInRect:self.bounds withCellBackgroundViewPosition:self.position];
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithCGPath:path];
        CGPathRelease(path);

        if (backgroundColor) {
            [backgroundColor setFill];
            [bezierPath fill];
        }

        if (borderColor) {
            [borderColor setStroke];
            [bezierPath setLineWidth:kDefaultBorderWidth];
            [bezierPath stroke];
        }
        
        if (PPTableCellBackgroundViewPositionSingle != self.position &&
            PPTableCellBackgroundViewPositionBottom != self.position) {
            
            UIColor * separatorColor = ([self separatorColorForState:controlState]) ?: ((backgroundColor) ?: (borderColor) ?: nil);
            
            if (separatorColor) {
                [separatorColor setFill];
                
                if (borderColor) {
                    UIRectFill(CGRectMake(floorf(kDefaultBorderWidth * 0.5f), floorf(self.bounds.size.height - kDefaultSeparatorHeight), self.bounds.size.width - kDefaultBorderWidth, kDefaultSeparatorHeight));
                }
                else {
                    UIRectFill(CGRectMake(0.0f, floorf(self.bounds.size.height - kDefaultSeparatorHeight), self.bounds.size.width, kDefaultSeparatorHeight));
                }
            }
        }
        
    }
    else {
        UIColor * backgroundColor = [self backgroundColorForState:controlState];
        
        if (backgroundColor) {
            [backgroundColor setFill];
            UIRectFill(self.bounds);
        }
        
        UIColor * highlightColor = [self highlightColorForState:controlState];
        
        if (highlightColor) {
            [highlightColor setFill];
            UIRectFill(CGRectMake(0.0f, 0.0f, self.bounds.size.width, kDefaultSeparatorHeight));
        }
        
        UIColor * separatorColor = [self separatorColorForState:controlState];
        
        if (separatorColor) {
            [separatorColor setFill];
            UIRectFill(CGRectMake(0.0f, floorf(self.bounds.size.height - kDefaultSeparatorHeight), self.bounds.size.width, kDefaultSeparatorHeight));
        }
    }
    
    CGContextRestoreGState(context);
}

#pragma mark Private Methods

- (CGPathRef)_createPathInRect:(CGRect)rect withCellBackgroundViewPosition:(PPTableCellBackgroundViewPosition)position {
    NSAssert(!CGRectEqualToRect(rect, CGRectZero), @"Try to create path for zero rect");
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat minX = floorf(CGRectGetMinX(rect));
    CGFloat midX = floorf(CGRectGetMidX(rect));
    CGFloat maxX = floorf(CGRectGetMaxX(rect));
    CGFloat minY = floorf(CGRectGetMinY(rect));
    CGFloat midY = floorf(CGRectGetMidY(rect));
    CGFloat maxY = floorf(CGRectGetMaxY(rect));
    minY -= 1.0f;
    
    if (PPTableCellBackgroundViewPositionSingle == position) {
        minY += 1.0f;
        CGPathMoveToPoint(path, NULL, minX, midY);
		CGPathAddArcToPoint(path, NULL, minX, minY, midX, minY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, midY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, maxY, midX, maxY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, minX, maxY, minX, midY, self.cornerRadius);
    }
    else if (PPTableCellBackgroundViewPositionTop == position) {
        minY += 1.0f;
        CGPathMoveToPoint(path, NULL, minX, maxY);
		CGPathAddArcToPoint(path, NULL, minX, minY, midX, minY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, maxY, self.cornerRadius);
		CGPathAddLineToPoint(path, NULL, maxX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, maxY);
    }
    else if (PPTableCellBackgroundViewPositionMiddle == position) {
        CGPathMoveToPoint(path, NULL, minX, minY);
		CGPathAddLineToPoint(path, NULL, maxX, minY);
		CGPathAddLineToPoint(path, NULL, maxX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, minY);
    }
    else if (PPTableCellBackgroundViewPositionBottom == position) {
        CGPathMoveToPoint(path, NULL, minX, minY);
		CGPathAddArcToPoint(path, NULL, minX, maxY, midX, maxY, self.cornerRadius);
		CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, minY, self.cornerRadius);
		CGPathAddLineToPoint(path, NULL, maxX, minY);
		CGPathAddLineToPoint(path, NULL, minX, minY);
    }
    else {
        NSAssert1(NO, @"Unsupported cell background view position: %d", position);
    }
    
    CGPathCloseSubpath(path);
    return path;
}

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
