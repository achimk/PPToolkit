//
//  PPOperationQueue.m
//  PPCatalog
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPOperationQueue.h"

#import "PPOperation.h"
#import "PPProgressObserver.h"
#import "NSString+PPToolkitAdditions.h"

static NSString * const PPOperationQueueLockName    = @"com.PPToolkit.operationQueue.lock";

#pragma mark - PPOperationQueue

@interface PPOperationQueue ()

@property (nonatomic, readwrite, strong) NSOperationQueue * queue;
@property (nonatomic, readwrite, strong) NSMutableDictionary * operations;
@property (nonatomic, readwrite, strong) NSMutableSet * progressObservers;
@property (nonatomic, readwrite, strong) NSRecursiveLock * lock;
@property (nonatomic, readwrite, assign, getter = isCancelled) BOOL cancelled;

@end

#pragma mark -

@implementation PPOperationQueue

@synthesize queue = _queue;
@synthesize operations = _operations;
@synthesize lock = _lock;
@synthesize delegate = _delegate;
@synthesize cancelled = _cancelled;

@dynamic name;
@dynamic operationCount;

@dynamic suspended;
@dynamic executing;
@dynamic finished;


#pragma mark Init

- (id)init {
    return [self initWithName:nil];
}

- (id)initWithName:(NSString *)queueName {
    if (self = [super init]) {
        _queue = [NSOperationQueue new];
        _queue.name = (queueName && queueName.length) ? queueName : [NSString pp_stringWithUUID];
        _operations = [NSMutableDictionary new];
        _progressObservers = [NSMutableSet new];
        _lock = [NSRecursiveLock new];
        _lock.name = PPOperationQueueLockName;
    }
    
    return self;
}

#pragma mark KeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == (__bridge void *)self) {
        if ([keyPath isEqualToString:@"isFinished"]) {
            [self removeOperation:(PPOperation *)object];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Accessors

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@, %p, suspended: %@, executing: %@, finished: %@, cancelled: %@>",
            NSStringFromClass([self class]),
            self,
            PPStringFromBool(self.isSuspended),
            PPStringFromBool(self.isExecuting),
            PPStringFromBool(self.isFinished),
            PPStringFromBool(self.isCancelled)];
}

- (void)setOperations:(NSMutableDictionary *)operations {
    [self.lock lock];
    
    if (operations != _operations) {
        if (_operations) {
            for (PPOperation * operation in [_operations allValues]) {
                [operation removeObserver:self forKeyPath:@"isFinished" context:(__bridge void *)self];
            }
        }
        
        _operations = operations;
    }
    
    [self.lock unlock];
}

- (void)setQueue:(NSOperationQueue *)queue {
    [self.lock lock];
    
    if (queue != _queue) {
        if (_queue) {
            [_queue cancelAllOperations];
        }
        
        _queue = queue;
    }
    
    [self.lock unlock];
}

- (NSString *)name {
    return self.queue.name;
}

- (NSUInteger)operationCount {
    NSInteger operationCount = 0;
    
    [self.lock lock];
    
    operationCount = [[_operations allValues] count];
    
    [self.lock unlock];
    
    return operationCount;
}

- (void)setCancelled:(BOOL)cancelled {
    [self.lock lock];
    
    _cancelled = cancelled;
    
    [self.lock unlock];
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (void)setSuspended:(BOOL)suspended {
    [self.lock lock];
    
    [self.queue setSuspended:suspended];
    
    [self.lock unlock];
}

- (BOOL)isSuspended {
    return self.queue.isSuspended;
}

- (BOOL)isExecuting {
    return (0 < self.operationCount);
}

- (BOOL)isFinished {
    return (0 == self.operationCount);
}

#pragma mark Operation

- (BOOL)addOperation:(PPOperation *)operation {
    NSParameterAssert(operation);
    BOOL isAdded = NO;
    
    [self.lock lock];
    
    if (operation && ![[self.operations allKeys] containsObject:operation.identifier]) {
        BOOL isExecuting = self.isExecuting;
        self.cancelled = NO;
        
        //add operation and observer
        [self.operations setObject:operation forKey:operation.identifier];
        [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
        
        [self performBlockOnMainQueueWithLock:^{
            if (!isExecuting) {
                [self operationQueueDidStart];
            }
            
            //perform queue did start delegate
            if (!isExecuting && [self.delegate respondsToSelector:@selector(operationQueueDidStart:)]) {
                [self.delegate operationQueueDidStart:self];
            }
            
            //perform progress observers update
            [self.progressObservers enumerateObjectsUsingBlock:^(PPProgressObserver * observer, BOOL * stop) {
                [observer addToStartingOperationCount:1];
            }];
        }];
        
        //add to queue
        [self.queue addOperation:operation];
        
        isAdded = YES;
    }
    
    [self.lock unlock];
    
    return isAdded;
}

- (BOOL)removeOperation:(PPOperation *)operation {
    NSParameterAssert(operation);
    BOOL isRemoved = NO;
    
    [self.lock lock];
    
    if (operation && [[self.operations allKeys] containsObject:operation.identifier]) {
        //remove observer
        [operation removeObserver:self forKeyPath:@"isFinished" context:(__bridge void *)self];
        
        //cancel
        if (!operation.isFinished) {
            [operation cancel];
            self.cancelled = YES;
        }
        
        //remove operation
        [self.operations removeObjectForKey:operation.identifier];
        
        BOOL isFinished = self.isFinished;
        NSUInteger count = self.operationCount;
        
        [self performBlockOnMainQueueWithLock:^{
            //notify progress observers did progress
            [self.progressObservers enumerateObjectsUsingBlock:^(PPProgressObserver * observer, BOOL * stop) {
                [observer runProgressBlockWithCurrentOperationCount:count];
            }];
            
            if (isFinished) {
                [self operationQueueDidFinish];
                
                //notify progress observers queue complete
                [self.progressObservers enumerateObjectsUsingBlock:^(PPProgressObserver * observer, BOOL * stop) {
                    [observer runCompletionBlock];
                }];
                
                //remove all progress observers
                [self removeAllProgressObservers];
                
                //perform queue did finish delegate
                if ([self.delegate respondsToSelector:@selector(operationQueueDidFinish:)]) {
                    [self.delegate operationQueueDidFinish:self];
                }
                
            }
        }];
        
        isRemoved = YES;
    }
    
    [self.lock unlock];
    
    return isRemoved;
}

- (void)addOperations:(NSArray *)operations waitUntilFinished:(BOOL)wait {
    NSParameterAssert(operations);
    
    [self.lock lock];
    
    for (id object in operations) {
        if ([object isKindOfClass:[PPOperation class]]) {
            PPOperation * operation = (PPOperation *)object;
            [self addOperation:operation];
        }
    }
    
    if (wait) {
        [self.queue waitUntilAllOperationsAreFinished];
    }
    
    [self.lock unlock];
}

- (PPOperation *)operationWithIdentifier:(NSString *)identifier {
    return (identifier && identifier.length) ? self.operations[identifier] : nil;
}

- (BOOL)updatePriorityOfOperationWithIdentifier:(NSString *)identifier toPriority:(NSOperationQueuePriority)priority {
    PPOperation * operation = [self operationWithIdentifier:identifier];
    
    if (operation) {
        operation.queuePriority = priority;
        return YES;
    }
    
    return NO;
}

- (void)cancelOperationWithIdentifier:(NSString *)identifier {
    PPOperation * operation = [self operationWithIdentifier:identifier];
    
    if (operation) {
        [self removeOperation:operation];
    }
}

- (void)cancelAllOperations {
    for (PPOperation * operation in [self.operations allValues]) {
        [self removeOperation:operation];
    }
    
    self.suspended = NO;
}

#pragma mark ProgressObserver

- (void)addProgressObserver:(PPProgressObserver *)progressObserver {
    NSParameterAssert(progressObserver);
    
    [self.lock lock];
    
    progressObserver.startingOperationCount = self.operationCount;
    
    if (!progressObserver.identifier || !progressObserver.identifier.length) {
        progressObserver.identifier = self.name;
    }
    
    [self.progressObservers addObject:progressObserver];
    
    [self.lock unlock];
}

- (void)removeProgressObserver:(PPProgressObserver *)progressObserver {
    NSParameterAssert(progressObserver);
    
    [self.lock lock];
    
    [self.progressObservers removeObject:progressObserver];
    
    [self.lock unlock];
}

- (void)removeAllProgressObservers {
    [self.lock lock];
    
    [self.progressObservers removeAllObjects];
    
    [self.lock unlock];
}

#pragma mark Private Methods

- (void)operationQueueDidStart {
    NSAssert([NSThread isMainThread], @"Must be dispatched on main queue!");
    //only for subclassing
}

- (void)operationQueueDidFinish {
    NSAssert([NSThread isMainThread], @"Must be dispatched on main queue!");
    //only for subclassing
}

- (void)performBlockWithLock:(void(^)(void))block {
    NSParameterAssert(block);
    
    [self.lock lock];
    
    block();
    
    [self.lock unlock];
}

- (void)performBlockOnMainQueueWithLock:(void (^)(void))block {
    [self performBlockOnMainQueueWithLock:block synchronously:NO];
}

- (void)performBlockOnMainQueueWithLock:(void (^)(void))block synchronously:(BOOL)isSynchronously {
    NSParameterAssert(block);
    
    if ([NSThread isMainThread]) {
        [self performBlockWithLock:block];
    }
    else if (isSynchronously) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self performBlockWithLock:block];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performBlockWithLock:block];
        });
    }
}

@end
