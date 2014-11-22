//
//  PPDelegateInterceptor.h
//  PPToolkit
//
//  Created by Joachim Kret on 12.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPDelegateInterceptor : NSObject

@property (nonatomic, readonly, strong) Protocol * sourceProtocol;
@property (nonatomic, readonly, strong) Protocol * destinationProtocol;
@property (nonatomic, readonly, strong) id sourceDelegate;
@property (nonatomic, readonly, strong) id destinationDelegate;

- (id)initWithSourceProtocol:(Protocol *)sourceProtocol sourceDelegate:(id)sourceDelegate destinationProtocol:(Protocol *)destinationProtocol destinationDelegate:(id)destinationDelegate;

@end
