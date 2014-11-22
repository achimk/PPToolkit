//
//  PPDispatchGroupOperation.h
//  PPCatalog
//
//  Created by Joachim Kret on 30.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPDispatchOperation.h"

@interface PPDispatchGroupOperation : PPDispatchOperation

@property (nonatomic, readonly, strong) NSMutableArray * observedOperations;

- (void)addDependency:(NSOperation *)operation;
- (void)addDependencyAndObserve:(NSOperation *)operation;
- (void)addDependency:(NSOperation *)operation shouldObserve:(BOOL)observe;

@end
