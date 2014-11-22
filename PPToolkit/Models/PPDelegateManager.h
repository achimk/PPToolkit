//
//  PPDelegateManager.h
//  PPToolkit
//
//  Created by Joachim Kret on 17.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPDelegateManager : NSObject

@property (nonatomic, readonly, strong) Protocol * protocol;
@property (nonatomic, readonly, strong) NSMutableSet * delegates;

- (id)initWithProtocol:(Protocol *)protocol delegates:(NSSet *)delegates;
- (void)registerDelegate:(id)delegate;
- (void)unregisterDelegate:(id)delegate;

@end
