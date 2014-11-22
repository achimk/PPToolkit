//
//  PPOperation.h
//  PPCatalog
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPOperation;

typedef void (^PPOperationSuccess)(PPOperation * operation);
typedef void (^PPOperationFailure)(PPOperation * operation, NSError * error);

#pragma mark - PPOperationDelegate

@protocol PPOperationDelegate <NSObject>

@optional
- (void)operationDidStart:(PPOperation *)operation;
- (void)operationDidFinish:(PPOperation *)operation;

@end

#pragma mark - PPOperation

@interface PPOperation : NSOperation

@property (nonatomic, readonly, copy) NSString * identifier;
@property (nonatomic, readwrite, assign) dispatch_queue_t successCallbackQueue;
@property (nonatomic, readwrite, assign) dispatch_queue_t failureCallbackQueue;
@property (nonatomic, readwrite, assign) dispatch_queue_t delegateQueue;
@property (nonatomic, readonly, strong) NSRecursiveLock * lock;
@property (nonatomic, readonly, strong) NSError * error;
@property (nonatomic, readwrite, weak) id <PPOperationDelegate> delegate;

- (id)init;
- (id)initWithIdentifier:(NSString *)identifier;

- (void)execute;
- (void)finish;

- (void)setCompletionBlockWithSuccess:(PPOperationSuccess)success failure:(PPOperationFailure)failure;

@end

#pragma mark - PPOperation (SubclassOnly)

@interface PPOperation (SubclassOnly)

- (void)setCancelled:(BOOL)cancelled;
- (BOOL)isCancelled;

- (void)setError:(NSError *)error;
- (NSError *)error;

- (void)setBackgroundTaskIdentifier:(UIBackgroundTaskIdentifier)backgroundTaskIdentifier;
- (UIBackgroundTaskIdentifier)backgroundTaskIdentifier;
- (void)beginBackgroundTask;
- (void)backgroundTaskHasExpired;
- (void)endBackgroundTask;

@end

#pragma mark - Utilities

extern NSString * PPStringNameForStateOfOperation(PPOperation * operation);