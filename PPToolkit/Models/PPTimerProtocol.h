//
//  PPTimerProtocol.h
//  PPToolkit
//
//  Created by Joachim Kret on 16.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PPTimerProtocol <NSObject>

- (void)fire;
- (void)invalidate;

- (BOOL)isValid;
- (NSTimeInterval)timeInterval;

@end
