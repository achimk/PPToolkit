//
//  PPManagedViewController.m
//  PPToolkit
//
//  Created by Joachim Kret on 02.04.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedViewController.h"

#import "PPManagedObject.h"
#import "UIViewController+PPToolkitExtensions.h"

#pragma mark - PPManagedViewController

@interface PPManagedViewController ()

- (NSManagedObject *)_managedObjectWithContext:(NSManagedObjectContext *)context;
- (NSFetchedResultsController *)_fetchedResultsControllerWithContext:(NSManagedObjectContext *)context;
- (void)_managedObject:(NSManagedObject *)managedObject shouldObserveAttributes:(BOOL)observeAttributes andObserveRelationships:(BOOL)observeRelationships;

@end

#pragma mark -

@implementation PPManagedViewController

@synthesize managedObject = _managedObject;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize changeType = _changeType;
@dynamic observeAttributes;
@dynamic observeRelationships;
@dynamic empty;

+ (Class)defaultFetchedResultsControllerClass {
    return [NSFetchedResultsController class];
}

#pragma mark Init

- (id)initWithManagedObject:(NSManagedObject *)managedObject {
    return [self initWithNibName:nil bundle:nil managedObject:managedObject];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObject:(NSManagedObject *)manageObject {
    
    if (self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.managedObject = manageObject;
    }
    
    return self;
}

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    return [self initWithNibName:nil bundle:nil fetchedResultsController:fetchedResultsController];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {

    if (self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.fetchedResultsController = fetchedResultsController;
    }
    
    return self;
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchIfNeeded];
}

#pragma mark Accessors

- (void)setManagedObject:(NSManagedObject *)managedObject {
    if (managedObject != _managedObject) {
        if (_managedObject) {
            [self _managedObject:_managedObject shouldObserveAttributes:NO andObserveRelationships:NO];
        }
        
        _managedObject = managedObject;
        
        if (managedObject) {
            self.managedObjectContext = managedObject.managedObjectContext;
            [self _managedObject:managedObject shouldObserveAttributes:self.observeAttributes andObserveRelationships:self.observeRelationships];
        }
    }
}

- (NSManagedObject *)managedObject {
    return _managedObject;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (managedObjectContext != _managedObjectContext) {
        _managedObjectContext = managedObjectContext;
        
        if (self.managedObject) {
            self.managedObject = [self _managedObjectWithContext:managedObjectContext];
        }
        
        if (self.fetchedResultsController) {
            self.fetchedResultsController = [self _fetchedResultsControllerWithContext:managedObjectContext];
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext;
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != _fetchedResultsController) {
        if (_fetchedResultsController) {
            _fetchedResultsController.delegate = nil;
        }

        _fetchedResultsController = fetchedResultsController;
        
        if (fetchedResultsController) {
            self.managedObjectContext = fetchedResultsController.managedObjectContext;
            fetchedResultsController.delegate = self;
            [self fetchIfVisible];
        }
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        self.fetchedResultsController = [self _fetchedResultsControllerWithContext:self.managedObjectContext];
    }
    
    return _fetchedResultsController;
}

- (void)setObserveAttributes:(BOOL)observeAttributes {
    if (observeAttributes != _PPManagedViewControllerFlags.observeAttributes) {
        _PPManagedViewControllerFlags.observeAttributes = observeAttributes;
        
        if (self.managedObject) {
            [self _managedObject:self.managedObject shouldObserveAttributes:observeAttributes andObserveRelationships:self.observeRelationships];
        }
    }
}

- (BOOL)observeAttributes {
    return _PPManagedViewControllerFlags.observeAttributes;
}

- (void)setObserveRelationships:(BOOL)observeRelationships {
    if (observeRelationships != _PPManagedViewControllerFlags.observeRelationships) {
        _PPManagedViewControllerFlags.observeRelationships = observeRelationships;
        
        if (self.managedObject) {
            [self _managedObject:self.managedObject shouldObserveAttributes:self.observeAttributes andObserveRelationships:observeRelationships];
        }
    }
}

- (BOOL)observeRelationships {
    return _PPManagedViewControllerFlags.observeRelationships;
}

- (BOOL)isEmpty {
    [self fetchIfNeeded];
    return (0 == [self.fetchedResultsController.fetchedObjects count]);
}

- (void)setNeedsFetch {
    _PPManagedViewControllerFlags.needsFetch = YES;
}

- (BOOL)needsFetch {
    return _PPManagedViewControllerFlags.needsFetch;
}

#pragma mark Public Methods

- (void)fetchIfNeeded {
    if ([self needsFetch]) {
        [self performFetch];
    }
}

- (void)fetchIfVisible {
    if (self.isViewVisible) {
        [self performFetch];
    }
    else {
        [self setNeedsFetch];
    }
}

- (void)performFetch {
    _PPManagedViewControllerFlags.needsFetch = NO;
    
    if (self.fetchedResultsController) {
        self.fetchedResultsController.fetchRequest.predicate = self.predicate;
        self.fetchedResultsController.fetchRequest.sortDescriptors = self.sortDescriptors;
        //[self.fetchedResultsController performSelectorOnMainThread:@selector(performFetch:) withObject:nil waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
        NSError * error = nil;
        
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark NSFetchedResultsController Configuration

- (Class)entityClass {
    return nil;
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest * fetchRequest = nil;
    NSManagedObjectContext * context = [self managedObjectContext];
    Class entityClass = [self entityClass];
    
    if (entityClass && context) {
        NSString * entityName = ([entityClass isSubclassOfClass:[PPManagedObject class]]) ? [entityClass entityName] : NSStringFromClass(entityClass);
        fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        fetchRequest.sortDescriptors = [self sortDescriptors];
        fetchRequest.predicate = [self predicate];
        fetchRequest.fetchBatchSize = kPPToolkitFetchBatchSize;
        fetchRequest.returnsObjectsAsFaults = NO;
    }
    
    return fetchRequest;
}

- (NSArray *)sortDescriptors {
    return [NSArray array];
}

- (NSPredicate *)predicate {
    return nil;
}

- (NSString *)sectionNameKeyPath {
    return nil;
}

- (NSString *)cacheName {
    return nil;
}

#pragma mark Private Methods

- (NSManagedObject *)_managedObjectWithContext:(NSManagedObjectContext *)context {
    NSManagedObject * managedObject = nil;

    if (context) {
        if (_managedObject && context != _managedObject.managedObjectContext) {
            managedObject = [context existingObjectWithID:_managedObject.objectID error:nil];
        }
        else if (_managedObject) {
            managedObject = _managedObject;
        }
    }
    
    return managedObject;
}

- (NSFetchedResultsController *)_fetchedResultsControllerWithContext:(NSManagedObjectContext *)context {
    NSFetchedResultsController * fetchedResultsController = nil;
    
    if (context) {
        if ([self entityClass] && !_fetchedResultsController) {
            NSAssert([[self class] defaultFetchedResultsControllerClass], @"Default NSFetchedResultsController class is undefined");
            NSAssert1([[[self class] defaultFetchedResultsControllerClass] isSubclassOfClass:[NSFetchedResultsController class]], @"'%@' is not subclass of the NSFetchedResultsController class", NSStringFromClass([[self class] defaultFetchedResultsControllerClass]));
            fetchedResultsController = [[[[self class] defaultFetchedResultsControllerClass] alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:context sectionNameKeyPath:self.sectionNameKeyPath cacheName:self.cacheName];
        }
        else if (_fetchedResultsController && context != _fetchedResultsController.managedObjectContext) {
            NSString * className = NSStringFromClass([_fetchedResultsController class]);
            Class classObject = NSClassFromString(className);
            fetchedResultsController = [[classObject alloc] initWithFetchRequest:_fetchedResultsController.fetchRequest managedObjectContext:context sectionNameKeyPath:_fetchedResultsController.sectionNameKeyPath cacheName:_fetchedResultsController.cacheName];
        }
        else if (_fetchedResultsController) {
            fetchedResultsController = _fetchedResultsController;
        }
    }

    return fetchedResultsController;
}

- (void)_managedObject:(NSManagedObject *)managedObject shouldObserveAttributes:(BOOL)observeAttributes andObserveRelationships:(BOOL)observeRelationships {
    if (!managedObject || managedObject != self.managedObject) {
        NSAssert(managedObject, @"Can't observe empty managed object");
        NSAssert(managedObject == self.managedObject, @"Can't observe other objects than managed object property");
        return;
    }
    
    if (observeAttributes == _PPManagedViewControllerFlags.hasObserveAttributes &&
        observeRelationships == _PPManagedViewControllerFlags.hasObserveRelationships) {
        //nothing to change
        return;
    }
    
    NSArray * properties = [[self.managedObject entity] properties];
    
    for (NSPropertyDescription * property in properties) {
        if ([property isKindOfClass:[NSAttributeDescription class]]) {
            if (observeAttributes && !_PPManagedViewControllerFlags.hasObserveAttributes) {
                [self addObserver:self forKeyPath:property.name options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
            }
            else if (!observeAttributes && _PPManagedViewControllerFlags.hasObserveAttributes) {
                [self removeObserver:self forKeyPath:property.name context:(__bridge void *)self];
            }
        }
        
        if ([property isKindOfClass:[NSRelationshipDescription class]]) {
            if (observeRelationships && !_PPManagedViewControllerFlags.hasObserveRelationships) {
                [self addObserver:self forKeyPath:property.name options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
            }
            else if (!observeRelationships && _PPManagedViewControllerFlags.hasObserveRelationships) {
                [self removeObserver:self forKeyPath:property.name context:(__bridge void *)self];
            }
        }
    }
    
    _PPManagedViewControllerFlags.hasObserveAttributes = observeAttributes;
    _PPManagedViewControllerFlags.hasObserveRelationships = observeRelationships;
}

@end
