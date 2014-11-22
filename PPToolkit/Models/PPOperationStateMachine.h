//
//  PPOperationStateMachine.h
//  PPCatalog
//
//  Created by Joachim Kret on 29.08.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TKStateMachine;

@interface PPOperationStateMachine : NSObject

@property (nonatomic, readonly, weak) NSOperation * operation;
@property (nonatomic, readonly, assign) dispatch_queue_t dispatchQueue;
@property (nonatomic, readonly, strong) TKStateMachine * stateMachine;

- (id)initWithOperation:(NSOperation *)operation dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (BOOL)isReady;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (BOOL)isCancelled;

- (void)setExecutionBlock:(void (^)(void))block;
- (void)setFinalizationBlock:(void (^)(void))block;
- (void)setCancellationBlock:(void (^)(void))block;

- (void)performBlockWithLock:(void (^)(void))block;

- (void)start;
- (void)finish;
- (void)cancel;

@end
