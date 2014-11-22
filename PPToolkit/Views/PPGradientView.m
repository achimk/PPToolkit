//
//  PPGradientView.m
//  PPToolkit
//
//  Created by Joachim Kret on 19.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPGradientView.h"

#pragma mark - PPGradientView

@implementation PPGradientView

@dynamic gradientLayer;
@dynamic colors;
@dynamic locations;
@dynamic startPoint;
@dynamic endPoint;
@dynamic gradientStyle;

+ (Class)layerClass {
    return [PPGradientLayer class];
}

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
}

#pragma mark Accessors

- (PPGradientLayer *)gradientLayer {
    if ([self.layer isKindOfClass:[PPGradientLayer class]]) {
        return (PPGradientLayer *)self.layer;
    }
    
    return nil;
}

- (void)setColors:(NSArray *)colors {
    if (self.gradientLayer) {
        self.gradientLayer.colors = colors;
        [self setNeedsDisplay];
    }
}

- (NSArray *)colors {
    return (self.gradientLayer) ? self.gradientLayer.colors : nil;
}

- (void)setLocations:(NSArray *)locations {
    if (self.gradientLayer) {
        self.gradientLayer.locations = locations;
        [self setNeedsDisplay];
    }
}

- (NSArray *)locations {
    return (self.gradientLayer) ? self.gradientLayer.locations : nil;
}

- (void)setStartPoint:(CGPoint)startPoint {
    if (self.gradientLayer) {
        self.gradientLayer.startPoint = startPoint;
        [self setNeedsDisplay];
    }
}

- (CGPoint)startPoint {
    return (self.gradientLayer) ? self.gradientLayer.startPoint : CGPointZero;
}

- (void)setEndPoint:(CGPoint)endPoint {
    if (self.gradientLayer) {
        self.gradientLayer.endPoint = endPoint;
        [self setNeedsDisplay];
    }
}

- (CGPoint)endPoint {
    return (self.gradientLayer) ? self.gradientLayer.endPoint : CGPointZero;
}

- (void)setGradientStyle:(PPGradientStyle)gradientStyle {
    if (self.gradientLayer) {
        self.gradientLayer.gradientStyle = gradientStyle;
        
        switch (gradientStyle) {
            case PPGradientStyleLinear: {
                self.startPoint = CGPointMake(0.0f, 0.0f);
                self.endPoint = CGPointMake(0.0f, self.bounds.size.height);
                break;
            }
            case PPGradientStyleRadial: {
                self.startPoint = CGPointMake(floorf(self.bounds.size.width * 0.5f), floorf(self.bounds.size.height * 0.5f));
                CGFloat scale = (isless(self.bounds.size.width, self.bounds.size.height)) ? floorf(self.bounds.size.height / self.bounds.size.width) : floorf(self.bounds.size.width / self.bounds.size.height);
                self.endPoint = CGPointMake(scale, scale);
                break;
            }
            default: {
                break;
            }
        }
        
        [self setNeedsDisplay];
    }
}

- (PPGradientStyle)gradientStyle {
    return (self.gradientLayer) ? self.gradientLayer.gradientStyle : NSNotFound;
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    switch (self.gradientStyle) {
        case PPGradientStyleLinear: {
            self.startPoint = CGPointMake(0.0f, 0.0f);
            self.endPoint = CGPointMake(0.0f, self.bounds.size.height);
            break;
        }
        case PPGradientStyleRadial: {
            self.startPoint = CGPointMake(floorf(self.bounds.size.width * 0.5f), floorf(self.bounds.size.height * 0.5f));
            CGFloat scale = (isless(self.bounds.size.width, self.bounds.size.height)) ? floorf(self.bounds.size.height / self.bounds.size.width) : floorf(self.bounds.size.width / self.bounds.size.height);
            self.endPoint = CGPointMake(scale, scale);
            break;
        }
        default: {
            break;
        }
    }
}

@end
