//
//  PPDispatchGroupOperation.m
//  PPCatalog
//
//  Created by Joachim Kret on 30.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPDispatchGroupOperation.h"

#import "PPOperationStateMachine.h"

#pragma mark - PPDispatchOperation

@interface PPDispatchOperation ()
@property (nonatomic, readwrite, assign) dispatch_queue_t dispatchQueue;
@end

#pragma mark - PPDispatchGroupOperation

@interface PPDispatchGroupOperation ()
@property (nonatomic, readwrite, strong) NSMutableArray * observedOperations;
@end

#pragma mark -

@implementation PPDispatchGroupOperation

@synthesize observedOperations = _observedOperations;

#pragma mark KeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == (__bridge void *)self) {
        if ([keyPath isEqualToString:@"isFinished"]) {
            PPOperation * operation = (PPOperation *)object;
            
            if (!self.isFinished &&
                !self.isCancelled &&
                !operation.isCancelled &&
                operation.error) {
                
                self.error = operation.error;
                [self cancel];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Accessors

- (void)setobservedOperations:(NSMutableArray *)observedOperations {
    dispatch_block_t block = ^{
        if (observedOperations != _observedOperations) {
            if (_observedOperations) {
                for (NSOperation * operation in _observedOperations) {
                    [operation removeObserver:self forKeyPath:@"isFinished" context:(__bridge void *)self];
                }
            }
            
            _observedOperations = observedOperations;
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
    
}

- (NSMutableArray *)observedOperations {
    __block NSMutableArray * result = nil;
    dispatch_block_t block = ^{
        if (!_observedOperations) {
            _observedOperations = [NSMutableArray new];
        }
        
        result = _observedOperations;
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_sync(self.dispatchQueue, block);
    }
    
    return result;
}

#pragma mark Dependency

- (void)addDependency:(NSOperation *)operation {
    [self addDependency:operation shouldObserve:NO];
}

- (void)addDependencyAndObserve:(NSOperation *)operation {
    [self addDependency:operation shouldObserve:YES];
}

- (void)addDependency:(NSOperation *)operation shouldObserve:(BOOL)observe {
    [super addDependency:operation];
    
    dispatch_block_t block = ^{
        if (observe &&
            operation &&
            [operation isKindOfClass:[PPOperation class]] &&
            ![self.observedOperations containsObject:operation]) {
            
            [self.observedOperations addObject:operation];
            [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
}

- (void)removeDependency:(NSOperation *)operation {
    [super removeDependency:operation];
    
    dispatch_block_t block = ^{
        if (operation && [self.observedOperations containsObject:operation]) {
            [operation removeObserver:self forKeyPath:@"isFinished" context:(__bridge void *)self];
            [self.observedOperations removeObject:operation];
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
}

#pragma mark NSOperation

- (void)finish {
    self.observedOperations = nil;
    
    [super finish];
}

- (void)cancel {
    if (!self.isFinished && !self.isCancelled) {
        __strong NSMutableArray * observedOperations = self.observedOperations;
        for (NSOperation * operation in observedOperations) {
            [operation cancel];
        }
        
        [super cancel];
    }
}

@end
