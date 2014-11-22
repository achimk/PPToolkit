//
//  PPManagedLoadingCollectionViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 29.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedLoadingCollectionViewController.h"

#import "PPCollectionViewCell.h"
#import "UIViewController+PPToolkitExtensions.h"

NSString * const PPManagedLoadingCollectionViewControllerFailureException       = @"PPManagedLoadingCollectionViewControllerFailureException";

#pragma mark - PPManagedCollectionViewController

@interface PPManagedCollectionViewController ()
@property (nonatomic, readonly, strong) NSMutableArray * sectionChanges;
@property (nonatomic, readonly, strong) NSMutableArray * objectChanges;
@end

#pragma mark - PPManagedLoadingCollectionViewController

@interface PPManagedLoadingCollectionViewController ()

@property (nonatomic, readwrite, assign) PPLoadingState state;
@property (nonatomic, readwrite, assign) BOOL showsLoadingCell;

@end

#pragma mark -

@implementation PPManagedLoadingCollectionViewController

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
    
    if ([[self class] defaultLoadingCollectionViewCellClass]) {
        [self.collectionView registerClass:[[self class] defaultLoadingCollectionViewCellClass] forCellWithReuseIdentifier:NSStringFromClass([[self class] defaultLoadingCollectionViewCellClass])];
    }
    else if ([[self class] defaultLoadingCollectionViewCellNibName]) {
        [self.collectionView registerNib:[UINib nibWithNibName:[[self class] defaultLoadingCollectionViewCellNibName] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[[self class] defaultLoadingCollectionViewCellNibName]];
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
    
    NSInteger sections = [self.collectionView numberOfSections];
    
    if (!sections) {
        return nil;
    }
    
    NSInteger rows = [self.collectionView numberOfItemsInSection:sections - 1];
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
    [NSException raise:PPManagedLoadingCollectionViewControllerFailureException format:@"Failed to load data. Implement method: '%@' with state: %@", NSStringFromSelector(_cmd), PPStringFromLoadingState(state)];
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
    
    NSInteger sections = [self.collectionView numberOfSections];
    NSInteger rows = [self.collectionView numberOfItemsInSection:sections - 1];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:((showsLoadingCell) ? rows - 1 : rows) inSection:sections - 1];
    
    self.showsLoadingCell = [self shouldShowLoadingCellWithState:newState];
    
    //show loading cell
    if (self.showsLoadingCell && !showsLoadingCell) {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        } completion:NULL];
    }
    else if (!self.showsLoadingCell && showsLoadingCell) { //hide loading cell
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } completion:NULL];
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

#pragma mark PSUICollectionViewDelegate

- (BOOL)collectionView:(PSUICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return ![self isLoadingCell:indexPath];
}

#pragma mark PSUICollectionViewDataSource

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSUICollectionViewCell * cell = nil;
    NSString * identifier = nil;
    
    if ([self isLoadingCell:indexPath]) {
        if ([[self class] defaultLoadingCollectionViewCellClass]) {
            identifier = NSStringFromClass([[self class] defaultLoadingCollectionViewCellClass]);
        }
        else if ([[self class] defaultLoadingCollectionViewCellNibName]) {
            identifier = [[self class] defaultLoadingCollectionViewCellNibName];
        }
        
        if (identifier) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            
            if ([cell conformsToProtocol:@protocol(PPCollectionViewCellProtocol)]) {
                [(id <PPCollectionViewCellProtocol>)cell configureViews];
            }
            
            [self loadingAction:indexPath];
        }
    }
    else {
        cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return (self.showsLoadingCell) ? [sectionInfo numberOfObjects] + 1 : [sectionInfo numberOfObjects];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (PPFetchedResultsChangeTypeUpdate == self.changeType ||
        _PPCollectionViewControllerFlags.useChangeAnimations) {
        _PPCollectionViewControllerFlags.useChangeAnimations = NO;
        
        if (0 < self.sectionChanges.count) {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary * change in self.sectionChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, id obj, BOOL * stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        
                        switch (type) {
                            case NSFetchedResultsChangeInsert: {
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            case NSFetchedResultsChangeDelete: {
                                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            case NSFetchedResultsChangeUpdate: {
                                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            default: {
                                break;
                            }
                        }
                    }];
                }
            } completion:NULL];
        }
        
        if (0 < self.objectChanges.count && 0 == self.sectionChanges.count) {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary * change in self.objectChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, id obj, BOOL * stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        
                        switch (type) {
                            case NSFetchedResultsChangeInsert: {
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            }
                            case NSFetchedResultsChangeDelete: {
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            }
                            case NSFetchedResultsChangeUpdate: {
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            }
                            case NSFetchedResultsChangeMove: {
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                            }
                            default: {
                                break;
                            }
                        }
                    }];
                }
            } completion:NULL];
        }
    }
    else {
        [self setNeedsReload];
    }
    
    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
}

@end
