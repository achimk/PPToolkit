//
//  PPManagedObjectContext.h
//  PPToolkit
//
//  Created by Joachim Kret on 21.11.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString * const PPRequestSpecificOptions;

typedef void (^PPSaveContextSuccess)(void);
typedef void (^PPSaveContextFailure)(NSError * error);

typedef void (^PPFetchContextSuccess)(NSArray * objects);
typedef void (^PPFetchContextFailure)(NSError * error);

#pragma mark - PPManagedObjectContext

@interface PPManagedObjectContext : NSManagedObjectContext

@property (nonatomic, readwrite, copy) NSString * identifier;
@property (nonatomic, readonly, assign, getter = isRoot) BOOL root;
@property (nonatomic, readwrite, assign) dispatch_queue_t successCallbackQueue;
@property (nonatomic, readwrite, assign) dispatch_queue_t failureCallbackQueue;

- (void)finishInitialize;

- (BOOL)isInternalSuccessQueue;
- (BOOL)isInternalFailureQueue;

- (void)observeContext:(NSManagedObjectContext *)contextToObserve;
- (void)stopObservingContext:(NSManagedObjectContext *)contextToStopObserving;
- (void)setContextShouldObtainPermanentIDsBeforeSaving:(BOOL)value;

- (void)saveWithSuccess:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure;
- (void)saveWithOptions:(id)options success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure;
- (void)saveAndWaitWithSuccess:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure;
- (void)saveAndWaitWithOptions:(id)options success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure;
- (void)saveSynchronously:(BOOL)isSynchronously withSuccess:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure;
- (void)saveSynchronously:(BOOL)isSynchronously withOptions:(id)options success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure;
- (void)saveSynchronously:(BOOL)isSynchronously withOptions:(id)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure;

- (void)executeFetchRequest:(NSFetchRequest *)fetchRequest withSuccess:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure;
- (void)executeFetchRequest:(NSFetchRequest *)fetchRequest withOptions:(id)options success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure;
- (void)executeFetchRequestAndWait:(NSFetchRequest *)fetchRequest withSuccess:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure;
- (void)executeFetchRequestAndWait:(NSFetchRequest *)fetchRequest withOptions:(id)options success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure;
- (void)executeFetchRequestSynchronously:(BOOL)isSynchronously withFetchRequest:(NSFetchRequest *)fetchRequest success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure;
- (void)executeFetchRequestSynchronously:(BOOL)isSynchronously withFetchRequest:(NSFetchRequest *)fetchRequest options:(id)options success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure;
- (void)executeFetchRequestSynchronously:(BOOL)isSynchronously withFetchRequest:(NSFetchRequest *)fetchRequest options:(id)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure;

@end

#pragma mark - PPManagedObjectContext (Notifications)

@interface PPManagedObjectContext (Notifications)

- (void)managedObjectContextWillSaveNotification:(NSNotification *)aNotification;
- (void)managedObjectContextDidSaveNotification:(NSNotification *)aNotification;

@end

#pragma mark - PPManagedObjectContext (SubclassOnly)

@interface PPManagedObjectContext (SubclassOnly)

- (void)dispatchSynchronously:(BOOL)isSynchronously onDispatchQueue:(dispatch_queue_t)dispatchQueue withBlock:(dispatch_block_t)block;

@end
