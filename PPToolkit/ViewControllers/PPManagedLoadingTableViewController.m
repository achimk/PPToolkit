//
//  PPManagedLoadingTableViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 23.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedLoadingTableViewController.h"

#import "PPTableViewCell.h"
#import "UIViewController+PPToolkitExtensions.h"

NSString * const PPManagedLoadingTableViewControllerFailureException    = @"PPManagedLoadingTableViewControllerFailureException";

#pragma mark - PPManagedLoadingTableViewController

@interface PPManagedLoadingTableViewController ()

@property (nonatomic, readwrite, assign) PPLoadingState state;
@property (nonatomic, readwrite, assign) BOOL showsLoadingCell;

@end

#pragma mark -

@implementation PPManagedLoadingTableViewController

@synthesize state = _state;
@synthesize stateActive = _stateActive;
@synthesize showsLoadingCell = _showsLoadingCell;

+ (Class)defaultLoadingTableViewCellClass {
    return nil;
}

+ (NSString *)defaultLoadingTableViewCellNibName {
    return nil;
}

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _state = PPLoadingStateEmpty;
        _stateActive = NO;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _state = PPLoadingStateEmpty;
        _stateActive = NO;
    }
    
    return self;
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[self class] defaultLoadingTableViewCellClass]) {
        [self.tableView registerClass:[[self class] defaultLoadingTableViewCellClass] forCellReuseIdentifier:NSStringFromClass([[self class] defaultLoadingTableViewCellClass])];
    }
    else if ([[self class] defaultLoadingTableViewCellNibName]) {
        [self.tableView registerNib:[UINib nibWithNibName:[[self class] defaultLoadingTableViewCellNibName] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[[self class] defaultLoadingTableViewCellNibName]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.isStateActive) {
        _state = self.initialState;
        _stateActive = YES;
    }
    
    BOOL isSuccess = [self changeCurrentStateWithState:PPLoadingStateInitial];
    
    if (!isSuccess) {
        [self changeCurrentStateWithState:PPLoadingStateRefresh];
    }
    
    [super viewWillAppear:animated];
}

#pragma mark Accessors

- (BOOL)isLoadingCell:(NSIndexPath *)indexPath {
    return [indexPath isEqual:self.loadingCellIndexPath];
}

- (NSIndexPath *)loadingCellIndexPath {
    if (!self.showsLoadingCell) {
        return nil;
    }
    
    NSInteger sections = [self.tableView numberOfSections];
    
    if (!sections) {
        return nil;
    }
    
    NSInteger rows = [self.tableView numberOfRowsInSection:sections - 1];
    return [NSIndexPath indexPathForRow:rows - 1 inSection:sections - 1];
}

- (void)setState:(PPLoadingState)state {
    if (state != _state) {
        [self willChangeValueForKey:@"state"];
        
        PPLoadingState oldState = _state;
        [self willChangeState:oldState toState:state];
        [self willExitState:oldState];
        [self willEnterState:state];
        
        _state = state;
        
        [self didExitState:oldState];
        [self didEnterState:state];
        [self didChangeState:oldState toState:state];
        
        [self didChangeValueForKey:@"state"];
    }
}

#pragma mark Actions

- (IBAction)initialAction:(id)sender {
    [self changeCurrentStateWithState:PPLoadingStateInitial];
}

- (IBAction)refreshAction:(id)sender {
    [self changeCurrentStateWithState:PPLoadingStateRefresh];
}

- (IBAction)loadingAction:(id)sender {
    [self changeCurrentStateWithState:PPLoadingStateLoading];
}

#pragma mark Public Methods

- (void)reloadData {
    self.showsLoadingCell = [self shouldShowLoadingCellWithState:self.state];
    [super reloadData];
}

#pragma mark Subclass Methods

- (PPLoadingState)initialState {
    return (self.isEmpty) ? PPLoadingStateEmpty : PPLoadingStateIdle;
}

- (BOOL)changeCurrentStateWithState:(PPLoadingState)state {
    if ([self canChangeStateFromState:self.state toState:state]) {
        self.state = state;
        return YES;
    }
    
    return NO;
}

- (BOOL)canChangeStateFromState:(PPLoadingState)oldState toState:(PPLoadingState)newState {
    if (!self.isStateActive) {
        return NO;
    }
    
    switch (newState) {
        case PPLoadingStateIdle:
        case PPLoadingStateEmpty:
        case PPLoadingStateError: {
            switch (oldState) {
                case PPLoadingStateInitial:
                case PPLoadingStateRefresh:
                case PPLoadingStateLoading: {
                    return YES;
                }
                default: {
                    break;
                }
            }
            
            break;
        }
        case PPLoadingStateInitial:
        case PPLoadingStateRefresh: {
            switch (oldState) {
                case PPLoadingStateIdle:
                case PPLoadingStateEmpty:
                case PPLoadingStateError:
                case PPLoadingStateLoading: {
                    return YES;
                }
                default: {
                    break;
                }
            }
            
            break;
        }
        case PPLoadingStateLoading: {
            switch (oldState) {
                case PPLoadingStateIdle:
                case PPLoadingStateEmpty:
                case PPLoadingStateError: {
                    return YES;
                }
                default: {
                    break;
                }
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
    return NO;
}

- (void)willChangeState:(PPLoadingState)oldState toState:(PPLoadingState)newState {
    //Subclasses can override this method
}

- (void)willExitState:(PPLoadingState)state {
    //Subclasses can override this method
}

- (void)willEnterState:(PPLoadingState)state {
    //Subclasses can override this method
}

- (void)didExitState:(PPLoadingState)state {
    //Subclasses can override this method
}

- (void)didEnterState:(PPLoadingState)state {
    //Subclasses can override this method
}

- (void)didChangeState:(PPLoadingState)oldState toState:(PPLoadingState)newState {
    switch (self.changeType) {
        case PPFetchedResultsChangeTypeUpdate: {
            if (self.isViewVisible && PPViewControllerLifeCyclePhaseViewWillAppear < self.lifeCyclePhase) {
                [self updateLoadingCellFromState:oldState toState:newState];
                break;
            }
        }
        case PPFetchedResultsChangeTypeReload:
        case PPFetchedResultsChangeTypeIgnore:
        default: {
            switch (newState) {
                case PPLoadingStateIdle:
                case PPLoadingStateEmpty:
                case PPLoadingStateError:
                case PPLoadingStateInitial:
                case PPLoadingStateRefresh: {
                    [self setNeedsReload];
                    break;
                }
                default: {
                    break;
                }
            }
            
            [self reloadIfNeeded];
            break;
        }
    }
    
    switch (newState) {
        case PPLoadingStateInitial:
        case PPLoadingStateRefresh:
        case PPLoadingStateLoading: {
            __weak __typeof(&*self) weakSelf = self;
            
            void (^successCallback)(void) = ^{
                if (newState == weakSelf.state) {
                    [weakSelf loadDataDidSuccessWithState:newState];
                }
            };
            
            void (^failureCallback)(NSError *) = ^(NSError * error) {
                if (newState == weakSelf.state) {
                    [weakSelf loadDataDidFailureWithState:newState error:error];
                }
            };
            
            [self loadDataWithState:newState success:successCallback failure:failureCallback];
            
            break;
        }
        default: {
            break;
        }
    }
}

- (void)loadDataWithState:(PPLoadingState)state success:(void(^)(void))success failure:(void(^)(NSError *))failure {
    [NSException raise:PPManagedLoadingTableViewControllerFailureException format:@"Failed to load data. Implement method: '%@' with state: %@", NSStringFromSelector(_cmd), PPStringFromLoadingState(state)];
}

- (void)loadDataDidSuccessWithState:(PPLoadingState)state {
    PPLoadingState newState = (self.isEmpty) ? PPLoadingStateEmpty : PPLoadingStateIdle;
    [self changeCurrentStateWithState:newState];
}

- (void)loadDataDidFailureWithState:(PPLoadingState)state error:(NSError *)error {
    [self changeCurrentStateWithState:PPLoadingStateError];
}

- (void)updateLoadingCellFromState:(PPLoadingState)oldState toState:(PPLoadingState)newState {
    NSAssert(PPFetchedResultsChangeTypeUpdate == self.changeType, @"Update loading cell allowed only for 'PPFetchedResultsChangeTypeUpdate' change type");
    BOOL showsLoadingCell = self.showsLoadingCell;
    
    NSInteger sections = [self.tableView numberOfSections];
    NSInteger rows = [self.tableView numberOfRowsInSection:sections - 1];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:((showsLoadingCell) ? rows - 1 : rows) inSection:sections - 1];
    
    self.showsLoadingCell = [self shouldShowLoadingCellWithState:newState];
    
    //show loading cell
    if (self.showsLoadingCell && !showsLoadingCell) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else if (!self.showsLoadingCell && showsLoadingCell) { //hide loading cell
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (BOOL)shouldShowLoadingCellWithState:(PPLoadingState)state {
    switch (state) {
        case PPLoadingStateIdle:
        case PPLoadingStateEmpty:
        case PPLoadingStateLoading: {
            return YES;
        }
        default: {
            return NO;
        }
    }
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return ![self isLoadingCell:indexPath];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    NSString * identifier = nil;
    
    if ([self isLoadingCell:indexPath]) {
        if ([[self class] defaultLoadingTableViewCellClass]) {
            identifier = NSStringFromClass([[self class] defaultLoadingTableViewCellClass]);
        }
        else if ([[self class]  defaultLoadingTableViewCellNibName]) {
            identifier = [[self class] defaultLoadingTableViewCellNibName];
        }
        
        if (identifier) {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if ([cell conformsToProtocol:@protocol(PPTableViewCellProtocol)]) {
                [(id <PPTableViewCellProtocol>)cell configureViews];
            }
            
            [self loadingAction:indexPath];
        }
    }
    else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return (self.showsLoadingCell) ? [sectionInfo numberOfObjects] + 1 : [sectionInfo numberOfObjects];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (PPFetchedResultsChangeTypeUpdate == self.changeType ||
        _PPTableViewControllerFlags.useChangeAnimations) {
        _PPTableViewControllerFlags.useChangeAnimations = NO;
        [self.tableView endUpdates];
    }
    else {
        [self setNeedsReload];
    }
}

@end
