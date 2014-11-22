//
//  PPObjectInterceptor.h
//  PPToolkit
//
//  Created by Joachim Kret on 25.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPObjectInterceptor : NSObject

@property (nonatomic, readonly, strong) id sourceObject;
@property (nonatomic, readonly, strong) id destinationObject;

- (id)initWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject;

@end
