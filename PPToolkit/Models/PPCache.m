//
//  PPCache.m
//  PPCatalog
//
//  Created by Joachim Kret on 06.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPCache.h"

#import "NSString+PPToolkitAdditions.h"

static NSString * const PPCacheDispatchQueueName    = @"pl.PPToolkit.cache.dispatchQueue";
static NSString * const PPCacheIOQueueName          = @"pl.PPToolkit.cache.ioQueue";

static NSString * const PPDispatchQueueSpecificKey  = @"PPDispatchQueueSpecific";
static NSString * const PPIOQueueSpecificKey        = @"PPIOQueueSpecific";

static NSString * const PPCacheDefaultName          = @"PPDefaultName";

#pragma mark - PPCache

@interface PPCache ()

@property (nonatomic, readwrite, copy) NSString * name;
@property (nonatomic, readwrite, copy) NSString * cacheDirectoryPath;
@property (nonatomic, readwrite, strong) NSCache * cache;
@property (nonatomic, readwrite, strong) NSFileManager * fileManager;
@property (nonatomic, readwrite, assign) dispatch_queue_t dispatchQueue;
@property (nonatomic, readwrite, assign, setter = setIOQueue:) dispatch_queue_t ioQueue;

- (NSString *)_sanitizeFileNameString:(NSString *)fileName;

@end

#pragma mark -

@implementation PPCache

@synthesize name = _name;
@synthesize cacheDirectoryPath = _cacheDirectoryPath;
@synthesize cache = _cache;
@synthesize fileManager = _fileManager;
@synthesize dispatchQueue = _dispatchQueue;
@synthesize ioQueue = _ioQueue;
@synthesize callbackQueue = _callbackQueue;

+ (PPCacheType)defaultCacheType {
    return PPCacheTypeAll;
}

#pragma mark Init

- (id)init {
    return [self initWithName:PPCacheDefaultName];
}

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = (name && name.length) ? name : [NSString pp_stringWithUUID];
        
        self.cache = [NSCache new];
        self.cache.name = self.name;
        
        self.fileManager = [NSFileManager new];
        
        //dispatch queue
        dispatch_queue_t dispatchQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.%@", PPCacheDispatchQueueName, self.name] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
        self.dispatchQueue = dispatchQueue;
#if !OS_OBJECT_USE_OBJC
        dispatch_release(dispatchQueue);
#endif
        
        //io queue
        dispatch_queue_t ioQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.%@", PPCacheIOQueueName, self.name] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        self.ioQueue = ioQueue;
#if !OS_OBJECT_USE_OBJC
        dispatch_release(ioQueue);
#endif
        
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:self.name];
		self.cacheDirectoryPath = path;
        
        if (![self.fileManager fileExistsAtPath:path]) {
            NSError * error = nil;
            [self.fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }
    
    return self;
}

- (void)dealloc {
    [self.cache removeAllObjects];
    self.dispatchQueue = NULL;
    self.ioQueue = NULL;
}

#pragma mark Accessors

- (void)setDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (dispatchQueue != _dispatchQueue) {
        if (_dispatchQueue) {
            void * key = (__bridge void *)PPDispatchQueueSpecificKey;
            dispatch_queue_set_specific(_dispatchQueue, key, NULL, NULL);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_dispatchQueue);
#endif
        }
        
        _dispatchQueue = dispatchQueue;
        
        if (dispatchQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(dispatchQueue);
#endif
            void * key = (__bridge void *)self;
            void * nonNullValue = (__bridge void *)PPDispatchQueueSpecificKey;
            dispatch_queue_set_specific(dispatchQueue, key, nonNullValue, NULL);
        }
    }
}

- (BOOL)isInternalDispatchQueue {
    void * const key = (__bridge void *)PPDispatchQueueSpecificKey;
    return (NULL != dispatch_get_specific(key));
}

- (void)setIOQueue:(dispatch_queue_t)ioQueue {
    if (ioQueue != _ioQueue) {
        if (_ioQueue) {
            void * key = (__bridge void *)PPIOQueueSpecificKey;
            dispatch_queue_set_specific(_ioQueue, key, NULL, NULL);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_ioQueue);
#endif
        }
        
        _ioQueue = ioQueue;
        
        if (ioQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(ioQueue);
#endif
            void * key = (__bridge void *)PPIOQueueSpecificKey;
            void * nonNullValue = (__bridge void *)self;
            dispatch_queue_set_specific(ioQueue, key, nonNullValue, NULL);
        }
    }
}

- (BOOL)isInternalIOQueue {
    void * const key = (__bridge void *)PPIOQueueSpecificKey;
    return (NULL != dispatch_get_specific(key));
}

- (void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    if (callbackQueue != _callbackQueue) {
#if !OS_OBJECT_USE_OBJC
        if (_callbackQueue) {
            dispatch_release(_callbackQueue);
        }
#endif
        
        _callbackQueue = callbackQueue;
        
#if !OS_OBJECT_USE_OBJC
        if (callbackQueue) {
            dispatch_retain(callbackQueue);
        }
#endif
    }
}

#pragma mark Get Object

- (id)objectForKey:(NSString *)aKey {
    return [self objectForKey:aKey fromCacheType:[[self class] defaultCacheType]];
}

- (id)objectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType {
    __block id object = nil;
    
    if (PPCacheTypeMemory & cacheType) {
        object = [self.cache objectForKey:aKey];
        
        if (object) {
            return object;
        }
    }
    
    if (PPCacheTypeDisk & cacheType) {
        BOOL exists = [self objectExistsForKey:aKey inCacheType:PPCacheTypeDisk];
        
        if (exists) {
            dispatch_sync(self.ioQueue, ^{
                object = [self cachedObjectFromFile:[self pathForKey:aKey]];
            });
            
            if ((PPCacheTypeMemory & cacheType) && object) {
                [self.cache setObject:object forKey:aKey];
            }
        }
        
        return object;
    }
    
    return nil;
}

- (void)objectForKey:(NSString *)aKey completion:(void(^)(id object))completion {
    [self objectForKey:aKey fromCacheType:[[self class] defaultCacheType] completion:completion];
}

- (void)objectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType completion:(void(^)(id object))completion {
    NSParameterAssert(completion);
    
    if (!completion) {
        return;
    }
    
    dispatch_block_t block = ^{
        completion([self objectForKey:aKey fromCacheType:cacheType]);
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
}

#pragma mark Exists Object

- (BOOL)objectExistsForKey:(NSString *)aKey {
    return [self objectExistsForKey:aKey inCacheType:[[self class] defaultCacheType]];
}

- (BOOL)objectExistsForKey:(NSString *)aKey inCacheType:(PPCacheType)cacheType {
    NSAssert(aKey && aKey.length, @"Empty key is not allowed");
    
    if (!aKey || !aKey.length) {
        return NO;
    }
    
    if ((PPCacheTypeMemory & cacheType) && [self.cache objectForKey:aKey]) {
        return YES;
    }
    
    if (PPCacheTypeDisk & cacheType) {
        __block BOOL exists;
        dispatch_sync(self.ioQueue, ^{
            exists = [self.fileManager fileExistsAtPath:[self pathForKey:aKey]];
        });
        
        return exists;
    }
    
    return NO;
}

- (void)objectExistsForKey:(NSString *)aKey completion:(void(^)(BOOL exists))completion {
    [self objectExistsForKey:aKey inCacheType:[[self class] defaultCacheType] completion:completion];
}

- (void)objectExistsForKey:(NSString *)aKey inCacheType:(PPCacheType)cacheType completion:(void(^)(BOOL exists))completion {
    NSParameterAssert(completion);
    
    if (!completion) {
        return;
    }
    
    dispatch_block_t block = ^{
        completion([self objectExistsForKey:aKey inCacheType:cacheType]);
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
}

#pragma mark Set Object

- (void)setObject:(id)object forKey:(NSString *)aKey {
    [self setObject:object forKey:aKey withCacheType:[[self class] defaultCacheType]];
}

- (void)setObject:(id)object forKey:(NSString *)aKey withCacheType:(PPCacheType)cacheType {
    NSAssert(aKey && aKey.length, @"Empty key is not allowed");
    
    if (!aKey || !aKey.length) {
        return;
    }
    
    if (!object) {
        [self removeObjectForKey:aKey fromCacheType:cacheType];
    }
    else {
        if (PPCacheTypeMemory & cacheType) {
            [self.cache setObject:object forKey:aKey];
        }
        
        if (PPCacheTypeDisk & cacheType) {
            dispatch_sync(self.ioQueue, ^{
                [self cacheObject:object toFile:[self pathForKey:aKey]];
            });
        }
    }
}

- (void)setObject:(id)object forKey:(NSString *)aKey completion:(void(^)(void))completion {
    [self setObject:object forKey:aKey withCacheType:[[self class] defaultCacheType] completion:completion];
}

- (void)setObject:(id)object forKey:(NSString *)aKey withCacheType:(PPCacheType)cacheType completion:(void(^)(void))completion {
    dispatch_block_t block = ^{
        [self setObject:object forKey:aKey withCacheType:cacheType];

        if (completion) {
            completion();
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
    
}

#pragma mark Remove Object

- (void)removeObjectForKey:(NSString *)aKey {
    [self removeObjectForKey:aKey fromCacheType:[[self class] defaultCacheType]];
}

- (void)removeObjectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType {
    NSAssert(aKey && aKey.length, @"Empty key is not allowed");
    
    if (!aKey || !aKey.length) {
        return;
    }
    
    if (PPCacheTypeMemory & cacheType) {
        [self.cache removeObjectForKey:aKey];
    }
    
    if (PPCacheTypeDisk & cacheType) {
        dispatch_async(self.ioQueue, ^{
            [self.fileManager removeItemAtPath:[self pathForKey:aKey] error:nil];
        });
    }
}

- (void)removeObjectForKey:(NSString *)aKey completion:(void(^)(void))completion {
    [self removeObjectForKey:aKey fromCacheType:[[self class] defaultCacheType] completion:completion];
}

- (void)removeObjectForKey:(NSString *)aKey fromCacheType:(PPCacheType)cacheType completion:(void(^)(void))completion {
    
    dispatch_block_t block = ^{
        [self removeObjectForKey:aKey fromCacheType:cacheType];
        
        if (completion) {
            completion();
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
}

- (void)removeAllObjects {
    [self removeAllObjectsFromCacheType:[[self class] defaultCacheType]];
}

- (void)removeAllObjectsFromCacheType:(PPCacheType)cacheType {
    if (PPCacheTypeMemory & cacheType) {
        [self.cache removeAllObjects];
    }
    
    if (PPCacheTypeDisk & cacheType) {
        dispatch_async(self.ioQueue, ^{
            NSArray * contentOfCacheDirectory = [self.fileManager contentsOfDirectoryAtPath:self.cacheDirectoryPath error:nil];
            for (NSString * path in contentOfCacheDirectory) {
                [self.fileManager removeItemAtPath:[self.cacheDirectoryPath stringByAppendingPathComponent:path] error:nil];
            }
        });
    }
}

- (void)removeAllObjectsWithCompletion:(void(^)(void))completion {
    [self removeAllObjectsFromCacheType:[[self class] defaultCacheType] withCompletion:completion];
}

- (void)removeAllObjectsFromCacheType:(PPCacheType)cacheType withCompletion:(void(^)(void))completion {
    dispatch_block_t block = ^{
        [self removeAllObjectsFromCacheType:cacheType];
        
        if (completion) {
            completion();
        }
    };
    
    if (self.isInternalDispatchQueue) {
        block();
    }
    else {
        dispatch_async(self.dispatchQueue, block);
    }
}

#pragma mark Path

- (NSString *)pathForKey:(NSString *)aKey {
    NSAssert(aKey && aKey.length, @"Empty key is not allowed");
    aKey = [self _sanitizeFileNameString:aKey];
    return [self.cacheDirectoryPath stringByAppendingPathComponent:aKey];
}

#pragma mark Subclass Methods

- (id)cachedObjectFromFile:(NSString *)path {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (void)cacheObject:(id)object toFile:(NSString *)path {
        [NSKeyedArchiver archiveRootObject:object toFile:path];
}

#pragma mark Private Methods

- (NSString *)_sanitizeFileNameString:(NSString *)fileName {
    static NSCharacterSet * __illegalFileNameCharacters = nil;
    
	static dispatch_once_t illegalCharacterCreationToken;
	dispatch_once(&illegalCharacterCreationToken, ^{
		__illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString: @"/\\?%*|\"<>:/" ];
	});
    
    if (!__illegalFileNameCharacters) {
        return fileName;
    }
    
	return [[fileName componentsSeparatedByCharactersInSet:__illegalFileNameCharacters] componentsJoinedByString: @""];
}

@end
