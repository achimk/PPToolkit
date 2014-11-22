//
//  PPCoreDataStore.h
//  PPToolkit
//
//  Created by Joachim Kret on 21.11.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <CoreData/CoreData.h>

#pragma mark - PPCoreDataStore

@interface PPCoreDataStore : NSObject {
@protected
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    NSManagedObjectModel * _managedObjectModel;
    NSManagedObjectContext * _privateContext;
    NSManagedObjectContext * _mainContext;
}

@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext * privateContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;
@property (nonatomic, readwrite, strong) id defaultMergePolicy;

+ (NSString *)defaultModelName;
+ (NSString *)defaultStoreName;
+ (NSDictionary *)defaultStoreOptions;
+ (Class)defaultManagedObjectContextClass;

- (id)init;
- (id)initWithModelName:(NSString *)modelName;
- (id)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

- (NSPersistentStore *)addInMemoryPersistentStore:(NSError **)error;
- (NSPersistentStore *)addSQLitePersistentStore:(NSError **)error;
- (NSPersistentStore *)addSQLitePersistentStoreWithName:(NSString *)name error:(NSError **)error;
- (NSPersistentStore *)addSQLitePersistentStoreWithName:(NSString *)name options:(NSDictionary *)options error:(NSError **)error;

- (NSManagedObjectContext *)contextForCurrentThread;
- (NSManagedObjectContext *)childContextForPrivateContext;
- (NSManagedObjectContext *)childContextForMainContext;
- (NSManagedObjectContext *)childContextForParentContext:(NSManagedObjectContext *)parentContext;
- (NSManagedObjectContext *)childContextForParentContext:(NSManagedObjectContext *)parentContext withConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;
- (void)setDefaultMergePolicy:(id)mergePolicy applyToMainThreadContextAndParent:(BOOL)apply;

- (NSURL *)urlForStoreName:(NSString *)storeName;

@end

#pragma mark - PPCoreDataStore (SubclassOnly)

@interface PPCoreDataStore (SubclassOnly)

- (void)setup;

@end
