//
//  PPGradientLayer.h
//  PPToolkit
//
//  Created by Joachim Kret on 19.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum {
    PPGradientStyleLinear   = 0,
    PPGradientStyleRadial
} PPGradientStyle;

@interface PPGradientLayer : CALayer

@property (nonatomic, readwrite, assign) PPGradientStyle gradientStyle;
@property (nonatomic, readwrite, copy) NSArray * colors;
@property (nonatomic, readwrite, copy) NSArray * locations;
@property (nonatomic, readwrite, assign) CGPoint startPoint;
@property (nonatomic, readwrite, assign) CGPoint endPoint;

@end
