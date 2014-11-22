//
//  PPDelegateInterceptor.m
//  PPToolkit
//
//  Created by Joachim Kret on 12.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPDelegateInterceptor.h"

#import <objc/runtime.h>

@implementation PPDelegateInterceptor

@synthesize sourceProtocol = _sourceProtocol;
@synthesize sourceDelegate = _sourceDelegate;
@synthesize destinationProtocol = _destinationProtocol;
@synthesize destinationDelegate = _destinationDelegate;

#pragma mark Init

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke %@ instead.",
                                           NSStringFromClass([self class]),
                                           NSStringFromSelector(@selector(initWithSourceProtocol:sourceDelegate:destinationProtocol:destinationDelegate:))]
                                 userInfo:nil];
    return nil;
}

- (id)initWithSourceProtocol:(Protocol *)sourceProtocol sourceDelegate:(id)sourceDelegate destinationProtocol:(Protocol *)destinationProtocol destinationDelegate:(id)destinationDelegate {
    NSParameterAssert(sourceProtocol);
    NSParameterAssert(sourceDelegate);
    NSParameterAssert(destinationProtocol);
    NSParameterAssert(destinationDelegate);
    
    if (self = [super init]) {
        _sourceProtocol = sourceProtocol;
        _sourceDelegate = sourceDelegate;
        _destinationProtocol = destinationProtocol;
        _destinationDelegate = destinationDelegate;
    }
    
    return self;
}

#pragma mark NSObject

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.sourceDelegate respondsToSelector:aSelector]) {
        //looking for a required method
        struct objc_method_description desc = protocol_getMethodDescription(self.sourceProtocol, aSelector, YES, YES);
        
        //looking for a optional method
        if (NULL == desc.name) {
            desc = protocol_getMethodDescription(self.sourceProtocol, aSelector, NO, YES);
        }
        
        if (NULL == desc.name) {
            //Couldn't find method, raise exception: NSInvalidArgumentException
            [self doesNotRecognizeSelector:aSelector];
            return nil;
        }
        
        return self.sourceDelegate;
    }
    else if ([self.destinationDelegate respondsToSelector:aSelector]) {
        //looking for a required method
        struct objc_method_description desc = protocol_getMethodDescription(self.destinationProtocol, aSelector, YES, YES);
        
        //looking for a optional method
        if (NULL == desc.name) {
            desc = protocol_getMethodDescription(self.destinationProtocol, aSelector, NO, YES);
        }
        
        if (NULL == desc.name) {
            //Couldn't find method, raise exception: NSInvalidArgumentException
            [self doesNotRecognizeSelector:aSelector];
            return nil;
        }
        
        return self.destinationDelegate;
    }
    else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.sourceDelegate respondsToSelector:aSelector]) {
        //looking for a required method
        struct objc_method_description desc = protocol_getMethodDescription(self.sourceProtocol, aSelector, YES, YES);
        
        //looking for a optional method
        if (NULL == desc.name) {
            desc = protocol_getMethodDescription(self.sourceProtocol, aSelector, NO, YES);
        }

        return (NULL != desc.name);
    }
    else if ([self.destinationDelegate respondsToSelector:aSelector]) {
        //looking for a required method
        struct objc_method_description desc = protocol_getMethodDescription(self.destinationProtocol, aSelector, YES, YES);
        
        //looking for a optional method
        if (NULL == desc.name) {
            desc = protocol_getMethodDescription(self.destinationProtocol, aSelector, NO, YES);
        }

        return (NULL != desc.name);
    }
    else {
        return [super respondsToSelector:aSelector];
    }
}
 
@end
