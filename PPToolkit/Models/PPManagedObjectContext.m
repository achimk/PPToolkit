//
//  PPManagedObjectContext.m
//  PPToolkit
//
//  Created by Joachim Kret on 21.11.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedObjectContext.h"

NSString * const PPRequestSpecificOptions   = @"PPRequestSpecificOptions";

static void * PPSuccessCallbackQueueKey     = (void *)"com.PPToolkit.managedObjectContext.successQueueKey";
static void * PPFailureCallbackQueueKey     = (void *)"com.PPToolkit.managedObjectContext.failureQueueKey";

#pragma mark - PPManagedObjectContext

@implementation PPManagedObjectContext

@synthesize identifier = _identifier;
@synthesize successCallbackQueue = _successCallbackQueue;
@synthesize failureCallbackQueue = _failureCallbackQueue;

@dynamic root;

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    
    return self;
}

- (id)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct {
    if (self = [super initWithConcurrencyType:ct]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)finishInitialize {
    self.identifier = PPStringFromManagedObjectContextConcurrencyType(self.concurrencyType);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Accessors

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p identifier: %@, concurencyType: %@, isRoot: %@, hasChanges: %@>",
            [self class],
            self,
            self.identifier,
            PPStringFromManagedObjectContextConcurrencyType(self.concurrencyType),
            PPStringFromBool(self.isRoot),
            PPStringFromBool(self.hasChanges)];
}

- (BOOL)isRoot {
    return (nil == self.parentContext);
}

- (void)setSuccessCallbackQueue:(dispatch_queue_t)successCallbackQueue {
    if (successCallbackQueue != _successCallbackQueue) {
        if (_successCallbackQueue) {
            void * key = PPSuccessCallbackQueueKey;
            dispatch_queue_set_specific(_successCallbackQueue, key, NULL, NULL);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_successCallbackQueue);
#endif
        }
        
        _successCallbackQueue = successCallbackQueue;
        
        if (successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(successCallbackQueue);
#endif
            void * key = PPSuccessCallbackQueueKey;
            void * nonNullValue = (__bridge void *)self;
            dispatch_queue_set_specific(successCallbackQueue, key, nonNullValue, NULL);
        }
    }
}

- (void)setFailureCallbackQueue:(dispatch_queue_t)failureCallbackQueue {
    if (failureCallbackQueue != _failureCallbackQueue) {
        if (_failureCallbackQueue) {
            void * key = PPFailureCallbackQueueKey;
            dispatch_queue_set_specific(_failureCallbackQueue, key, NULL, NULL);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_failureCallbackQueue);
#endif
        }
        
        _failureCallbackQueue = failureCallbackQueue;
        
        if (failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(failureCallbackQueue);
#endif
            void * key = PPFailureCallbackQueueKey;
            void * nonNullValue = (__bridge void *)self;
            dispatch_queue_set_specific(failureCallbackQueue, key, nonNullValue, NULL);
        }
    }
}

- (BOOL)isInternalSuccessQueue {
    return (NULL != dispatch_get_specific(PPSuccessCallbackQueueKey));
}

- (BOOL)isInternalFailureQueue {
    return (NULL != dispatch_get_specific(PPFailureCallbackQueueKey));
}

- (void)observeContext:(NSManagedObjectContext *)contextToObserve {
    NSParameterAssert(contextToObserve);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:contextToObserve];
}

- (void)stopObservingContext:(NSManagedObjectContext *)contextToStopObserving {
    NSParameterAssert(contextToStopObserving);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:contextToStopObserving];
}

- (void)setContextShouldObtainPermanentIDsBeforeSaving:(BOOL)value {
     if (value) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextWillSaveNotification:) name:NSManagedObjectContextWillSaveNotification object:self];
     }
     else {
         [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:self];
     }
}

#pragma mark Save

- (void)saveWithSuccess:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure {
    [self saveSynchronously:NO withOptions:nil successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)saveWithOptions:(id)options success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure {
    [self saveSynchronously:NO withOptions:options successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)saveAndWaitWithSuccess:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure {
    [self saveSynchronously:YES withOptions:nil successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)saveAndWaitWithOptions:(id)options success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure {
    [self saveSynchronously:YES withOptions:options successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)saveSynchronously:(BOOL)isSynchronously withSuccess:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure {
    [self saveSynchronously:isSynchronously withOptions:nil successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)saveSynchronously:(BOOL)isSynchronously withOptions:(id)options success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure {
    [self saveSynchronously:isSynchronously withOptions:options successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)saveSynchronously:(BOOL)isSynchronously withOptions:(id)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue success:(PPSaveContextSuccess)success failure:(PPSaveContextFailure)failure {
    if (!self.hasChanges) {
        if (success) {
            if (successCallbackQueue) {
                dispatch_block_t block = ^{
                    success();
                };
                
                [self dispatchSynchronously:isSynchronously onDispatchQueue:successCallbackQueue withBlock:block];
            }
            else {
                success();
            }
        }
        
        return;
    }
    
    void (^saveBlock)(void) = ^{
        BOOL isSaved = NO;
        BOOL isRootContext = (nil == self.parentContext);
        NSError * error = nil;
        
        @try {
            if (isRootContext && options) {
                NSMutableDictionary * threadDictionary = [[NSThread currentThread] threadDictionary];
                [threadDictionary setObject:options forKey:PPRequestSpecificOptions];
            }

            isSaved = [self save:&error];
            
            if (isRootContext && options) {
                [[[NSThread currentThread] threadDictionary] removeObjectForKey:PPRequestSpecificOptions];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to perform save: %@", (id)[exception userInfo] ?: (id)[exception reason]);
        }
        @finally {
            if (isSaved) {
                BOOL saveParent = (self.parentContext && [self.parentContext isKindOfClass:[PPManagedObjectContext class]]);
                
                if (saveParent) {
                    PPManagedObjectContext * parentContext = (PPManagedObjectContext *)self.parentContext;
                    [parentContext saveSynchronously:isSynchronously withOptions:options successCallbackQueue:successCallbackQueue failureCallbackQueue:failureCallbackQueue success:success failure:failure];
                }
                else {
                    if (self.parentContext) {
                        NSLog(@"Save brake on context: %@", self.parentContext);
                    }
                    
                    if (success) {
                        if (successCallbackQueue) {
                            dispatch_block_t block = ^{
                                success();
                            };
                            
                            [self dispatchSynchronously:isSynchronously onDispatchQueue:successCallbackQueue withBlock:block];
                        }
                        else {
                            success();
                        }
                    }
                }
            }
            else {
                if (failure) {
                    if (failureCallbackQueue) {
                        dispatch_block_t block = ^{
                            failure(error);
                        };
                        
                        [self dispatchSynchronously:isSynchronously onDispatchQueue:failureCallbackQueue withBlock:block];
                    }
                    else {
                        failure(error);
                    }
                }
            }
        }
    };
    
    if (isSynchronously) {
        [self performBlockAndWait:saveBlock];
    }
    else {
        [self performBlock:saveBlock];
    }

}

#pragma mark Fetch

- (void)executeFetchRequest:(NSFetchRequest *)fetchRequest withSuccess:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure {
    [self executeFetchRequestSynchronously:NO withFetchRequest:fetchRequest options:nil successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)executeFetchRequest:(NSFetchRequest *)fetchRequest withOptions:(id)options success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure {
    [self executeFetchRequestSynchronously:NO withFetchRequest:fetchRequest options:options successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)executeFetchRequestAndWait:(NSFetchRequest *)fetchRequest withSuccess:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure  {
    [self executeFetchRequestSynchronously:YES withFetchRequest:fetchRequest options:nil successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)executeFetchRequestAndWait:(NSFetchRequest *)fetchRequest withOptions:(id)options success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure {
    [self executeFetchRequestSynchronously:YES withFetchRequest:fetchRequest options:options successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)executeFetchRequestSynchronously:(BOOL)isSynchronously withFetchRequest:(NSFetchRequest *)fetchRequest success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure {
    [self executeFetchRequestSynchronously:isSynchronously withFetchRequest:fetchRequest options:nil successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)executeFetchRequestSynchronously:(BOOL)isSynchronously withFetchRequest:(NSFetchRequest *)fetchRequest options:(id)options success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure {
    [self executeFetchRequestSynchronously:isSynchronously withFetchRequest:fetchRequest options:options successCallbackQueue:self.successCallbackQueue failureCallbackQueue:self.failureCallbackQueue success:success failure:failure];
}

- (void)executeFetchRequestSynchronously:(BOOL)isSynchronously withFetchRequest:(NSFetchRequest *)fetchRequest options:(id)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue success:(PPFetchContextSuccess)success failure:(PPFetchContextFailure)failure {
    NSParameterAssert(fetchRequest);
    
    NSManagedObjectContext * rootContext = self;
    
    for (;;) {
        if (rootContext.parentContext) {
            rootContext = rootContext.parentContext;
        }
        else {
            break;
        }
    }
    
    void (^fetchBlock)(void) = ^{
        NSError * error = nil;
        
        if (options) {
            NSMutableDictionary * threadDictionary = [[NSThread currentThread] threadDictionary];
            [threadDictionary setObject:options forKey:PPRequestSpecificOptions];
        }
        
        __block NSArray * fetchResults = [rootContext executeFetchRequest:fetchRequest error:&error];
        
        if (options) {
            [[[NSThread currentThread] threadDictionary] removeObjectForKey:PPRequestSpecificOptions];
        }
        
        if (!error) {
            if (success) {
                if (self != rootContext) {
                    NSMutableArray * mutableFetchedResutls = [NSMutableArray array];
                    
                    for (NSManagedObject * managedObject in fetchResults) {
                        NSManagedObject * object = [self objectWithID:managedObject.objectID];
                        [mutableFetchedResutls addObject:object];
                    }
                    
                    fetchResults = mutableFetchedResutls;
                }
                
                if (successCallbackQueue) {
                    dispatch_block_t block = ^{
                        success(fetchResults);
                    };
                    
                    [self dispatchSynchronously:isSynchronously onDispatchQueue:successCallbackQueue withBlock:block];
                }
                else {
                    success(fetchResults);
                }
            }
        }
        else {
            if (failure) {
                if (failureCallbackQueue) {
                    dispatch_block_t block = ^{
                        failure(error);
                    };
                    
                    [self dispatchSynchronously:isSynchronously onDispatchQueue:failureCallbackQueue withBlock:block];
                }
                else {
                    failure(error);
                }
            }
        }
    };
    
    if (isSynchronously) {
        [rootContext performBlockAndWait:fetchBlock];
    }
    else {
        [rootContext performBlock:fetchBlock];
    }
}

#pragma mark Notifications

- (void)managedObjectContextWillSaveNotification:(NSNotification *)aNotification {
    NSAssert1([aNotification.name isEqualToString:NSManagedObjectContextWillSaveNotification], @"Can't obtain permanent IDs for inserted objects with notification: %@", aNotification);
    
    NSManagedObjectContext * context = (NSManagedObjectContext *)aNotification.object;
    
    if (context && context.insertedObjects.count) {
        NSArray * insertedObjects = [[context insertedObjects] allObjects];
        [context obtainPermanentIDsForObjects:insertedObjects error:nil];
    }
}

- (void)managedObjectContextDidSaveNotification:(NSNotification *)aNotification {
    NSAssert1([aNotification.name isEqualToString:NSManagedObjectContextDidSaveNotification], @"Can't merge changes from context did save notification for notification: %@", aNotification);
    
    [self mergeChangesFromContextDidSaveNotification:aNotification];
}

#pragma mark Subclass Methods

- (void)dispatchSynchronously:(BOOL)isSynchronously onDispatchQueue:(dispatch_queue_t)dispatchQueue withBlock:(dispatch_block_t)block {
    NSParameterAssert(dispatchQueue);
    NSParameterAssert(block);

    if (dispatch_get_main_queue() == dispatchQueue) {
        if ([NSThread isMainThread]) {
            block();
        }
        else if (isSynchronously) {
            dispatch_sync(dispatchQueue, block);
        }
        else {
            dispatch_async(dispatchQueue, block);
        }
    }
    else {
        if (self.isInternalSuccessQueue || self.isInternalFailureQueue) {
            block();
        }
        else if (isSynchronously) {
            dispatch_sync(dispatchQueue, block);
        }
        else {
            dispatch_async(dispatchQueue, block);
        }
    }
}

@end
