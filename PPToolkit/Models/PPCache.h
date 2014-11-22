//
//  PPCache.h
//  PPCatalog
//
//  Created by Joachim Kret on 06.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PPCacheTypeMemory   = 1 << 0,
    PPCacheTypeDisk     = 1 << 1,
    PPCacheTypeAll      = PPCacheTypeMemory | PPCacheTypeDisk
} PPCacheType;

#pragma mark - PPCache

@interface PPCache : NSObject {
@protected
    NSString        * _name;
    NSString        * _cacheDirectoryPath;
    NSCache         * _cache;
    NSFileManager   * _fileManager;
}

@property (nonatomic, readonly, copy) NSString * name;
@property (nonatomic, readonly, copy) NSString * cacheDirectoryPath;
@property (nonatomic, readonly, strong) NSCache * cache;
@property (nonatomic, readonly, strong) NSFileManager * fileManager;
@property (nonatomic, readwrite, assign) dispatch_queue_t callbackQueue;

+ (PPCacheType)defaultCacheType;

//init
- (id)init;
- (id)initWithName:(NSString *)name;

//get object
- (id)objectForKey:(NSString *)aKey;
- (id)objectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType;
- (void)objectForKey:(NSString *)aKey completion:(void(^)(id object))completion;
- (void)objectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType completion:(void(^)(id object))completion;

//exists object
- (BOOL)objectExistsForKey:(NSString *)aKey;
- (BOOL)objectExistsForKey:(NSString *)aKey inCacheType:(PPCacheType)cacheType;
- (void)objectExistsForKey:(NSString *)aKey completion:(void(^)(BOOL exists))completion;
- (void)objectExistsForKey:(NSString *)aKey inCacheType:(PPCacheType)cacheType completion:(void(^)(BOOL exists))completion;

//set object
- (void)setObject:(id)object forKey:(NSString *)aKey;
- (void)setObject:(id)object forKey:(NSString *)aKey withCacheType:(PPCacheType)cacheType;
- (void)setObject:(id)object forKey:(NSString *)aKey completion:(void(^)(void))completion;
- (void)setObject:(id)object forKey:(NSString *)aKey withCacheType:(PPCacheType)cacheType completion:(void(^)(void))completion;

//remove object
- (void)removeObjectForKey:(NSString *)aKey;
- (void)removeObjectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType;
- (void)removeObjectForKey:(NSString *)aKey completion:(void(^)(void))completion;
- (void)removeObjectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType completion:(void(^)(void))completion;

//remove all
- (void)removeAllObjects;
- (void)removeAllObjectsFromCacheType:(PPCacheType)cacheType;
- (void)removeAllObjectsWithCompletion:(void(^)(void))completion;
- (void)removeAllObjectsFromCacheType:(PPCacheType)cacheType withCompletion:(void(^)(void))completion;

//path
- (NSString *)pathForKey:(NSString *)aKey;

@end

#pragma mark - PPCache (SubclassOnly)

@interface PPCache (SubclassOnly)

@property (nonatomic, readonly, assign) dispatch_queue_t dispatchQueue;
@property (nonatomic, readonly, assign) dispatch_queue_t ioQueue;

- (BOOL)isInternalDispatchQueue;
- (BOOL)isInternalIOQueue;

- (id)cachedObjectFromFile:(NSString *)path;
- (void)cacheObject:(id)object toFile:(NSString *)path;

@end