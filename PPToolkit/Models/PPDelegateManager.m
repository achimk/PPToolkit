//
//  PPDelegateManager.m
//  PPToolkit
//
//  Created by Joachim Kret on 17.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPDelegateManager.h"

#import <objc/runtime.h>

@interface PPDelegateManager ()
@property (nonatomic, readwrite, strong) Protocol * protocol;
@property (nonatomic, readwrite, strong) NSMutableSet * delegates;
@end

#pragma mark -

@implementation PPDelegateManager

@synthesize protocol = _protocol;
@synthesize delegates = _delegates;

#pragma mark Init

- (id)initWithProtocol:(Protocol *)protocol delegates:(NSSet *)delegates {
    NSParameterAssert(protocol);
    
    if (self = [super init]) {
        _protocol = protocol;
        _delegates = [[NSMutableSet alloc] init];
        
        if (delegates && [delegates count]) {
            [_delegates addObjectsFromArray:delegates.allObjects];
        }
    }
    return self;
}

- (void)dealloc {
    [self.delegates removeAllObjects];
}

#pragma mark Public Methods

- (void)registerDelegate:(id)delegate {
    NSParameterAssert(delegate);
    NSAssert1([delegate conformsToProtocol:self.protocol], @"Observer must conforms to protocol: %@", NSStringFromProtocol(self.protocol));
    
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)unregisterDelegate:(id)delegate {
    NSParameterAssert(delegate);
    
    [self.delegates removeObject:delegate];
}

#pragma mark Invoke Observers

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature * result = [super methodSignatureForSelector:aSelector];
    
    if (result) {
        return result;
    }
    
    //looking for a required method
    struct objc_method_description desc = protocol_getMethodDescription(self.protocol, aSelector, YES, YES);
    
    //looking for a optional method
    if (NULL == desc.name) {
        desc = protocol_getMethodDescription(self.protocol, aSelector, NO, YES);
    }
    
    if (NULL == desc.name) {
        //Couldn't find method, raise exception: NSInvalidArgumentException
        [self doesNotRecognizeSelector:aSelector];
        return nil;
    }
    
    return [NSMethodSignature signatureWithObjCTypes:desc.types];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL aSelector = [anInvocation selector];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            [anInvocation setTarget:delegate];
            [anInvocation invoke];
        }
    }
}

@end
