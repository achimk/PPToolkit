//
//  CAAnimation+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 18.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "CAAnimation+PPToolkitAdditions.h"

#pragma mark - PPAnimationDelegate

@interface PPAnimationDelegate : NSObject

@property (nonatomic, readwrite, copy) void (^start)(void);
@property (nonatomic, readwrite, copy) void (^completion)(BOOL finished);

- (void)animationDidStart:(CAAnimation *)anim;
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end

@implementation PPAnimationDelegate

@synthesize start = _start;
@synthesize completion = _completion;

#pragma mark CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    if (self.start) {
        self.start();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.completion) {
        self.completion(flag);
    }
}

@end

#pragma mark - CAAnimation (PPToolkitAdditions)

@implementation CAAnimation (PPToolkitAdditions)

- (void)pp_setStartBlock:(void(^)(void))block {
    if (self.delegate && [self.delegate isKindOfClass:[PPAnimationDelegate class]]) {
        PPAnimationDelegate * animationDelegate = (PPAnimationDelegate *)self.delegate;
        animationDelegate.start = block;
    }
    else {
        PPAnimationDelegate * animationDelegate = [PPAnimationDelegate new];
        animationDelegate.start = block;
        self.delegate = animationDelegate;
    }
}

- (void(^)(void))pp_startBlock {
    if (self.delegate && [self.delegate isKindOfClass:[PPAnimationDelegate class]]) {
        PPAnimationDelegate * animationDelegate = (PPAnimationDelegate *)self.delegate;
        return animationDelegate.start;
    }
    
    return NULL;
}

- (void)pp_setCompletionBlock:(void(^)(BOOL finished))block {
    if (self.delegate && [self.delegate isKindOfClass:[PPAnimationDelegate class]]) {
        PPAnimationDelegate * animationDelegate = (PPAnimationDelegate *)self.delegate;
        animationDelegate.completion = block;
    }
    else {
        PPAnimationDelegate * animationDelegate = [PPAnimationDelegate new];
        animationDelegate.completion = block;
        self.delegate = animationDelegate;
    }
}

- (void(^)(BOOL finished))pp_completionBlock {
    if (self.delegate && [self.delegate isKindOfClass:[PPAnimationDelegate class]]) {
        PPAnimationDelegate * animationDelegate = (PPAnimationDelegate *)self.delegate;
        return animationDelegate.completion;
    }
    
    return NULL;
}

@end
