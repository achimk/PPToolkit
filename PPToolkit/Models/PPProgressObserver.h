//
//  PPProgressObserver.h
//  PPCatalog
//
//  Created by Joachim Kret on 26.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPProgressObserver;

typedef void (^PPProgressObserverProgressBlock)(float progress);
typedef void (^PPProgressObserverCompletionBlock)(void);

#pragma mark - PPProgressObserverDelegate

@protocol PPProgressObserverDelegate <NSObject>

@optional
- (void)progressObserver:(PPProgressObserver *)progressObserver didProgress:(float)progress;
- (void)progressObserverDidComplete:(PPProgressObserver *)progressObserver;

@end

#pragma mark - PPProgressObserver

@interface PPProgressObserver : NSObject

@property (nonatomic, readwrite, copy) NSString * identifier;
@property (nonatomic, readwrite, assign) NSUInteger startingOperationCount;
@property (nonatomic, readwrite, copy) PPProgressObserverProgressBlock progressBlock;
@property (nonatomic, readwrite, copy) PPProgressObserverCompletionBlock completionBlock;
@property (nonatomic, readwrite, weak) id <PPProgressObserverDelegate> delegate;

+ (PPProgressObserver *)progressObserverWithStartingOperationCount:(NSUInteger)operationCount progressBlock:(PPProgressObserverProgressBlock)progressBlock completionBlock:(PPProgressObserverCompletionBlock)completionBlock;

- (id)init;
- (id)initWithStartingOperationCount:(NSUInteger)operationCount progressBlock:(PPProgressObserverProgressBlock)progressBlock completionBlock:(PPProgressObserverCompletionBlock)completionBlock;

- (void)runProgressBlockWithCurrentOperationCount:(NSUInteger)operationCount;
- (void)runCompletionBlock;
- (void)addToStartingOperationCount:(NSUInteger)numberToAdd;

@end
