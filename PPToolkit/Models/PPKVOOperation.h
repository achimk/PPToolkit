//
//  PPKVOOperation.h
//  PPCatalog
//
//  Created by Joachim Kret on 26.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPOperation.h"

typedef enum {
    PPKVOOperationStateReady    = 1,
    PPKVOOperationStateExecuting,
    PPKVOOperationStateFinished
} PPKVOOperationState;

#pragma mark - PPKVOOperation

@interface PPKVOOperation : PPOperation

@property (nonatomic, readonly, assign) PPKVOOperationState state;

@end

#pragma mark - Utilities

extern NSString * PPKVOKeyPathFromOperationState(PPKVOOperationState state);
extern BOOL PPKVOStateTransitionIsValid(PPKVOOperationState fromState, PPKVOOperationState toState, BOOL isCancelled);
