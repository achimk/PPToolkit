//
//  PPStateMachineOperation.m
//  PPCatalog
//
//  Created by Joachim Kret on 29.11.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPStateMachineOperation.h"

#import "TransitionKit.h"

#pragma mark - PPStateMachineOperation

@interface PPStateMachineOperation ()
@property (nonatomic, readwrite, strong) TKStateMachine * stateMachine;
@property (nonatomic, readwrite, strong) NSMutableArray * eventHistory;
@property (nonatomic, readwrite, strong) NSMutableArray * stateHistory;
@end

#pragma mark -

@implementation PPStateMachineOperation

@synthesize stateMachine = _stateMachine;
@synthesize eventHistory = _eventHistory;
@synthesize stateHistory = _stateHistory;

#pragma mark Init

- (id)initWithIdentifier:(NSString *)identifier dispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (self = [super initWithIdentifier:identifier dispatchQueue:dispatchQueue]) {
        _eventHistory = [NSMutableArray new];
        _stateHistory = [NSMutableArray new];
        [self prepareStateMachine];
    }

    return self;
}

#pragma mark Accessors

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p identifier: %@, state: %@, state machine state: %@, concurrent: %@, cancelled: %@, error: %@>",
            [self class],
            self,
            self.identifier,
            PPStringNameForStateOfOperation(self),
            self.stateMachine.currentState.name,
            PPStringFromBool(self.isConcurrent),
            PPStringFromBool(self.isCancelled),
            self.error];
}

#pragma mark History

- (NSString *)lastEventName {
    return [self lastEventNameIgnoringEvents:nil];
}

- (NSString *)lastEventNameIgnoringEvents:(NSArray *)events {
    NSMutableArray * eventNames = [NSMutableArray array];
    
    if (events) {
        for (id event in events) {
            if ([event isKindOfClass:[TKEvent class]]) {
                [eventNames addObject:[(TKEvent *)event name]];
            }
            else if ([event isKindOfClass:[NSString class]]) {
                [eventNames addObject:event];
            }
        }
    }
    
    __block NSString * result = nil;
    dispatch_block_t block = ^{
        for (NSString * event in self.eventHistory) {
            if (![eventNames containsObject:event]) {
                result = [event copy];
                break;
            }
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_sync(self.dispatchQueue, block);
    }
    
    return result;
}

- (NSString *)lastStateName {
    return [self lastStateNameIgnoringStates:nil];
}

- (NSString *)lastStateNameIgnoringStates:(NSArray *)states {
    NSMutableArray * stateNames = [NSMutableArray array];
    
    if (states) {
        for (id state in states) {
            if ([state isKindOfClass:[TKState class]]) {
                [stateNames addObject:[(TKState *)state name]];
            }
            else if ([state isKindOfClass:[NSString class]]) {
                [stateNames addObject:state];
            }
        }
    }
    
    __block NSString * result = nil;
    dispatch_block_t block = ^{
        for (NSString * state in self.stateHistory) {
            if (![stateNames containsObject:state]) {
                result = [state copy];
                break;
            }
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_sync(self.dispatchQueue, block);
    }
    
    return result;
}

#pragma mark Subclass Methods

- (void)prepareStateMachine {
    if (self.stateMachine) {
        return;
    }
    
    self.stateMachine = [TKStateMachine new];
    NSArray * stateNames = [self stateNames];
    NSArray * eventNames = [self eventNames];
    
    for (NSString * stateName in stateNames) {
        TKState * state = [self stateWithName:stateName];
        
        if (state) {
            [self.stateMachine addState:state];
        }
    }
    
    for (NSString * eventName in eventNames) {
        TKEvent * event = [self eventWithName:eventName];
        
        if (event) {
            __weak __typeof(&*self) weakSelf = self;
            [event setWillFireEventBlock:^(TKEvent * event, TKStateMachine * stateMachine) {
                if (weakSelf.isInternalDispatchQueue) {
                    [weakSelf.eventHistory addObject:event.name];
                    [weakSelf operationStateMachine:stateMachine willFireEvent:event];
                }
                else {
                    __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                    dispatch_async(weakSelf.dispatchQueue, ^{
                        [strongSelf.eventHistory addObject:event.name];
                        [strongSelf operationStateMachine:stateMachine willFireEvent:event];
                    });
                }
            }];
            
            [event setDidFireEventBlock:^(TKEvent * event, TKStateMachine * stateMachine) {
                if (weakSelf.isInternalDispatchQueue) {
                    [weakSelf operationStateMachine:stateMachine didFireEvent:event];
                }
                else {
                    __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                    dispatch_async(weakSelf.dispatchQueue, ^{
                        [strongSelf operationStateMachine:stateMachine didFireEvent:event];
                    });
                }
            }];
            
            [self.stateMachine addEvent:event];
        }
    }
    
    TKState * initialState = [self.stateMachine stateNamed:[self initialStateName]];
    
    if (initialState) {
        self.stateMachine.initialState = initialState;
    }
}

- (NSString *)initialStateName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to return initial state name. Subclasses should implement '%@' method.",
                                           NSStringFromClass([self class]), NSStringFromSelector(@selector(_cmd))]
                                 userInfo:nil];
    return nil;
}

- (NSArray *)stateNames {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to return state names. Subclasses should implement '%@' method.",
                                           NSStringFromClass([self class]), NSStringFromSelector(@selector(_cmd))]
                                 userInfo:nil];
    return nil;
}

- (NSArray *)eventNames {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to return event names. Subclasses should implement '%@' method.",
                                           NSStringFromClass([self class]), NSStringFromSelector(@selector(_cmd))]
                                 userInfo:nil];
    return nil;
}

- (TKState *)stateWithName:(NSString *)name {
    NSParameterAssert(name);
    NSAssert(name && name.length, @"State name is empty");
    
    if (!name || !name.length) {
        return nil;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    TKState * state = [TKState stateWithName:name];
    [state setWillEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        if (weakSelf.isInternalDispatchQueue) {
            [weakSelf.stateHistory addObject:state.name];
            [weakSelf operationStateMachine:stateMachine willEnterState:state];
        }
        else {
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            dispatch_async(weakSelf.dispatchQueue, ^{
                [strongSelf.stateHistory addObject:state.name];
                [strongSelf operationStateMachine:stateMachine willEnterState:state];
            });
        }
    }];
    [state setDidEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        if (weakSelf.isInternalDispatchQueue) {
            [weakSelf operationStateMachine:stateMachine didEnterState:state];
        }
        else {
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            dispatch_async(weakSelf.dispatchQueue, ^{
                [strongSelf operationStateMachine:stateMachine didEnterState:state];
            });
        }
    }];
    [state setWillExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        if (weakSelf.isInternalDispatchQueue) {
            [weakSelf operationStateMachine:stateMachine willExitState:state];
        }
        else {
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            dispatch_async(weakSelf.dispatchQueue, ^{
                [strongSelf operationStateMachine:stateMachine willExitState:state];
            });
        }
    }];
    [state setDidExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        if (weakSelf.isInternalDispatchQueue) {
            [weakSelf operationStateMachine:stateMachine didExitState:state];
        }
        else {
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            dispatch_async(weakSelf.dispatchQueue, ^{
                [strongSelf operationStateMachine:stateMachine didExitState:state];
            });
        }
    }];
    
    return state;
}

- (TKEvent *)eventWithName:(NSString *)name {
    NSParameterAssert(name);
    NSAssert(name && name.length, @"Event name is empty");
    NSAssert([[self.stateMachine.states allObjects] count], @"Can't create event for empty states list");
    
    if (!name || !name.length || ![[self.stateMachine.states allObjects] count]) {
        return nil;
    }
    
    //default queue all states in FIFO order
    NSInteger index = [[self eventNames] indexOfObject:name];
    NSArray * stateNames = [self stateNames];
    TKEvent * lastEvent = (0 < index) ? [self.stateMachine eventNamed:[[self eventNames] objectAtIndex:index - 1]] : nil;
    TKState * sourceState = nil;
    TKState * destinationState = nil;
    
    if (lastEvent) {
        index = [stateNames indexOfObject:[lastEvent.destinationState name]];
        NSString * destinationStateName = [stateNames objectAtIndex:(index + 1)];
        sourceState = lastEvent.destinationState;
        destinationState = [self.stateMachine stateNamed:destinationStateName];
    }
    else {
        index = [stateNames indexOfObject:[self initialStateName]];
        NSString * destinationStateName = [stateNames objectAtIndex:(index + 1)];
        sourceState = [self.stateMachine stateNamed:[self initialStateName]];
        destinationState = [self.stateMachine stateNamed:destinationStateName];
    }
    
    return [TKEvent eventWithName:name transitioningFromStates:@[sourceState] toState:destinationState];
}

- (void)operationStateMachine:(TKStateMachine *)stateMachine willFireEvent:(TKEvent *)event {
    //subclasses should override this method...
}

- (void)operationStateMachine:(TKStateMachine *)stateMachine didFireEvent:(TKEvent *)event {
    //subclasses should override this method...
}

- (void)operationStateMachine:(TKStateMachine *)stateMachine willEnterState:(TKState *)state {
    //subclasses should override this method...
}

- (void)operationStateMachine:(TKStateMachine *)stateMachine didEnterState:(TKState *)state {
    //subclasses should override this method...
}

- (void)operationStateMachine:(TKStateMachine *)stateMachine willExitState:(TKState *)state {
    //subclasses should override this method...
}

- (void)operationStateMachine:(TKStateMachine *)stateMachine didExitState:(TKState *)state {
    //subclasses should override this method...
}

@end
