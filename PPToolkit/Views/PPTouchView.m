//
//  PPTouchView.m
//  PPToolkit
//
//  Created by Joachim Kret on 20.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPTouchView.h"

@implementation PPTouchView

@synthesize receiver = _receiver;

#pragma mark Touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        return self.receiver;
    }
    
    return nil;
}

@end
