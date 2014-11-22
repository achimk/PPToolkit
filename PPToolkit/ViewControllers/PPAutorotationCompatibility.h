//
//  PPAutorotationCompatibility.h
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This protocol exists to suppress warnings when compiling against the iOS 5 SDK
 */
@protocol PPAutorotationCompatibility <NSObject>

@optional

/**
 * Return whether autorotation should occur or not
 */
- (BOOL)shouldAutorotate;

/**
 * Returns all of the interface orientations that are supported
 */
- (NSUInteger)supportedInterfaceOrientations;

@end