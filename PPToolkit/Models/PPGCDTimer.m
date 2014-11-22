//
//  PPGCDTimer.m
//  PPToolkit
//
//  Created by Joachim Kret on 16.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPGCDTimer.h"

static NSString * const PPPrivateDispatchQueueName  = @"com.PPToolkit.GCDTimer.privateQueue";

#pragma mark - PPGCDTimer

@interface PPGCDTimer () {
    dispatch_queue_t    _privateDispatchQueue;
    dispatch_source_t   _timer;
    BOOL                _suspended;
}

@property (nonatomic, readwrite, assign) dispatch_queue_t privateDispatchQueue;
@property (nonatomic, readonly, assign) dispatch_source_t timer;
@property (nonatomic, readwrite, assign, getter = isSuspended) BOOL suspended;
@property (nonatomic, readonly, assign) BOOL onPrivateDispatchQueue;

@property (nonatomic, readwrite, assign) NSTimeInterval timeInterval;
@property (nonatomic, readwrite, weak) id target;
@property (nonatomic, readwrite, assign) SEL selector;
@property (nonatomic, readwrite, strong) id userInfo;
@property (nonatomic, readwrite, assign) BOOL repeats;

- (void)_updateTimer;
- (void)_resumeTimer;
- (void)_suspendTimer;

@end

#pragma mark -

@implementation PPGCDTimer

@dynamic privateDispatchQueue;
@dynamic timer;
@dynamic suspended;
@dynamic onPrivateDispatchQueue;

@synthesize timeInterval = _timeInterval;
@synthesize target = _target;
@synthesize selector = _selector;
@synthesize userInfo = _userInfo;
@synthesize repeats = _repeats;

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue {

    return nil;
}

#pragma mark Init / Dealloc

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke %@ instead.",
                                           NSStringFromClass([self class]), NSStringFromSelector(@selector(initWithTimeInterval:target:selector:userInfo:repeats:dispatchQueue:))]
                                 userInfo:nil];
    return nil;
}

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue {
    NSParameterAssert(target);
    NSParameterAssert(selector);
    NSParameterAssert(dispatchQueue);
    
    if (self = [super init]) {
        self.timeInterval = (isgreater(timeInterval, 0.0f)) ? timeInterval : 0.1f;
        self.target = target;
        self.selector = selector;
        self.userInfo = userInfo;
        self.repeats = repeats;
        
        NSString * privateQueueName = [NSString stringWithFormat:@"%@.%p", PPPrivateDispatchQueueName, self];
        
        dispatch_queue_t privateDispatchQueue = dispatch_queue_create([privateQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(privateDispatchQueue, dispatchQueue);
        self.privateDispatchQueue = privateDispatchQueue;
#if !OS_OBJECT_USE_OBJC
        dispatch_release(privateDispatchQueue);
#endif
        
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, privateDispatchQueue);
        self.timer = timer;
#if !OS_OBJECT_USE_OBJC
        dispatch_release(timer);
#endif
        self.suspended = YES;
    }
    
    return self;
}

- (void)dealloc {
    dispatch_sync(self.privateDispatchQueue, ^{
        
    });
    
    self.privateDispatchQueue = NULL;
}

#pragma mark Accessors

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p timeInterval: %f, target: %@, selector: %@, userInfo: %@, repeats: %@, timer: %@>",
            NSStringFromClass([self class]),
            self,
            self.timeInterval,
            self.target,
            NSStringFromSelector(self.selector),
            self.userInfo,
            PPStringFromBool(self.repeats),
            self.timer];
}

- (void)setPrivateDispatchQueue:(dispatch_queue_t)privateDispatchQueue {
    if (privateDispatchQueue != _privateDispatchQueue) {
        if (_privateDispatchQueue) {
            void * key = (__bridge void *)self;
            dispatch_queue_set_specific(_privateDispatchQueue, key, NULL, NULL);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_privateDispatchQueue);
#endif
        }
        
        _privateDispatchQueue = privateDispatchQueue;
        
        if (privateDispatchQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(privateDispatchQueue);
#endif
            void * key = (__bridge void *)self;
            void * nonNullValue = (__bridge void *)self;
            dispatch_queue_set_specific(privateDispatchQueue, key, nonNullValue, NULL);
        }
    }
}

- (dispatch_queue_t)privateDispatchQueue {
    return _privateDispatchQueue;
}

- (void)setTimer:(dispatch_source_t)timer {
    if (timer != _timer) {
#if !OS_OBJECT_USE_OBJC
        if (_timer) {
            dispatch_release(_timer);
        }
#endif
        
        _timer = timer;
        
#if !OS_OBJECT_USE_OBJC
        if (timer) {
            dispatch_retain(timer);
        }
#endif
    }
}

- (dispatch_source_t)timer {
    return _timer;
}

- (BOOL)onPrivateDispatchQueue {
    void * const key = (__bridge void *)self;
    return (NULL != dispatch_get_specific(key));
}

#pragma mark PPTimerProtocol

- (void)fire {
    //TODO: implement
}

- (void)invalidate {
    //TODO: implement
}

- (BOOL)isValid {
    //TODO: implement
    return NO;
}

#pragma mark Private Methods

- (void)_updateTimer {
    //TODO: implement
}

- (void)_resumeTimer {
    if (self.isSuspended) {
        dispatch_resume(self.timer);
        self.suspended = NO;
    }
}

- (void)_suspendTimer {
    if (!self.isSuspended) {
        dispatch_suspend(self.timer);
        self.suspended = YES;
    }
}

@end
