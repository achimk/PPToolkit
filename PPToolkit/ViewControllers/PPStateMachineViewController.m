//
//  PPStateMachineViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 17.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPStateMachineViewController.h"

#import "TransitionKit.h"

#pragma mark - PPStateMachineViewController

@interface PPStateMachineViewController ()
@property (nonatomic, readwrite, strong) TKStateMachine * stateMachine;
@end

#pragma mark -

@implementation PPStateMachineViewController

@synthesize stateMachine = _stateMachine;

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self prepareStateMachine];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self prepareStateMachine];
    }
    
    return self;
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
                [weakSelf stateMachine:stateMachine willFireEvent:event];
            }];
            
            [event setDidFireEventBlock:^(TKEvent * event, TKStateMachine * stateMachine) {
                [weakSelf stateMachine:stateMachine didFireEvent:event];
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
        [weakSelf stateMachine:stateMachine willEnterState:state];
    }];
    [state setDidEnterStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        [weakSelf stateMachine:stateMachine didEnterState:state];
    }];
    [state setWillExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        [weakSelf stateMachine:stateMachine willExitState:state];
    }];
    [state setDidExitStateBlock:^(TKState * state, TKStateMachine * stateMachine) {
        [weakSelf stateMachine:stateMachine didExitState:state];
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

- (void)stateMachine:(TKStateMachine *)stateMachine willFireEvent:(TKEvent *)event {
    //subclasses should override this method...
}

- (void)stateMachine:(TKStateMachine *)stateMachine didFireEvent:(TKEvent *)event {
    //subclasses should override this method...
}

- (void)stateMachine:(TKStateMachine *)stateMachine willEnterState:(TKState *)state {
    //subclasses should override this method...
}

- (void)stateMachine:(TKStateMachine *)stateMachine didEnterState:(TKState *)state {
    //subclasses should override this method...
}

- (void)stateMachine:(TKStateMachine *)stateMachine willExitState:(TKState *)state {
    //subclasses should override this method...
}

- (void)stateMachine:(TKStateMachine *)stateMachine didExitState:(TKState *)state {
    //subclasses should override this method...
}

@end
