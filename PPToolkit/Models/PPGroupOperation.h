//
//  PPGroupOperation.h
//  PPCatalog
//
//  Created by Joachim Kret on 27.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPOperation.h"

@interface PPGroupOperation : PPOperation

@property (nonatomic, readonly, strong) NSMutableArray * observedOperations;

- (void)addDependency:(NSOperation *)operation;
- (void)addDependencyAndObserve:(NSOperation *)operation;
- (void)addDependency:(NSOperation *)operation shouldObserve:(BOOL)observe;

@end
