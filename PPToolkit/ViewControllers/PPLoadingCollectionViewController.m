//
//  PPLoadingCollectionViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 29.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPLoadingCollectionViewController.h"

#import "PPCollectionViewCell.h"

NSString * const PPLoadingCollectionViewControllerFailureException      = @"PPLoadingCollectionViewControllerFailureException";

#pragma mark - PPLoadingCollectionViewController

@interface PPLoadingCollectionViewController ()

@property (nonatomic, readwrite, assign) PPLoadingState state;
@property (nonatomic, readwrite, assign) BOOL showsLoadingCell;

@end

#pragma mark -

@implementation PPLoadingCollectionViewController

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
    [NSException raise:PPLoadingCollectionViewControllerFailureException format:@"Failed to load data. Implement method: '%@' with state: %@", NSStringFromSelector(_cmd), PPStringFromLoadingState(state)];
}

- (void)loadDataDidSuccessWithState:(PPLoadingState)state {
    PPLoadingState newState = (self.isEmpty) ? PPLoadingStateEmpty : PPLoadingStateIdle;
    [self changeCurrentStateWithState:newState];
}

- (void)loadDataDidFailureWithState:(PPLoadingState)state error:(NSError *)error {
    [self changeCurrentStateWithState:PPLoadingStateError];
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
    return 1;
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (self.showsLoadingCell) ? 1 : 0;
}

@end
