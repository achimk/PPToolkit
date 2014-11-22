//
//  PPGroupOperation.m
//  PPCatalog
//
//  Created by Joachim Kret on 27.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPGroupOperation.h"

@interface PPGroupOperation ()
@property (nonatomic, readwrite, strong) NSMutableArray * observedOperations;
@end

#pragma mark -

@implementation PPGroupOperation

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

- (void)setObservedOperations:(NSMutableArray *)observedOperations {
    if (observedOperations != _observedOperations) {
        if (_observedOperations) {
            for (NSOperation * operation in _observedOperations) {
                [operation removeObserver:self forKeyPath:@"isFinished" context:(__bridge void *)self];
            }
        }
        
        _observedOperations = observedOperations;
    }
}

- (NSMutableArray *)observedOperations {
    if (!_observedOperations) {
        _observedOperations = [NSMutableArray new];
    }
    
    return _observedOperations;
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
    
    if (observe &&
        operation &&
        [operation isKindOfClass:[PPOperation class]] &&
        ![self.observedOperations containsObject:operation]) {
        
        [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    }
}

- (void)removeDependency:(NSOperation *)operation {
    [super removeDependency:operation];
    
    if (operation && [self.observedOperations containsObject:operation]) {
        [operation removeObserver:self forKeyPath:@"isFinished" context:(__bridge void *)self];
        [self.observedOperations removeObject:operation];
    }
}

#pragma mark NSOperation

- (void)finish {
    self.observedOperations = nil;
    
    [super finish];
}

- (void)cancel {
    if (!self.isFinished && !self.isCancelled) {
        for (NSOperation * operation in self.observedOperations) {
            [operation cancel];
        }
        
        [super cancel];
    }
}

@end
