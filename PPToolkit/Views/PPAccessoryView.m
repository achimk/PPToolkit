//
//  PPAccessoryView.m
//  PPToolkit
//
//  Created by Joachim Kret on 09.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPAccessoryView.h"

#define kAccessoryViewRect              CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)

#define kDisclosureStartX               CGRectGetMaxX(self.bounds) - 7.0f
#define kDisclosureStartY               CGRectGetMidY(self.bounds)
#define kDisclosureRadius               4.5f
#define kDisclosureWidth                3.0f
#define kDisclosureShadowOffset         CGSizeMake(0.0f, -1.0f)
#define kDisclosurePositon              CGPointMake(18.0f, 13.5f)

#define kCheckMarkStartX                kAccessoryViewRect.size.width * 0.5f + 1.0f
#define kCheckMarkStartY                kAccessoryViewRect.size.height * 0.5f - 1.0f
#define kCheckMarkLCGapX                3.5f
#define kCheckMarkLCGapY                5.0f
#define kCheckMarkCRGapX                10.0f
#define kCheckMarkCRGapY                -6.0f
#define kCheckMarkWidth                 2.5f

@interface PPAccessoryView ()
- (void)_finishInitialize;
@end

#pragma mark -

@implementation PPAccessoryView

@synthesize accessoryType = _accessoryType;
@synthesize accessoryColor = _accessoryColor;

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _finishInitialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _finishInitialize];
    }
    
    return self;
}

- (void)_finishInitialize {
    self.accessoryType = kPPAccessoryTypeDisclosureIndicator;
    self.accessoryColor = [UIColor darkGrayColor];
}

#pragma mark Accessors

- (void)setAccessoryType:(PPAccessoryType)accessoryType {
    if (accessoryType != _accessoryType) {
        _accessoryType = accessoryType;
        [self setNeedsDisplay];
    }
}

- (void)setAccessoryColor:(UIColor *)accessoryColor {
    if (accessoryColor != _accessoryColor) {
        _accessoryColor = accessoryColor;
        [self setNeedsDisplay];
    }
}

#pragma mark Frames

- (CGSize)sizeThatFits:(CGSize)size {
    return kAccessoryViewRect.size;
}

#pragma mark Drawing

- (void)drawRect:(CGRect)dirtyRect {
    switch (self.accessoryType) {
        case kPPAccessoryTypeDisclosureIndicator: {
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextMoveToPoint(context, kDisclosureStartX - kDisclosureRadius, kDisclosureStartY - kDisclosureRadius);
            CGContextAddLineToPoint(context, kDisclosureStartX, kDisclosureStartY);
            CGContextAddLineToPoint(context, kDisclosureStartX - kDisclosureRadius, kDisclosureStartY + kDisclosureRadius);
            CGContextSetLineCap(context, kCGLineCapSquare);
            CGContextSetLineJoin(context, kCGLineJoinMiter);
            CGContextSetLineWidth(context, kDisclosureWidth);
            
            if (self.accessoryColor) {
                [self.accessoryColor setStroke];
            }
            
            CGContextStrokePath(context);
             
            break;
        }
        case kPPAccessoryTypeCheckmark: {
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextMoveToPoint(context, kCheckMarkStartX, kCheckMarkStartY);
            CGContextAddLineToPoint(context, kCheckMarkStartX + kCheckMarkLCGapX, kCheckMarkStartY + kCheckMarkLCGapY);
            CGContextAddLineToPoint(context, kCheckMarkStartX + kCheckMarkCRGapX, kCheckMarkStartY + kCheckMarkCRGapY);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextSetLineWidth(context, kCheckMarkWidth);

            if (self.accessoryColor) {
                [self.accessoryColor setStroke];
            }
            
            CGContextStrokePath(context);
            
            break;
        }
        default: {
            break;
        }
    }
}

@end
