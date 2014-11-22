//
//  PPOperationQueue.h
//  PPCatalog
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPOperation;
@class PPProgressObserver;
@class PPOperationQueue;

#pragma mark - PPOperationQueueDelegate

@protocol PPOperationQueueDelegate <NSObject>

@optional
- (void)operationQueueDidStart:(PPOperationQueue *)operationQueue;
- (void)operationQueueDidFinish:(PPOperationQueue *)operationQueue;

@end

#pragma mark - PPOperationQueue

@interface PPOperationQueue : NSObject

@property (nonatomic, readonly, strong) NSOperationQueue * queue;
@property (nonatomic, readonly, strong) NSMutableDictionary * operations;
@property (nonatomic, readonly, strong) NSMutableSet * progressObservers;
@property (nonatomic, readonly, assign) NSString * name;
@property (nonatomic, readonly, assign) NSUInteger operationCount;
@property (nonatomic, readwrite, assign, getter = isSuspended) BOOL suspended;
@property (nonatomic, readonly, assign, getter = isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter = isFinished) BOOL finished;
@property (nonatomic, readonly, assign, getter = isCancelled) BOOL cancelled;
@property (nonatomic, readwrite, weak) id <PPOperationQueueDelegate> delegate;

- (id)init;
- (id)initWithName:(NSString *)queueName;

- (BOOL)addOperation:(PPOperation *)operation;
- (BOOL)removeOperation:(PPOperation *)operation;
- (void)addOperations:(NSArray *)operations waitUntilFinished:(BOOL)wait;

- (PPOperation *)operationWithIdentifier:(NSString *)identifier;
- (BOOL)updatePriorityOfOperationWithIdentifier:(NSString *)identifier toPriority:(NSOperationQueuePriority)priority;

- (void)cancelOperationWithIdentifier:(NSString *)identifier;
- (void)cancelAllOperations;

- (void)addProgressObserver:(PPProgressObserver *)progressObserver;
- (void)removeProgressObserver:(PPProgressObserver *)progressObserver;
- (void)removeAllProgressObservers;

@end

#pragma mark - PPOperationQueue (SubclassOnly)

@interface PPOperationQueue (SubclassOnly)

- (void)operationQueueDidStart;
- (void)operationQueueDidFinish;

- (NSRecursiveLock *)lock;
- (void)performBlockWithLock:(void(^)(void))block;
- (void)performBlockOnMainQueueWithLock:(void (^)(void))block;
- (void)performBlockOnMainQueueWithLock:(void (^)(void))block synchronously:(BOOL)isSynchronously;

@end
