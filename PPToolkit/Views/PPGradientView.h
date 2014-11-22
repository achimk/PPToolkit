//
//  PPGradientView.h
//  PPToolkit
//
//  Created by Joachim Kret on 19.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PPGradientLayer.h"

#pragma mark - PPGradientView

@interface PPGradientView : UIView

@property (nonatomic, readonly, strong) PPGradientLayer * gradientLayer;
@property (nonatomic, readwrite, copy) NSArray * colors;
@property (nonatomic, readwrite, copy) NSArray * locations;
@property (nonatomic, readwrite, assign) CGPoint startPoint;
@property (nonatomic, readwrite, assign) CGPoint endPoint;
@property (nonatomic, readwrite, assign) PPGradientStyle gradientStyle;

- (void)finishInitialize;

@end
