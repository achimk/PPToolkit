//
//  PPStateMachineViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 17.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPViewController.h"

@class TKStateMachine, TKEvent, TKState;

#pragma mark - PPStateMachineViewController

@interface PPStateMachineViewController : PPViewController

@property (nonatomic, readonly, strong) TKStateMachine * stateMachine;

- (NSString *)initialStateName;
- (NSArray *)stateNames;
- (NSArray *)eventNames;

@end

#pragma mark - PPStateMachineViewController (SubclassOnly)

@interface PPStateMachineViewController (SubclassOnly)

- (void)prepareStateMachine;
- (TKState *)stateWithName:(NSString *)name;
- (TKEvent *)eventWithName:(NSString *)name;

- (void)stateMachine:(TKStateMachine *)stateMachine willFireEvent:(TKEvent *)event;
- (void)stateMachine:(TKStateMachine *)stateMachine didFireEvent:(TKEvent *)event;
- (void)stateMachine:(TKStateMachine *)stateMachine willEnterState:(TKState *)state;
- (void)stateMachine:(TKStateMachine *)stateMachine didEnterState:(TKState *)state;
- (void)stateMachine:(TKStateMachine *)stateMachine willExitState:(TKState *)state;
- (void)stateMachine:(TKStateMachine *)stateMachine didExitState:(TKState *)state;

@end
