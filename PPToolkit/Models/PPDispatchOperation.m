//
//  PPDispatchOperation.m
//  PPCatalog
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPDispatchOperation.h"

#import "PPOperationStateMachine.h"

#pragma nark - PPOperation

@interface PPOperation ()

@property (nonatomic, readwrite, assign, getter = isCancelled) BOOL cancelled;

@end

#pragma mark - PPDispatchOperation

@interface PPDispatchOperation ()

@property (nonatomic, readwrite, assign) dispatch_queue_t dispatchQueue;
@property (nonatomic, readwrite, assign) dispatch_group_t dispatchGroup;
@property (nonatomic, readwrite, strong) PPOperationStateMachine * operationStateMachine;

@end

#pragma mark -

@implementation PPDispatchOperation

@synthesize dispatchQueue = _dispatchQueue;
@synthesize dispatchGroup = _dispatchGroup;

+ (dispatch_queue_t)defaultDispatchQueue {
    static dispatch_queue_t __defaultDispatchQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultDispatchQueue = dispatch_queue_create("com.PPToolkit.dispatchOperation.defaultDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return __defaultDispatchQueue;
}

#pragma mark Init / Dealloc

- (id)init {
    return [self initWithIdentifier:nil dispatchQueue:[[self class] defaultDispatchQueue]];
}

- (id)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier dispatchQueue:[[self class] defaultDispatchQueue]];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)dispatchQueue {
    return [self initWithIdentifier:nil dispatchQueue:dispatchQueue];
}

- (id)initWithIdentifier:(NSString *)identifier dispatchQueue:(dispatch_queue_t)dispatchQueue {
    NSParameterAssert(dispatchQueue);
    
    if (self = [super initWithIdentifier:identifier]) {
        __weak __typeof (&*self)weakSelf = self;
        
        self.dispatchQueue = dispatchQueue;
        self.operationStateMachine = [[PPOperationStateMachine alloc] initWithOperation:self dispatchQueue:dispatchQueue];

        //execution block
        [self.operationStateMachine setExecutionBlock:^{
            if (weakSelf.isCancelled) {
                [weakSelf.operationStateMachine finish];
            }
            else {
                [weakSelf execute];
            }
        }];
        
        //finalization block
        [self.operationStateMachine setFinalizationBlock:^{
            [weakSelf finish];
        }];
    }
    
    return self;
}

- (void)dealloc {
    self.dispatchGroup = NULL;
    self.dispatchQueue = NULL;
}

#pragma mark Accessors

- (void)setDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (dispatchQueue != _dispatchQueue) {
        if (_dispatchQueue) {
            void * key = (__bridge void *)self;
            dispatch_queue_set_specific(_dispatchQueue, key, NULL, NULL);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_dispatchQueue);
#endif
        }
        
        _dispatchQueue = dispatchQueue;
        
        if (dispatchQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(dispatchQueue);
#endif
            void * key = (__bridge void *)self;
            void * nonNullValue = (__bridge void *)self;
            dispatch_queue_set_specific(dispatchQueue, key, nonNullValue, NULL);
        }
    }
}

- (BOOL)isInternalDispatchQueue {
    void * const key = (__bridge void *)self;
    return (NULL != dispatch_get_specific(key));
}

- (void)setDispatchGroup:(dispatch_group_t)dispatchGroup {
    if (dispatchGroup != _dispatchGroup) {
        if (_dispatchGroup) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_dispatchGroup);
#endif
        }
        
        _dispatchGroup = dispatchGroup;
        
        if (dispatchGroup) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(dispatchGroup);
#endif
        }
    }
}

- (dispatch_group_t)dispatchGroup {
    if (!_dispatchGroup) {
        dispatch_group_t dispatchGroup = dispatch_group_create();
        self.dispatchGroup = dispatchGroup;
#if !OS_OBJECT_USE_OBJC
        dispatch_release(dispatchGroup);
#endif
    }
    
    return _dispatchGroup;
}

#pragma mark NSOperation

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isReady {
    return [self.operationStateMachine isReady] && [super isReady];
}

- (BOOL)isExecuting {
    return [self.operationStateMachine isExecuting];
}

- (BOOL)isFinished {
    return [self.operationStateMachine isFinished];
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
    
    [self.operationStateMachine start];
}

- (void)execute {
    [self.operationStateMachine finish];
}

- (void)finish {
    NSAssert2(!self.isFinished, @"Operation class '%@' with identifier %@ already finished", NSStringFromClass([self class]), self.identifier);
    
    dispatch_async(self.delegateQueue ?: dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(operationDidFinish:)]) {
            [self.delegate operationDidFinish:self];
        }
    });
}

- (void)cancel {
    [super cancel];
    [self.operationStateMachine cancel];
}

@end
