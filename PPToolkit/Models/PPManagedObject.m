//
//  PPManagedObject.m
//  PPToolkit
//
//  Created by Joachim Kret on 29.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedObject.h"

@implementation PPManagedObject

#pragma mark Keys

+ (NSString *)defaultLocalKey {
    return nil;
}

#pragma mark Entity

+ (NSString *)entityName {
    return NSStringFromClass([self class]);
}

#pragma mark Entity Sort Descriptors

+ (NSArray *)sortDescriptors {
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[self defaultLocalKey] ascending:YES]];
}

#pragma mark Value Transformer

+ (NSValueTransformer *)defaultValueTransformer {
    return nil;
}

#pragma mark Core Data

+ (NSManagedObjectContext *)defaultManagedObjectContext {
    return nil;
}

+ (NSPersistentStore *)defaultPersistentStore {
    return nil;
}

#pragma mark Entity Description

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

#pragma mark NSFetchRequest With Value

+ (NSFetchRequest *)fetchRequestWithValue:(id)value {
    return [self fetchRequestWithValue:value context:nil];
}

+ (NSFetchRequest *)fetchRequestWithValue:(id)value context:(NSManagedObjectContext *)context {
    return [self fetchRequestWithValue:value context:context store:nil];
}

+ (NSFetchRequest *)fetchRequestWithValue:(id)value context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store {
    if (!context) {
        context = [self defaultManagedObjectContext];
        NSAssert(context, @"Can't create fetch request for empty managed object context");
    }
    
    if (!store) {
        store = [self defaultPersistentStore];
    }
    
    NSValueTransformer * valueTransformer = [self defaultValueTransformer];
    
    if (valueTransformer && ![value isKindOfClass:[[valueTransformer class] transformedValueClass]]) {
        value = [valueTransformer transformedValue:value];
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = %@", [self defaultLocalKey], value];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [self entityInManagedObjectContext:context];
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = 1;
    
    if (store) {
        fetchRequest.affectedStores = [NSArray arrayWithObject:store];
    }

    return fetchRequest;
}

#pragma mark Object With Value

+ (id)objectWithValue:(id)value {
    return [self objectWithValue:value context:nil];
}

+ (id)objectWithValue:(id)value context:(NSManagedObjectContext *)context {
    return [self objectWithValue:value context:context store:nil];
}

+ (id)objectWithValue:(id)value context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store {
    NSAssert(value, @"value is 'null'");
    NSAssert([self defaultLocalKey], @"search key is 'null'");
    
    if (!context) {
        context = [self defaultManagedObjectContext];
        NSAssert(context, @"Can't create fetch request for empty managed object context");
    }
    
    if (!store) {
        store = [self defaultPersistentStore];
    }
    
    PPManagedObject * object = [self existingObjectWithValue:value context:context store:store];
    
    if (!object) {
        object = [self insertInManagedObjectContext:context];
        
        NSValueTransformer * valueTransformer = [self defaultValueTransformer];
        
        if (valueTransformer && ![value isKindOfClass:[[valueTransformer class] transformedValueClass]]) {
            value = [valueTransformer transformedValue:value];
        }
        
        [object setPrimitiveValue:value forKey:[self defaultLocalKey]];
        
        if (store) {
            [context assignObject:object toPersistentStore:store];
        }
    }
    
    return object;
}

+ (id)existingObjectWithValue:(id)value {
    return [self existingObjectWithValue:value context:nil];
}

+ (id)existingObjectWithValue:(id)value context:(NSManagedObjectContext *)context {
    return [self existingObjectWithValue:value context:context store:nil];
}

+ (id)existingObjectWithValue:(id)value context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store {
    NSAssert(value, @"value is 'null'");
    NSAssert([self defaultLocalKey], @"search key is 'null'");
    
    if (!context) {
        context = [self defaultManagedObjectContext];
        NSAssert(context, @"Can't create fetch request for empty managed object context");
    }
    
    if (!store) {
        store = [self defaultPersistentStore];
    }

    NSFetchRequest * fetchRequest = [self fetchRequestWithValue:value context:context store:store];
    
    if (!fetchRequest) {
        return nil;
    }
    
    __block NSArray * results = nil;
    
    NSError * error = nil;
    results = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Execute fetch request error: %@", error);
    }
    
    return (results && results.count) ? [results lastObject] : nil;
}

@end
