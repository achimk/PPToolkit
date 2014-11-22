//
//  PPTableViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPTableViewController.h"

#import "PPTableView.h"
#import "PPTableViewCell.h"
#import "UIViewController+PPToolkitExtensions.h"

#pragma mark - PPTableViewController

@interface PPTableViewController ()
@end

#pragma mark -

@implementation PPTableViewController

@synthesize tableView = _tableView;
@dynamic clearsSelectionOnViewWillAppear;
@dynamic clearsSectionOnReloadData;
@dynamic reloadOnAppearsFirstTime;
@dynamic empty;

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
        self.reloadOnAppearsFirstTime = NO;
        [self reloadData];
    }
    else {
        [self reloadIfNeeded];
    }
    
    if (_PPTableViewControllerFlags.clearsSelectionOnViewWillAppear) {
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

- (void)setClearsSectionOnReloadData:(BOOL)clearsSectionOnReloadData {
    _PPTableViewControllerFlags.clearsSelectionOnReloadData = clearsSectionOnReloadData;
}

- (BOOL)clearsSectionOnReloadData {
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

- (BOOL)isEmpty {
    if (self.tableView) {
        NSInteger sections = [self.tableView numberOfSections];
        
        for (NSInteger section = 0; section < sections; section++) {
            NSInteger rows = [self.tableView numberOfRowsInSection:section];
            
            if (rows) {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark Keyboard

- (BOOL)shouldAcceptScrollView:(UIScrollView *)scrollView forKeyboardNotification:(NSNotification *)aNotification {
    return scrollView && self.tableView && (scrollView == self.tableView);
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
    
    if (self.clearsSectionOnReloadData) {
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
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

@end
