//
//  PPStateMachineOperation.h
//  PPCatalog
//
//  Created by Joachim Kret on 29.11.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPDispatchOperation.h"

@class TKStateMachine, TKEvent, TKState;

#pragma mark - PPStateMachineOperation

@interface PPStateMachineOperation : PPDispatchOperation

@property (nonatomic, readonly, strong) TKStateMachine * stateMachine;

- (NSString *)initialStateName;
- (NSArray *)stateNames;
- (NSArray *)eventNames;

- (NSString *)lastEventName;
- (NSString *)lastEventNameIgnoringEvents:(NSArray *)events;

- (NSString *)lastStateName;
- (NSString *)lastStateNameIgnoringStates:(NSArray *)states;

@end

#pragma mark - PPStateMachineOperation (SubclassOnly)

@interface PPStateMachineOperation (SubclassOnly)

- (void)prepareStateMachine;
- (TKState *)stateWithName:(NSString *)name;
- (TKEvent *)eventWithName:(NSString *)name;

- (void)operationStateMachine:(TKStateMachine *)stateMachine willFireEvent:(TKEvent *)event;
- (void)operationStateMachine:(TKStateMachine *)stateMachine didFireEvent:(TKEvent *)event;
- (void)operationStateMachine:(TKStateMachine *)stateMachine willEnterState:(TKState *)state;
- (void)operationStateMachine:(TKStateMachine *)stateMachine didEnterState:(TKState *)state;
- (void)operationStateMachine:(TKStateMachine *)stateMachine willExitState:(TKState *)state;
- (void)operationStateMachine:(TKStateMachine *)stateMachine didExitState:(TKState *)state;

@end
