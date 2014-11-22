//
//  PPManagedLoadingTableViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 23.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedTableViewController.h"

#import "PPToolkitDefines.h"

extern NSString * const PPManagedLoadingTableViewControllerFailureException;

#pragma mark - PPManagedLoadingTableViewController

@interface PPManagedLoadingTableViewController : PPManagedTableViewController {
@protected
    PPLoadingState      _state;
    BOOL                _stateActive;
    BOOL                _showsLoadingCell;
}

@property (nonatomic, readonly, assign) PPLoadingState state;
@property (nonatomic, readonly, assign, getter = isStateActive) BOOL stateActive;
@property (nonatomic, readonly, assign) BOOL showsLoadingCell;
 
+ (Class)defaultLoadingTableViewCellClass;
+ (NSString *)defaultLoadingTableViewCellNibName;

- (BOOL)isLoadingCell:(NSIndexPath *)indexPath;
- (NSIndexPath *)loadingCellIndexPath;

- (IBAction)initialAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)loadingAction:(id)sender;

@end

#pragma mark - PPManagedLoadingTableViewController (SubclassOnly)

@interface PPManagedLoadingTableViewController (SubclassOnly)

- (PPLoadingState)initialState;
- (BOOL)changeCurrentStateWithState:(PPLoadingState)state;
- (BOOL)canChangeStateFromState:(PPLoadingState)oldState toState:(PPLoadingState)newState;

- (void)willChangeState:(PPLoadingState)oldState toState:(PPLoadingState)newState;
- (void)willExitState:(PPLoadingState)state;
- (void)willEnterState:(PPLoadingState)state;
- (void)didExitState:(PPLoadingState)state;
- (void)didEnterState:(PPLoadingState)state;
- (void)didChangeState:(PPLoadingState)oldState toState:(PPLoadingState)newState;

- (void)loadDataWithState:(PPLoadingState)state success:(void(^)(void))success failure:(void(^)(NSError *))failure;
- (void)loadDataDidSuccessWithState:(PPLoadingState)state;
- (void)loadDataDidFailureWithState:(PPLoadingState)state error:(NSError *)error;
- (void)updateLoadingCellFromState:(PPLoadingState)oldState toState:(PPLoadingState)newState;
- (BOOL)shouldShowLoadingCellWithState:(PPLoadingState)state;

@end
