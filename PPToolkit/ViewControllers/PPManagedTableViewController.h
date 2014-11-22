//
//  PPManagedTableViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 02.04.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedViewController.h"

@interface PPManagedTableViewController : PPManagedViewController <UITableViewDelegate, UITableViewDataSource> {
@protected
    UITableView     * _tableView;
    
    struct {
        unsigned int clearsSelectionOnViewWillAppear        : 1;
        unsigned int clearsSelectionOnReloadData            : 1;
        unsigned int reloadOnAppearsFirstTime               : 1;
        unsigned int useChangeAnimations                    : 1;
        unsigned int needsReload                            : 1;
    } _PPTableViewControllerFlags;
}

@property (nonatomic, readwrite, strong) IBOutlet UITableView * tableView;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;

+ (UITableViewStyle)defaultTableViewStyle;
+ (Class)defaultTableViewClass;
+ (Class)defaultTableViewCellClass;
+ (NSString *)defaultTableViewCellNibName;

- (id)initWithStyle:(UITableViewStyle)style;

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
