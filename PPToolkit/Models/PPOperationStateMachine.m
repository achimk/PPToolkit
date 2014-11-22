//
//  PPOperationStateMachine.m
//  PPCatalog
//
//  Created by Joachim Kret on 29.08.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPOperationStateMachine.h"

#import "TransitionKit.h"

NSString * const PPOperationFailureException        = @"PPOperationFailureException";

static NSString * const PPOperationStateReady       = @"Ready";
static NSString * const PPOperationStateExecuting   = @"Executing";
static NSString * const PPOperationStateFinished    = @"Finished";

static NSString * const PPOperationEventStart       = @"Start";
static NSString * const PPOperationEventFinish      = @"Finish";

static NSString * const PPOperationLockName         = @"com.PPToolkit.stateMachine.operation.lock";

#pragma mark - PPOperationStateMachine

@interface PPOperationStateMachine ()

@property (nonatomic, readwrite, strong) TKStateMachine * stateMachine;
@property (nonatomic, readwrite, weak) NSOperation * operation;
@property (nonatomic, readwrite, assign) dispatch_queue_t dispatchQueue;
@property (nonatomic, readwrite, strong) NSRecursiveLock * lock;
@property (nonatomic, readwrite, assign, getter = isCancelled) BOOL cancelled;
@property (nonatomic, readwrite, copy) void (^cancellationBlock)(void);

@end

#pragma mark -

@implementation PPOperationStateMachine

@synthesize stateMachine = _stateMachine;
@synthesize operation = _operation;
@synthesize dispatchQueue = _dispatchQueue;
@synthesize lock = _lock;
@synthesize cancelled = _cancelled;
@synthesize cancellationBlock = _cancellationBlock;

#pragma mark Init / Dealloc

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke initWithOperation:dispatchQueue: instead.",
                                           NSStringFromClass([self class])]
                                 userInfo:nil];
    return nil;
}

- (id)initWithOperation:(NSOperation *)operation dispatchQueue:(dispatch_queue_t)dispatchQueue {
    NSParameterAssert(operation);
    NSParameterAssert(dispatchQueue);
    
    if (self = [super init]) {
        self.operation = operation;
        self.dispatchQueue = dispatchQueue;
        
        self.stateMachine = [TKStateMachine new];
        self.lock = [NSRecursiveLock new];
        self.lock.name = PPOperationLockName;
        
        // ready state
        __weak __typeof(&*self)weakSelf = self;
        TKState * readyState = [TKState stateWithName:PPOperationStateReady];
        
        [readyState setWillExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation willChangeValueForKey:@"isReady"];
        }];
        
        [readyState setDidExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation didChangeValueForKey:@"isReady"];
        }];
        
        // executing state
        TKState * executingState = [TKState stateWithName:PPOperationStateExecuting];
        
        [executingState setWillEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation willChangeValueForKey:@"isExecuting"];
        }];
        
        [executingState setDidEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [NSException raise:NSInternalInconsistencyException format:@"You must configure an execution block via `setExecutionBlock:`."];
        }];
        
        [executingState setWillExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation willChangeValueForKey:@"isExecuting"];
        }];
        
        [executingState setDidExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation didChangeValueForKey:@"isExecuting"];
        }];
        
        // finished state
        TKState * finishedState = [TKState stateWithName:PPOperationStateFinished];
        
        [finishedState setWillEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
        }];
        
        [finishedState setDidEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation didChangeValueForKey:@"isFinished"];
        }];
        
        [finishedState setWillExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
        }];
        
        [finishedState setDidEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
            [weakSelf.operation didChangeValueForKey:@"isFinished"];
        }];
        
        // add states
        [self.stateMachine addStates:@[readyState, executingState, finishedState]];
        
        // start event
        TKEvent * startEvent = [TKEvent eventWithName:PPOperationEventStart transitioningFromStates:@[readyState] toState:executingState];
        
        // finish event
        TKEvent * finishEvent = [TKEvent eventWithName:PPOperationEventFinish transitioningFromStates:@[executingState] toState:finishedState];
        
        // add events
        [self.stateMachine addEvents:@[startEvent, finishEvent]];
        
        self.stateMachine.initialState = readyState;
        [self.stateMachine activate];
    }
    
    return self;
}

#pragma mark Accessors

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p (for %@:%p), state: %@, cancelled: %@, finished: %@>",
            [self class],
            self,
            [self.operation class],
            self.operation,
            self.stateMachine.currentState.name,
            PPStringFromBool(self.isCancelled),
            PPStringFromBool(self.isFinished)];
}

- (void)setCancelled:(BOOL)cancelled {
    [self performBlockWithLock:^{
        _cancelled = cancelled;
    }];
}

- (void)setCancellationBlock:(void (^)(void))block {
    [self performBlockWithLock:^{
        _cancellationBlock = [block copy];
    }];
}

- (BOOL)isReady {
    return [self.stateMachine isInState:PPOperationStateReady];
}

- (BOOL)isExecuting {
    return [self.stateMachine isInState:PPOperationStateExecuting];
}

- (BOOL)isFinished {
    return [self.stateMachine isInState:PPOperationStateFinished];
}

- (void)setExecutionBlock:(void (^)(void))block {
    __weak __typeof(&*self) weakSelf = self;
    TKState * executingState = [self.stateMachine stateNamed:PPOperationStateExecuting];
    [executingState setDidEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        [weakSelf.operation didChangeValueForKey:@"isExecuting"];
        dispatch_async(weakSelf.dispatchQueue, ^{
            block();
        });
    }];
}

- (void)setFinalizationBlock:(void (^)(void))block {
    __weak __typeof(&*self) weakSelf = self;
    TKState * finishedState = [self.stateMachine stateNamed:PPOperationStateFinished];
    [finishedState setWillEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        [weakSelf performBlockWithLock:^{
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
            block();
        }];
    }];
}

#pragma mark Public Methods

- (void)performBlockWithLock:(void (^)(void))block {
    NSParameterAssert(block);
    
    [self.lock lock];
    block();
    [self.lock unlock];
}

#pragma mark Operation State

- (void)start {
    if (!self.dispatchQueue) {
        [NSException raise:NSInternalInconsistencyException format:@"You must configure an 'operationQueue'."];
    }
    
    [self performBlockWithLock:^{
        NSError * error = nil;
        BOOL success = [self.stateMachine fireEvent:PPOperationEventStart error:&error];
        
        if (!success) {
            [NSException raise:PPOperationFailureException format:@"The operation unexpectedly failed to start due to an error: %@", error];
        }
    }];
}

- (void)finish {
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(self.dispatchQueue, ^{
        [weakSelf performBlockWithLock:^{
            NSError * error = nil;
            BOOL success = [weakSelf.stateMachine fireEvent:PPOperationEventFinish error:&error];
            
            if (!success) {
                [NSException raise:PPOperationFailureException format:@"The operation unexpectedly failed to finish due to an error: %@", error];
            }
        }];
    });
}

- (void)cancel {
    if ([self isCancelled] || [self isFinished]) {
        return;
    }
    
    self.cancelled = YES;
    
    if (self.cancellationBlock) {
        __weak __typeof(&*self) weakSelf = self;
        dispatch_async(self.dispatchQueue, ^{
            [weakSelf performBlockWithLock:weakSelf.cancellationBlock];
        });
    }
}

@end
