//
//  PPManagedObject.h
//  PPToolkit
//
//  Created by Joachim Kret on 29.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PPManagedObject : NSManagedObject

+ (NSString *)defaultLocalKey;
+ (NSString *)entityName;

+ (NSArray *)sortDescriptors;
+ (NSValueTransformer *)defaultValueTransformer;

+ (NSManagedObjectContext *)defaultManagedObjectContext;
+ (NSPersistentStore *)defaultPersistentStore;

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)fetchRequestWithValue:(id)value;
+ (NSFetchRequest *)fetchRequestWithValue:(id)value context:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)fetchRequestWithValue:(id)value context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store;

+ (id)objectWithValue:(id)value;
+ (id)objectWithValue:(id)value context:(NSManagedObjectContext *)context;
+ (id)objectWithValue:(id)value context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store;

+ (id)existingObjectWithValue:(id)value;
+ (id)existingObjectWithValue:(id)value context:(NSManagedObjectContext *)context;
+ (id)existingObjectWithValue:(id)value context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store;

@end
