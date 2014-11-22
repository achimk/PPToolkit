//
//  PPSynthesizeSingleton.h
//  PPToolkit
//
//  Created by Joachim Kret on 06.04.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#define SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName) \
\
static classname * accessorMethodName = nil; \
\
+ (classname *)accessorMethodName { \
if (accessorMethodName) { \
return accessorMethodName; \
} \
static dispatch_once_t onceDispatch; \
dispatch_once(&onceDispatch, ^{ \
accessorMethodName = [[self alloc] init]; \
}); \
return accessorMethodName; \
}

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, shared##classname)