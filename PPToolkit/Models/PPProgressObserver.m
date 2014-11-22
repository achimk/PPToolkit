//
//  PPProgressObserver.m
//  PPCatalog
//
//  Created by Joachim Kret on 26.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPProgressObserver.h"

@implementation PPProgressObserver

@synthesize identifier = _identifier;
@synthesize startingOperationCount = _startingOperationCount;
@synthesize progressBlock = _progressBlock;
@synthesize completionBlock = _completionBlock;

+ (PPProgressObserver *)progressObserverWithStartingOperationCount:(NSUInteger)operationCount progressBlock:(PPProgressObserverProgressBlock)progressBlock completionBlock:(PPProgressObserverCompletionBlock)completionBlock {
    
    PPProgressObserver * observer = [self new];
    observer.startingOperationCount = operationCount;
    observer.progressBlock          = progressBlock;
    observer.completionBlock        = completionBlock;
    
    return observer;
}

#pragma mark Init

- (id)init {
    return [self initWithStartingOperationCount:0 progressBlock:NULL completionBlock:NULL];
}

- (id)initWithStartingOperationCount:(NSUInteger)operationCount progressBlock:(PPProgressObserverProgressBlock)progressBlock completionBlock:(PPProgressObserverCompletionBlock)completionBlock {

    if (self = [super init]) {
        self.startingOperationCount = operationCount;
        self.progressBlock = progressBlock;
        self.completionBlock = completionBlock;
    }
    
    return self;
}

#pragma mark Progress Observer

- (void)runProgressBlockWithCurrentOperationCount:(NSUInteger)operationCount {
    NSAssert(self.startingOperationCount, @"Starting operation count is 0. Initialize observer with a operation count of larger than 0.");
    
    if (!self.startingOperationCount) {
        return;
    }

    float progress = ((float)self.startingOperationCount - (float)operationCount) / (float)self.startingOperationCount;
    progress = MIN(MAX(progress, 0.0f), 1.0f);
    
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
    
    if ([self.delegate respondsToSelector:@selector(progressObserver:didProgress:)]) {
        [self.delegate progressObserver:self didProgress:progress];
    }
}

- (void)runCompletionBlock {
    if (self.completionBlock) {
        self.completionBlock();
    }
    
    if ([self.delegate respondsToSelector:@selector(progressObserverDidComplete:)]) {
        [self.delegate progressObserverDidComplete:self];
    }
}

- (void)addToStartingOperationCount:(NSUInteger)numberToAdd {
    self.startingOperationCount += numberToAdd;
}

@end
