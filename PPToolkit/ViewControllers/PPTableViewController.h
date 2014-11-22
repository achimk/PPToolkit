//
//  PPTableViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPKeyboardViewController.h"

@interface PPTableViewController : PPKeyboardViewController <UITableViewDelegate, UITableViewDataSource> {
@protected
    UITableView     * _tableView;
    
    struct {
        unsigned int clearsSelectionOnViewWillAppear    : 1;
        unsigned int clearsSelectionOnReloadData        : 1;
        unsigned int reloadOnAppearsFirstTime           : 1;
        unsigned int needsReload                        : 1;
    } _PPTableViewControllerFlags;
}

@property (nonatomic, readwrite, strong) IBOutlet UITableView * tableView;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;
@property (nonatomic, readonly, assign, getter = isEmpty) BOOL empty;

+ (UITableViewStyle)defaultTableViewStyle;
+ (Class)defaultTableViewClass;
+ (Class)defaultTableViewCellClass;
+ (NSString *)defaultTableViewCellNibName;

- (id)initWithStyle:(UITableViewStyle)style;

- (void)setNeedsReload;
- (BOOL)needsReload;

- (void)reloadIfNeeded;
- (void)reloadIfVisible;
- (void)reloadData;

@end