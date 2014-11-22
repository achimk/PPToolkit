//
//  PPRemoteManagedObject.h
//  PPToolkit
//
//  Created by Joachim Kret on 29.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPManagedObject.h"

@interface PPRemoteManagedObject : PPManagedObject

+ (NSString *)defaultRemoteKey;

+ (id)objectWithDictionary:(NSDictionary *)dictionary;
+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;
+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store;

+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary;
+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;
+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context store:(NSPersistentStore *)store;

- (BOOL)isRemote;

- (void)unpackDictionary:(NSDictionary *)dictionary;
- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)serializedDictionary;

@end
