//
//  PPRemoteManagedObject.m
//  PPToolkit
//
//  Created by Joachim Kret on 29.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPRemoteManagedObject.h"

@implementation PPRemoteManagedObject

#pragma mark Keys

+ (NSString *)defaultRemoteKey {
    return nil;
}

#pragma mark Object With Dictionary

+ (id)objectWithDictionary:(NSDictionary *)dictionary {
    return [self objectWithDictionary:dictionary context:[self defaultManagedObjectContext]];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
    return [self objectWithDictionary:dictionary context:context store:nil];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store {
    NSParameterAssert(context);
    NSAssert([self defaultRemoteKey], @"remote key is 'null'");
    
    if (!dictionary) {
        return nil;
    }
    
    id value = [dictionary objectForKey:[self defaultRemoteKey]];
    if (!value) {
        return nil;
    }
    
    if (!store) {
        store = [self defaultPersistentStore];
    }
    
    PPRemoteManagedObject * object = [self objectWithValue:value context:context store:store];
    
    if (object && [object shouldUnpackDictionary:dictionary]) {
        [object unpackDictionary:dictionary];
    }
    
    return object;
}

+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary {
    return [self existingObjectWithDictionary:dictionary context:[self defaultManagedObjectContext]];
}

+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
    return [self existingObjectWithDictionary:dictionary context:context store:nil];
}

+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store {
    NSParameterAssert(context);
    NSAssert([self defaultRemoteKey], @"remote key is 'null'");
    
    if (!dictionary) {
        return nil;
    }
    
    id value = [dictionary objectForKey:[self defaultRemoteKey]];
    if (!value) {
        return nil;
    }
    
    if (!context) {
        context = [self defaultManagedObjectContext];
    }
    
    if (!store) {
        store = [self defaultPersistentStore];
    }
    
    PPRemoteManagedObject * object = [self existingObjectWithValue:value context:context store:store];
    
    if (object && [object shouldUnpackDictionary:dictionary]) {
        [object unpackDictionary:dictionary];
    }
    
    return object;
}


#pragma mark Accessors

- (BOOL)isRemote {
    return (nil != [self primitiveValueForKey:[[self class] defaultLocalKey]]);
}

#pragma mark Unpack

- (void)unpackDictionary:(NSDictionary *)dictionary {
    if (dictionary && !self.isRemote) {
        NSValueTransformer * valueTransformer = [[self class] defaultValueTransformer];
        id value = [dictionary objectForKey:[[self class] defaultRemoteKey]];
        
        if (valueTransformer && ![value isKindOfClass:[[valueTransformer class] transformedValueClass]]) {
            value = [valueTransformer transformedValue:value];
        }
        
        [self setPrimitiveValue:value forKey:[[self class] defaultLocalKey]];
    }
}

- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
    return (!self.isDeleted && nil != self.managedObjectContext);
}

#pragma mark Serialization

- (NSDictionary *)serializedDictionary {
    return nil;
}

@end
