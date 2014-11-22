//
//  CAAnimation+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 18.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (PPToolkitAdditions)

- (void)pp_setStartBlock:(void(^)(void))block;
- (void(^)(void))pp_startBlock;

- (void)pp_setCompletionBlock:(void(^)(BOOL finished))block;
- (void(^)(BOOL finished))pp_completionBlock;

@end
