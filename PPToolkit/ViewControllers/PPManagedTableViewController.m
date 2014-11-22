//
//  PPManagedTableViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 02.04.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedTableViewController.h"

#import "UIViewController+PPToolkitExtensions.h"
#import "PPTableView.h"
#import "PPTableViewCell.h"

#pragma mark - PPManagedTableViewController

@interface PPManagedTableViewController ()
@end

#pragma mark -

@implementation PPManagedTableViewController

@synthesize tableView = _tableView;
@dynamic clearsSelectionOnViewWillAppear;
@dynamic clearsSelectionOnReloadData;
@dynamic reloadOnAppearsFirstTime;

+ (UITableViewStyle)defaultTableViewStyle {
    return UITableViewStylePlain;
}

+ (Class)defaultTableViewClass {
    return [PPTableView class];
}

+ (Class)defaultTableViewCellClass {
    return nil;
}

+ (NSString *)defaultTableViewCellNibName {
    return nil;
}

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _PPViewControllerFlags.appearsFirstTime = YES;
        _PPTableViewControllerFlags.reloadOnAppearsFirstTime = YES;
        _PPTableViewControllerFlags.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.tableView = [[[[self class] defaultTableViewClass] alloc] initWithFrame:CGRectZero style:style];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _PPViewControllerFlags.appearsFirstTime = YES;
        _PPTableViewControllerFlags.reloadOnAppearsFirstTime = YES;
        _PPTableViewControllerFlags.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

#pragma mark View

- (void)loadView {
    [super loadView];

    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if (!_tableView) {
        self.tableView = [[[[self class] defaultTableViewClass] alloc] initWithFrame:self.view.bounds style:[[self class] defaultTableViewStyle]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[self class] defaultTableViewCellClass]) {
        [self.tableView registerClass:[[self class] defaultTableViewCellClass] forCellReuseIdentifier:NSStringFromClass([[self class] defaultTableViewCellClass])];
    }
    else if ([[self class] defaultTableViewCellNibName]) {
        [self.tableView registerNib:[UINib nibWithNibName:[[self class] defaultTableViewCellNibName] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[[self class] defaultTableViewCellNibName]];
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
        for (NSIndexPath * indexPath in [[self.tableView indexPathsForSelectedRows] copy]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        }
    }
}

- (void)releaseViews {
    [super releaseViews];
    self.tableView = nil;
}

#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark Accessors

- (void)setClearsSelectionOnViewWillAppear:(BOOL)clearsSelectionOnViewWillAppear {
    _PPTableViewControllerFlags.clearsSelectionOnViewWillAppear = clearsSelectionOnViewWillAppear;
}

- (BOOL)clearsSelectionOnViewWillAppear {
    return _PPTableViewControllerFlags.clearsSelectionOnViewWillAppear;
}

- (void)setClearsSelectionOnReloadData:(BOOL)clearsSelectionOnReloadData {
    _PPTableViewControllerFlags.clearsSelectionOnReloadData = clearsSelectionOnReloadData;
}

- (BOOL)clearsSelectionOnReloadData {
    return _PPTableViewControllerFlags.clearsSelectionOnReloadData;
}

- (void)setReloadOnAppearsFirstTime:(BOOL)reloadOnAppearsFirstTime {
    _PPTableViewControllerFlags.reloadOnAppearsFirstTime = reloadOnAppearsFirstTime;
}

- (BOOL)reloadOnAppearsFirstTime {
    return _PPTableViewControllerFlags.reloadOnAppearsFirstTime;
}

- (void)setNeedsReload {
    _PPTableViewControllerFlags.needsReload = YES;
}

- (BOOL)needsReload {
    return _PPTableViewControllerFlags.needsReload;
}

- (void)setTableView:(UITableView *)tableView {
    if (tableView != _tableView) {
        if (_tableView) {
            [_tableView removeFromSuperview];
            _tableView.delegate = nil;
            _tableView.dataSource = nil;
        }
        
        _tableView = tableView;
        
        if (tableView) {
            tableView.delegate = self;
            tableView.dataSource = self;
            
            if (!tableView.superview) {
                tableView.frame = self.view.bounds;
                tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.view addSubview:tableView];
            }
        }
    }
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
    _PPTableViewControllerFlags.needsReload = NO;
    
    if (self.clearsSelectionOnReloadData) {
        [self.tableView reloadData];
    }
    else {
        NSArray * selectedItems = [[self.tableView indexPathsForSelectedRows] copy];
        
        [self.tableView reloadData];
        
        for (NSIndexPath * indexPath in selectedItems) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark Keyboard

- (BOOL)shouldAcceptScrollView:(UIScrollView *)scrollView forKeyboardNotification:(NSNotification *)aNotification {
    return scrollView && self.tableView && (scrollView == self.tableView);
}

#pragma mark UITableView Additional Accessors

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

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    NSString * identifier = nil;
    
    if ([[self class] defaultTableViewCellClass]) {
        identifier = NSStringFromClass([[self class] defaultTableViewCellClass]);
    }
    else if ([[self class] defaultTableViewCellNibName]) {
        identifier = [[self class] defaultTableViewCellNibName];
    }
    
    if (identifier) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

        if ([cell conformsToProtocol:@protocol(PPTableViewCellProtocol)]) {
            NSManagedObject * managedObject = [self objectForController:self.fetchedResultsController viewIndexPath:indexPath];
            [(UITableViewCell <PPTableViewCellProtocol> *)cell configureForData:managedObject tableView:tableView indexPath:indexPath];
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    switch (self.changeType) {
        case PPFetchedResultsChangeTypeUpdate: {
            _PPTableViewControllerFlags.useChangeAnimations = YES;
            [self.tableView beginUpdates];
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
    
    if (!_PPTableViewControllerFlags.useChangeAnimations) {
        return;
    }
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (!_PPTableViewControllerFlags.useChangeAnimations) {
        return;
    }
    
    indexPath = [self viewIndexPathForFetchedIndexPath:indexPath];
    newIndexPath = [self viewIndexPathForFetchedIndexPath:newIndexPath];
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: (self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationNone : UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (PPFetchedResultsChangeTypeUpdate == self.changeType ||
        _PPTableViewControllerFlags.useChangeAnimations) {
        _PPTableViewControllerFlags.useChangeAnimations = NO;
        [self.tableView endUpdates];
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
