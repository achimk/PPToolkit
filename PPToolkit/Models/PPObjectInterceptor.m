//
//  PPObjectInterceptor.m
//  PPToolkit
//
//  Created by Joachim Kret on 25.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPObjectInterceptor.h"

#import <objc/runtime.h>

@implementation PPObjectInterceptor

@synthesize sourceObject = _sourceObject;
@synthesize destinationObject = _destinationObject;

#pragma mark Init

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke %@ instead.",
                                           NSStringFromClass([self class]),
                                           NSStringFromSelector(@selector(initWithSourceObject:destinationObject:))]
                                 userInfo:nil];
    return nil;
}

- (id)initWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject {
    NSParameterAssert(sourceObject);
    NSParameterAssert(destinationObject);
    
    if (self = [super init]) {
        _sourceObject = sourceObject;
        _destinationObject = destinationObject;
    }
    
    return self;
}

#pragma mark NSObject

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.sourceObject respondsToSelector:aSelector]) {
        return self.sourceObject;
    }
    else if ([self.destinationObject respondsToSelector:aSelector]) {
        return self.destinationObject;
    }
    else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.sourceObject respondsToSelector:aSelector]) {
        return YES;
    }
    else if ([self.destinationObject respondsToSelector:aSelector]) {
        return YES;
    }
    else {
        return [super respondsToSelector:aSelector];
    }
}
 
@end
