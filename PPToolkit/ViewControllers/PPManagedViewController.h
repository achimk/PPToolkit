//
//  PPManagedViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 02.04.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPKeyboardViewController.h"

#import <CoreData/CoreData.h>

typedef enum {
    PPFetchedResultsChangeTypeIgnore    = 0,
    PPFetchedResultsChangeTypeReload,
    PPFetchedResultsChangeTypeUpdate
} PPFetchedResultsChangeType;

@interface PPManagedViewController : PPKeyboardViewController <NSFetchedResultsControllerDelegate> {
@protected
    struct {
        unsigned int observeAttributes          : 1;
        unsigned int observeRelationships       : 1;
        unsigned int hasObserveAttributes       : 1;
        unsigned int hasObserveRelationships    : 1;
        unsigned int needsFetch                 : 1;
    } _PPManagedViewControllerFlags;
    
    NSManagedObject                 * _managedObject;
    NSManagedObjectContext          * _managedObjectContext;
    NSFetchedResultsController      * _fetchedResultsController;
}

@property (nonatomic, readwrite, strong) NSManagedObject * managedObject;
@property (nonatomic, readwrite, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, readwrite, strong) NSFetchedResultsController * fetchedResultsController;

@property (nonatomic, readwrite, assign) PPFetchedResultsChangeType changeType;
@property (nonatomic, readwrite, assign) BOOL observeAttributes;    //only for managed object property
@property (nonatomic, readwrite, assign) BOOL observeRelationships; //only for managed object property
@property (nonatomic, readonly, assign, getter = isEmpty) BOOL empty;

+ (Class)defaultFetchedResultsControllerClass;

- (id)initWithManagedObject:(NSManagedObject *)managedObject;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObject:(NSManagedObject *)manageObject;
- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

- (void)setNeedsFetch;
- (BOOL)needsFetch;

- (void)fetchIfNeeded;
- (void)fetchIfVisible;
- (void)performFetch;

- (Class)entityClass;
- (NSFetchRequest *)fetchRequest;
- (NSArray *)sortDescriptors;
- (NSPredicate *)predicate;
- (NSString *)sectionNameKeyPath;
- (NSString *)cacheName;

@end
