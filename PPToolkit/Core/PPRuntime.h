//
//  PPRuntime.h
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <objc/runtime.h>

/**
 * Enable or disable logging of the messages sent through objc_msgSend. Messages are logged to
 *    /tmp/msgSends-XXXX
 * with the following format:
 *    <Receiver object class> <Class which implements the method> <Selector name>
 *
 * Remark:
 * This is a function secretely implemented by the Objective-C runtime, not by CoconutKit. The declaration
 * is here only provided for convenience
 */
void instrumentObjcMessageSends(BOOL start);

/**
 * Replace the implementation of a class method, given its selector. Return the original implementation
 */
IMP PPSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original implementation
 */
IMP PPSwizzleSelector(Class clazz, SEL selector, IMP newImplementation);