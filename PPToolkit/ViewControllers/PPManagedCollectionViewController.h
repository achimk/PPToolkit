//
//  PPManagedCollectionViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 23.05.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedViewController.h"

#import "PSTCollectionView.h"

@interface PPManagedCollectionViewController : PPManagedViewController <PSUICollectionViewDelegate, PSUICollectionViewDataSource> {
@protected
    PSUICollectionViewLayout    * _layout;
    PSUICollectionView          * _collectionView;
    
    struct {
        unsigned int clearsSelectionOnViewWillAppear        : 1;
        unsigned int clearsSelectionOnReloadData            : 1;
        unsigned int reloadOnAppearsFirstTime               : 1;
        unsigned int useChangeAnimations                    : 1;
        unsigned int needsReload                            : 1;
    } _PPCollectionViewControllerFlags;
}

@property (nonatomic, readonly, strong) PSUICollectionViewLayout * layout;
@property (nonatomic, readwrite, strong) IBOutlet PSUICollectionView * collectionView;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;

+ (Class)defaultCollectionViewClass;
+ (Class)defaultCollectionViewLayoutClass;
+ (Class)defaultCollectionViewCellClass;
+ (NSString *)defaultCollectionViewCellNibName;

- (id)initWithCollectionViewLayout:(PSUICollectionViewLayout *)layout;

- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath;
- (NSIndexPath *)viewIndexPathForController:(NSFetchedResultsController *)controller fetchedIndexPath:(NSIndexPath *)fetchedIndexPath;
- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath;
- (NSIndexPath *)fetchedIndexPathForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)viewIndexPath;
- (id)objectForViewIndexPath:(NSIndexPath *)indexPath;
- (id)objectForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)indexPath;

- (void)setNeedsReload;
- (BOOL)needsReload;

- (void)reloadIfNeeded;
- (void)reloadIfVisible;
- (void)reloadData;

@end
