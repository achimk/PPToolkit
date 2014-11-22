//
//  PPKVOOperation.m
//  PPCatalog
//
//  Created by Joachim Kret on 26.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPKVOOperation.h"

#pragma mark - PPKVOOperation

@interface PPKVOOperation ()

@property (nonatomic, readwrite, assign) PPKVOOperationState state;

@end

#pragma mark -

@implementation PPKVOOperation

@synthesize state = _state;

#pragma mark Init

- (id)initWithIdentifier:(NSString *)identifier {
    if (self = [super initWithIdentifier:identifier]) {
        self.state = PPKVOOperationStateReady;
    }
    
    return self;
}

#pragma mark Accessors

- (void)setState:(PPKVOOperationState)state {
    if (!PPKVOStateTransitionIsValid(self.state, state, self.isCancelled)) {
        return;
    }
    
    [self.lock lock];
    
    NSString * oldStateKey = PPKVOKeyPathFromOperationState(self.state);
    NSString * newStateKey = PPKVOKeyPathFromOperationState(state);
    
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    
    _state = state;
    
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    
    [self.lock unlock];
}

- (void)setCancelled:(BOOL)cancelled {
    [self.lock lock];
    [super setCancelled:cancelled];
    [self.lock unlock];
}

#pragma mark NSOperation

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isReady {
    return (PPKVOOperationStateReady == self.state) && [super isReady];
}

- (BOOL)isExecuting {
    return (PPKVOOperationStateExecuting == self.state);
}

- (BOOL)isFinished {
    return (PPKVOOperationStateFinished == self.state);
}

- (void)main {
    NSAssert(!self.isConcurrent, @"Main method should ben never called for concurrent operation.");
}

- (void)start {
    dispatch_async(self.delegateQueue ?: dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(operationDidStart:)]) {
            [self.delegate operationDidStart:self];
        }
    });
    
    if (self.isCancelled) {
        [self finish];
    }
    else {
        self.state = PPKVOOperationStateExecuting;
        [self execute];
    }
}

- (void)execute {
    [self finish];
}

- (void)finish {
    NSAssert2(!self.isFinished, @"Operation class '%@' with identifier %@ already finished", NSStringFromClass([self class]), self.identifier);
    
    self.state = PPKVOOperationStateFinished;
    
    dispatch_async(self.delegateQueue ?: dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(operationDidFinish:)]) {
            [self.delegate operationDidFinish:self];
        }
    });
}

- (void)cancel {
    if (!self.isFinished && !self.isCancelled) {
        [super cancel];
    }
}

@end

#pragma mark Utilities

NSString * PPKVOKeyPathFromOperationState(PPKVOOperationState state) {
    switch (state) {
        case PPKVOOperationStateReady: {
            return @"isReady";
        }
        case PPKVOOperationStateExecuting: {
            return @"isExecuting";
        }
        case PPKVOOperationStateFinished: {
            return @"isFinished";
        }
        default: {
            return @"state";
        }
    }
}

BOOL PPKVOStateTransitionIsValid(PPKVOOperationState fromState, PPKVOOperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case PPKVOOperationStateReady: {
            switch (toState) {
                case PPKVOOperationStateExecuting: {
                    return YES;
                }
                case PPKVOOperationStateFinished: {
                    return isCancelled;
                }
                default: {
                    return NO;
                }
            }
        }
        case PPKVOOperationStateExecuting: {
            switch (toState) {
                case PPKVOOperationStateFinished: {
                    return YES;
                }
                default: {
                    return NO;
                }
            }
        }
        case PPKVOOperationStateFinished: {
            return NO;
        }
        default: {
            return YES;
        }
    }
}
