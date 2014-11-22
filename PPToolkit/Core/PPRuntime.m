//
//  PPRuntime.m
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPRuntime.h"

IMP PPSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation) {
    // Get the original implementation we are replacing
    Class metaClass = objc_getMetaClass(class_getName(clazz));
    Method method = class_getClassMethod(metaClass, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(metaClass, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}

IMP PPSwizzleSelector(Class clazz, SEL selector, IMP newImplementation) {
    // Get the original implementation we are replacing
    Method method = class_getInstanceMethod(clazz, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(clazz, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}
