//
//  PPOperation.m
//  PPCatalog
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPOperation.h"

#import "PPOperationQueue.h"
#import "PPOperationStateMachine.h"
#import "NSString+PPToolkitAdditions.h"

static NSString * const PPOperationLockName = @"com.PPToolkit.operation.lock";

#pragma mark - PPOperation

@interface PPOperation ()

@property (nonatomic, readwrite, copy) NSString * identifier;
@property (nonatomic, readwrite, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, readwrite, strong) NSRecursiveLock * lock;
@property (nonatomic, readwrite, strong) NSError * error;
@property (nonatomic, readwrite, assign, getter = isCancelled) BOOL cancelled;

@end

#pragma mark -

@implementation PPOperation

@synthesize identifier = _identifier;
@synthesize backgroundTaskIdentifier = _backgroundTaskIdentifier;
@synthesize successCallbackQueue = _successCallbackQueue;
@synthesize failureCallbackQueue = _failureCallbackQueue;
@synthesize delegateQueue = _delegateQueue;
@synthesize lock = _lock;
@synthesize error = _error;
@synthesize cancelled = _cancelled;
@synthesize delegate = _delegate;

#pragma mark Init / Dealloc

- (id)init {
    return [self initWithIdentifier:nil];
}

- (id)initWithIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        self.identifier = (identifier && identifier.length) ? identifier : [NSString pp_stringWithUUID];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        _lock = [NSRecursiveLock new];
        _lock.name = [NSString stringWithFormat:@"%@.%@", PPOperationLockName, self.identifier];
    }
    
    return self;
}

- (void)dealloc {
    [self endBackgroundTask];
    self.successCallbackQueue = NULL;
    self.failureCallbackQueue = NULL;
    self.delegateQueue = NULL;
}

#pragma mark Accessors

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p identifier: %@, state: %@, concurrent: %@, cancelled: %@, error: %@>",
            [self class],
            self,
            self.identifier,
            PPStringNameForStateOfOperation(self),
            PPStringFromBool(self.isConcurrent),
            PPStringFromBool(self.isCancelled),
            self.error];
}

- (void)setSuccessCallbackQueue:(dispatch_queue_t)successCallbackQueue {
    if (successCallbackQueue != _successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        if (_successCallbackQueue) {
            dispatch_release(_successCallbackQueue);
        }
#endif
        
        _successCallbackQueue = successCallbackQueue;
        
#if !OS_OBJECT_USE_OBJC
        if (successCallbackQueue) {
            dispatch_retain(successCallbackQueue);
        }
#endif
    }
}

- (void)setFailureCallbackQueue:(dispatch_queue_t)failureCallbackQueue {
    if (failureCallbackQueue != _failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        if (_failureCallbackQueue) {
            dispatch_release(_failureCallbackQueue);
        }
#endif
        
        _failureCallbackQueue = failureCallbackQueue;
        
#if !OS_OBJECT_USE_OBJC
        if (failureCallbackQueue) {
            dispatch_retain(failureCallbackQueue);
        }
#endif
    }
}

- (void)setDelegateQueue:(dispatch_queue_t)delegateQueue {
    if (delegateQueue != _delegateQueue) {
#if !OS_OBJECT_USE_OBJC
        if (_delegateQueue) {
            dispatch_release(_delegateQueue);
        }
#endif
        
        _delegateQueue = delegateQueue;
        
#if !OS_OBJECT_USE_OBJC
        if (delegateQueue) {
            dispatch_retain(delegateQueue);
        }
#endif
    }
}

- (void)setCompletionBlock:(void (^)(void))block {
    if (block) {
        __weak __typeof(&*self)weakSelf = self;
        [super setCompletionBlock:^{
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            
            block();
            [strongSelf setCompletionBlock:nil];
        }];
    }
    else {
        [super setCompletionBlock:nil];
    }
}

- (void)setCompletionBlockWithSuccess:(PPOperationSuccess)success failure:(PPOperationFailure)failure {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wgnu"
    
    self.completionBlock = ^{
        if (self.isCancelled && !self.error) {
            self.error = [NSError errorWithDomain:kPPToolkitErrorDomain code:kPPToolkitOperationCancelledError userInfo:nil];
        }
        
        if (self.error) {
            if (failure) {
                dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(self, self.error);
                });
            }
        }
        else {
            if (success) {
                dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                    success(self);
                });
            }
        }
    };
    
#pragma clang diagnostic pop
}

- (void)setCancelled:(BOOL)cancelled {
    [self.lock lock];
    _cancelled = cancelled;
    [self.lock unlock];
}

- (void)setError:(NSError *)error {
    [self.lock lock];
    _error = error;
    [self.lock unlock];
}

#pragma mark NSOperation

- (void)main {
    dispatch_async(self.delegateQueue ?: dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(operationDidStart:)]) {
            [self.delegate operationDidStart:self];   
        }
    });
    
    if (self.isCancelled) {
        [self finish];
    }
    else {
        [self execute];
    }
}

- (void)execute {
    [self finish];
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
    if (!self.isFinished && !self.isCancelled) {
        self.cancelled = YES;
        [super cancel];
    }
}

#pragma mark Background Task

- (void)beginBackgroundTask {
    if (UIBackgroundTaskInvalid == self.backgroundTaskIdentifier) {
        void (^handler)(void) = ^{
            [self backgroundTaskHasExpired];
            [self cancel];
            [self endBackgroundTask];
        };
        
        self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:handler];
    }
}

- (void)backgroundTaskHasExpired {
    //Subclasses should override this method
}

- (void)endBackgroundTask {
    if (self.backgroundTaskIdentifier &&
        UIBackgroundTaskInvalid != self.backgroundTaskIdentifier) {
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

@end

#pragma mark - Utilities

NSString * PPStringNameForStateOfOperation(PPOperation * operation) {
    assert(nil != operation);
    
    if (operation.isExecuting) {
        return @"Executing";
    }
    else if (operation.isFinished) {
        if (operation.error) {
            return @"Finished (Fail)";
        }
        else {
            return @"Finished (Success)";
        }
    }
    else {
        return @"Ready";
    }
}
