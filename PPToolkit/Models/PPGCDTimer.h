//
//  PPGCDTimer.h
//  PPToolkit
//
//  Created by Joachim Kret on 16.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PPTimerProtocol.h"

@interface PPGCDTimer : NSObject <PPTimerProtocol>

@property (nonatomic, readonly, assign) NSTimeInterval timeInterval;

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue;

@end
