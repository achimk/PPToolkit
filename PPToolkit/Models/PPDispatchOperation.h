//
//  PPDispatchOperation.h
//  PPCatalog
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPOperation.h"

@class PPOperationStateMachine;

@interface PPDispatchOperation : PPOperation

@property (nonatomic, readonly, assign) dispatch_queue_t dispatchQueue;
@property (nonatomic, readonly, assign) dispatch_group_t dispatchGroup;
@property (nonatomic, readonly, strong) PPOperationStateMachine * operationStateMachine;

+ (dispatch_queue_t)defaultDispatchQueue;

- (id)initWithDispatchQueue:(dispatch_queue_t)dispatchQueue;
- (id)initWithIdentifier:(NSString *)identifier dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (BOOL)isInternalDispatchQueue;

@end
