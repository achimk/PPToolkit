//
//  PPManagedCollectionViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 23.05.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedCollectionViewController.h"

#import "UIViewController+PPToolkitExtensions.h"
#import "PPCollectionViewCell.h"

#pragma mark - PPManagedCollectionViewController

@interface PPManagedCollectionViewController ()

@property (nonatomic, readwrite, strong) PSUICollectionViewLayout * layout;
@property (nonatomic, readonly, strong) NSMutableArray * sectionChanges;
@property (nonatomic, readonly, strong) NSMutableArray * objectChanges;

@end

#pragma mark -

@implementation PPManagedCollectionViewController

@synthesize layout = _layout;
@synthesize collectionView = _collectionView;
@synthesize sectionChanges = _sectionChanges;
@synthesize objectChanges = _objectChanges;
@dynamic clearsSelectionOnViewWillAppear;
@dynamic reloadOnAppearsFirstTime;

+ (Class)defaultCollectionViewClass {
    return [PSUICollectionView class];
}

+ (Class)defaultCollectionViewLayoutClass {
    return [PSUICollectionViewFlowLayout class];
}

+ (Class)defaultCollectionViewCellClass {
    return nil;
}

+ (NSString *)defaultCollectionViewCellNibName {
    return nil;
}

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _PPViewControllerFlags.appearsFirstTime = YES;
        _PPCollectionViewControllerFlags.reloadOnAppearsFirstTime = YES;
        _PPCollectionViewControllerFlags.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (id)initWithCollectionViewLayout:(PSUICollectionViewLayout *)layout {
    if (self = [self initWithNibName:nil bundle:nil]) {
        if (layout) {
            self.layout = layout;
        }
        
        self.collectionView = [(PSUICollectionView *)[[[self class] defaultCollectionViewCellClass] alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _PPViewControllerFlags.appearsFirstTime = YES;
        _PPCollectionViewControllerFlags.reloadOnAppearsFirstTime = YES; 
        _PPCollectionViewControllerFlags.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if (!_collectionView) {
        self.collectionView = [(PSUICollectionView *)[[[self class] defaultCollectionViewClass] alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[self class] defaultCollectionViewCellClass]) {
        [self.collectionView registerClass:[[self class] defaultCollectionViewCellClass] forCellWithReuseIdentifier:NSStringFromClass([[self class] defaultCollectionViewCellClass])];
    }
    else if ([[self class] defaultCollectionViewCellNibName]) {
        [self.collectionView registerNib:[UINib nibWithNibName:[[self class] defaultCollectionViewCellNibName] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[[self class] defaultCollectionViewCellNibName]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.appearsFirstTime && self.reloadOnAppearsFirstTime) {
        [self reloadData];
    }
    else {
        [self reloadIfNeeded];
    }
    
    if (self.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath * indexPath in [[self.collectionView indexPathsForSelectedItems] copy]) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
        }
    }
}

- (void)releaseViews {
    [super releaseViews];
    self.collectionView = nil;
}

#pragma mark Accessors

- (void)setClearsSelectionOnViewWillAppear:(BOOL)clearsSelectionOnViewWillAppear {
    _PPCollectionViewControllerFlags.clearsSelectionOnViewWillAppear = clearsSelectionOnViewWillAppear;
}

- (BOOL)clearsSelectionOnViewWillAppear {
    return _PPCollectionViewControllerFlags.clearsSelectionOnViewWillAppear;
}

- (void)setClearsSelectionOnReloadData:(BOOL)clearsSelectionOnReloadData {
    _PPCollectionViewControllerFlags.clearsSelectionOnReloadData = clearsSelectionOnReloadData;
}

- (BOOL)clearsSelectionOnReloadData {
    return _PPCollectionViewControllerFlags.clearsSelectionOnReloadData;
}

- (void)setReloadOnAppearsFirstTime:(BOOL)reloadOnAppearsFirstTime {
    _PPCollectionViewControllerFlags.reloadOnAppearsFirstTime = reloadOnAppearsFirstTime;
}

- (BOOL)reloadOnAppearsFirstTime {
    return _PPCollectionViewControllerFlags.reloadOnAppearsFirstTime;
}

- (void)setNeedsReload {
    _PPCollectionViewControllerFlags.needsReload = YES;
}

- (BOOL)needsReload {
    return _PPCollectionViewControllerFlags.needsReload;
}

- (PSUICollectionViewLayout *)layout {
    if (!_layout) {
        _layout = [[[self class] defaultCollectionViewLayoutClass] new];
    }
    return _layout;
}

- (void)setCollectionView:(PSUICollectionView *)collectionView {
    if (collectionView != _collectionView) {
        if (_collectionView) {
            [_collectionView removeFromSuperview];
            _collectionView.delegate = nil;
            _collectionView.dataSource = nil;
        }
        
        _collectionView = collectionView;
        
        if (collectionView) {
            collectionView.delegate = self;
            collectionView.dataSource = self;

            if (!collectionView.superview) {
                collectionView.frame = self.view.bounds;
                collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.view addSubview:collectionView];
            }
        }
    }
}

- (NSMutableArray *)sectionChanges {
    if (!_sectionChanges) {
        _sectionChanges = [NSMutableArray new];
    }
    
    return _sectionChanges;
}

- (NSMutableArray *)objectChanges {
    if (!_objectChanges) {
        _objectChanges = [NSMutableArray new];
    }
    
    return _objectChanges;
}

#pragma mark Public Methods

- (void)reloadIfNeeded {
    if (self.needsReload) {
        [self reloadData];
    }
}

- (void)reloadIfVisible {
    if (self.isViewVisible) {
        [self reloadData];
    }
    else {
        [self setNeedsReload];
    }
}

- (void)reloadData {
    _PPCollectionViewControllerFlags.needsReload = NO;
    
    if (self.clearsSelectionOnReloadData) {
        [self.collectionView reloadData];
    }
    else {
        NSArray * selectedItems = [[self.collectionView indexPathsForSelectedItems] copy];
        
        [self.collectionView reloadData];
        
        for (NSIndexPath * indexPath in selectedItems) {
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:PSTCollectionViewScrollPositionNone];
        }
    }
}

#pragma mark Keyboard

- (BOOL)shouldAcceptScrollView:(UIScrollView *)scrollView forKeyboardNotification:(NSNotification *)aNotification {
    return NO; //default NO accept keyboard for CollectionView
}

#pragma mark CollectionView Additional Accessors

- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath {
    return [self viewIndexPathForController:self.fetchedResultsController fetchedIndexPath:fetchedIndexPath];
}

- (NSIndexPath *)viewIndexPathForController:(NSFetchedResultsController *)controller fetchedIndexPath:(NSIndexPath *)fetchedIndexPath {
    return fetchedIndexPath;
}

- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath {
    return [self fetchedIndexPathForController:self.fetchedResultsController viewIndexPath:viewIndexPath];
}

- (NSIndexPath *)fetchedIndexPathForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)viewIndexPath {
    return viewIndexPath;
}

- (id)objectForViewIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:[self fetchedIndexPathForViewIndexPath:indexPath]];
}

- (id)objectForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)indexPath {
    if (controller == self.fetchedResultsController) {
        return [self.fetchedResultsController objectAtIndexPath:[self fetchedIndexPathForController:controller viewIndexPath:indexPath]];
    }
    return nil;
}

#pragma mark PSUICollectionViewDataSource

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PSUICollectionViewCell * cell = nil;
    NSString * identifier = nil;
    
    if ([[self class] defaultCollectionViewCellClass]) {
        identifier = NSStringFromClass([[self class] defaultCollectionViewCellClass]);
    }
    else if ([[self class] defaultCollectionViewCellNibName]) {
        identifier = [[self class] defaultCollectionViewCellNibName];
    }
    
    if (identifier) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        if ([cell conformsToProtocol:@protocol(PPCollectionViewCellProtocol)]) {
            NSManagedObject * managedObject = [self objectForController:self.fetchedResultsController viewIndexPath:indexPath];
            [(PSUICollectionViewCell <PPCollectionViewCellProtocol> *)cell configureForData:managedObject collectionView:collectionView indexPath:indexPath];
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark NSFetchedResultsControllerDelegate

//implementation from: https://github.com/iceesj/MR_PSUICollectionViewController/blob/master/testPST/ViewController.m

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    switch (self.changeType) {
        case PPFetchedResultsChangeTypeUpdate: {
            _PPCollectionViewControllerFlags.useChangeAnimations = YES;
            break;
        }
        case PPFetchedResultsChangeTypeIgnore:
        case PPFetchedResultsChangeTypeReload:
        default: {
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    if (!_PPCollectionViewControllerFlags.useChangeAnimations) {
        return;
    }
    
    NSMutableDictionary * changes = [NSMutableDictionary dictionary];
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            changes[@(NSFetchedResultsChangeInsert)] = @(sectionIndex);
            break;
        }
        case NSFetchedResultsChangeDelete: {
            changes[@(NSFetchedResultsChangeDelete)] = @(sectionIndex);
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            changes[@(NSFetchedResultsChangeUpdate)] = @(sectionIndex);
            break;
        }
        default: {
            break;
        }
    }
    
    [self.sectionChanges addObject:changes];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    if (!_PPCollectionViewControllerFlags.useChangeAnimations) {
        return;
    }
    
    indexPath = [self viewIndexPathForController:controller fetchedIndexPath:indexPath];
    newIndexPath = [self viewIndexPathForController:controller fetchedIndexPath:newIndexPath];
    NSMutableDictionary * changes = [NSMutableDictionary dictionary];
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            changes[@(NSFetchedResultsChangeInsert)] = newIndexPath;
            break;
        }
        case NSFetchedResultsChangeDelete: {
            changes[@(NSFetchedResultsChangeDelete)] = indexPath;
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            changes[@(NSFetchedResultsChangeUpdate)] = indexPath;
            break;
        }
        case NSFetchedResultsChangeMove: {
            changes[@(NSFetchedResultsChangeMove)] = @[indexPath, newIndexPath];
            break;
        }
        default: {
            break;
        }
    }
    
    [self.objectChanges addObject:changes];
}

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
        
        [self.sectionChanges removeAllObjects];
        [self.objectChanges removeAllObjects];
    }
    else if (PPFetchedResultsChangeTypeReload == self.changeType) {
        if (self.isViewVisible) {
            [self reloadData];
        }
        else {
            [self setNeedsReload];
        }
    }
    else {
        [self setNeedsReload];
    }
}

@end
