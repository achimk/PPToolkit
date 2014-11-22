//
//  PPGradientLayer.m
//  PPToolkit
//
//  Created by Joachim Kret on 19.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPGradientLayer.h"

#pragma mark -

@implementation PPGradientLayer

@synthesize gradientStyle = _gradientStyle;
@synthesize colors = _colors;
@synthesize locations = _locations;
@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;

#pragma mark Accessors

- (void)setGradientStyle:(PPGradientStyle)gradientStyle {
    switch (gradientStyle) {
        case PPGradientStyleLinear:
        case PPGradientStyleRadial: {
            _gradientStyle = gradientStyle;
            [self setNeedsDisplay];
            break;
        }
        default: {
            NSAssert1(NO, @"Unsupported gradient style: %d", gradientStyle);
            break;
        }
    }
}

- (void)setColors:(NSArray *)colors {
    _colors = (colors) ? [colors copy] : nil;
    [self setNeedsDisplay];
}

- (void)setLocations:(NSArray *)locations {
    _locations = (locations) ? [locations copy] : nil;
    [self setNeedsDisplay];
}

- (void)setStartPoint:(CGPoint)startPoint {
    _startPoint = startPoint;
    [self setNeedsDisplay];
}

- (void)setEndPoint:(CGPoint)endPoint {
    _endPoint = endPoint;
    [self setNeedsDisplay];
}

#pragma mark Drawing

- (void)drawInContext:(CGContextRef)context {
    CGContextSaveGState(context);
    
    if (PPGradientStyleLinear == self.gradientStyle) {
        size_t num_locations = self.locations.count;
        
        int numbOfComponents = 0;
        CGColorSpaceRef colorSpace = NULL;
        CATransform3D fullTransform = self.transform;
        CGAffineTransform affine = CGAffineTransformMake(fullTransform.m11, fullTransform.m12, fullTransform.m21, fullTransform.m22, fullTransform.m41, fullTransform.m42);
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, 1, self.startPoint.x, self.startPoint.y));
        CGContextConcatCTM(context, affine);
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, 1, -self.startPoint.x, -self.startPoint.y));
        
        if (self.colors.count) {
            CGColorRef colorRef = (__bridge CGColorRef)[self.colors objectAtIndex:0];
            numbOfComponents = CGColorGetNumberOfComponents(colorRef);
            colorSpace = CGColorGetColorSpace(colorRef);
            
            CGFloat * locations = calloc(num_locations, sizeof(CGFloat));
            CGFloat * components = calloc(num_locations, numbOfComponents * sizeof(CGFloat));
            
            for (int x = 0; x < num_locations; x++) {
                locations[x] = [[self.locations objectAtIndex:x] floatValue];
                const CGFloat *comps = CGColorGetComponents((CGColorRef)[self.colors objectAtIndex:x]);
                
                for (int y = 0; y < numbOfComponents; y++) {
                    int shift = numbOfComponents * x;
                    components[shift + y] = comps[y];
                }
            }
            
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
            CGContextDrawLinearGradient(context, gradient, self.startPoint, self.endPoint, 0);
            
            free(locations);
            free(components);
            CGGradientRelease(gradient);
        }
    }
    else if (PPGradientStyleRadial == self.gradientStyle) {
        size_t num_locations = self.locations.count;
        
        int numbOfComponents = 0;
        CGColorSpaceRef colorSpace = NULL;
        CATransform3D fullTransform = self.transform;
        CGAffineTransform affine = CGAffineTransformMake(fullTransform.m11, fullTransform.m12, fullTransform.m21, fullTransform.m22, fullTransform.m41, fullTransform.m42);
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, 1, self.startPoint.x, self.startPoint.y));
        CGContextConcatCTM(context, affine);
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, 1, -self.startPoint.x, -self.startPoint.y));
        
        if (self.colors.count) {
            CGColorRef colorRef = (__bridge CGColorRef)[self.colors objectAtIndex:0];
            numbOfComponents = CGColorGetNumberOfComponents(colorRef);
            colorSpace = CGColorGetColorSpace(colorRef);
            
            CGFloat * locations = calloc(num_locations, sizeof(CGFloat));
            CGFloat * components = calloc(num_locations, numbOfComponents * sizeof(CGFloat));
            
            for (int x = 0; x < num_locations; x++) {
                locations[x] = [[self.locations objectAtIndex:x] floatValue];
                const CGFloat *comps = CGColorGetComponents((CGColorRef)[self.colors objectAtIndex:x]);
                
                for (int y = 0; y < numbOfComponents; y++) {
                    int shift = numbOfComponents * x;
                    components[shift + y] = comps[y];
                }
            }
            
            CGPoint position = self.startPoint;
            CGFloat radius = (isless(self.bounds.size.width, self.bounds.size.height)) ? floorf(self.endPoint.x * self.bounds.size.width) : floorf(self.endPoint.y * self.bounds.size.height);
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
            
            CGContextDrawRadialGradient(context, gradient, position, 0.0f, position, radius, kCGGradientDrawsAfterEndLocation);
            
            free(locations);
            free(components);
            CGGradientRelease(gradient);
        }
    }
    
    CGContextRestoreGState(context);
}
 
@end
