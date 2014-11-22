//
//  PPCollectionViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 23.05.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPCollectionViewController.h"

#import "UIViewController+PPToolkitExtensions.h"

#pragma mark - PPCollectionViewController

@interface PPCollectionViewController ()
@property (nonatomic, readwrite, strong) PSUICollectionViewLayout * layout;
@end

#pragma mark -

@implementation PPCollectionViewController

@synthesize layout = _layout;
@synthesize collectionView = _collectionView;
@dynamic clearsSelectionOnViewWillAppear;
@dynamic clearsSelectionOnReloadData;
@dynamic reloadOnAppearsFirstTime;
@dynamic empty;

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
        self.layout = [[[self class] defaultCollectionViewLayoutClass] new];
        _PPCollectionViewControllerFlags.clearsSelectionOnViewWillAppear = YES;
        _PPCollectionViewControllerFlags.reloadOnAppearsFirstTime = YES;
        _PPViewControllerFlags.appearsFirstTime = YES;
    }
    return self;
}

- (id)initWithCollectionViewLayout:(PSUICollectionViewLayout *)layout {
    if (self = [self initWithNibName:nil bundle:nil]) {
        if (layout) {
            self.layout = layout;
        }
        
        self.collectionView = [(PSUICollectionView *)[[[self class] defaultCollectionViewClass] alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.layout = [[[self class] defaultCollectionViewLayoutClass] new];
        _PPCollectionViewControllerFlags.clearsSelectionOnViewWillAppear = YES;
        _PPCollectionViewControllerFlags.reloadOnAppearsFirstTime = YES;
        _PPViewControllerFlags.appearsFirstTime = YES;
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

- (BOOL)isEmpty {
    if (self.collectionView) {
        NSInteger sections = [self.collectionView numberOfSections];
        
        for (NSInteger section = 0; section < sections; section++) {
            NSInteger rows = [self.collectionView numberOfItemsInSection:section];
            
            if (rows) {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark Keyboard

- (BOOL)shouldAcceptScrollView:(UIScrollView *)scrollView forKeyboardNotification:(NSNotification *)aNotification {
    return NO; //default NO accept keyboard for CollectionView
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
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView {
    return 0;
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

@end
