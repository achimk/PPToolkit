//
//  PPToolkitDefines.h
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#ifndef PPTOOLKITDEFINES
#define PPTOOLKITDEFINES

/*
 * Define to use iOS 7 SDK
 */
#define IS_iOS7_SDK     1

/*
 *  User Interface Device Preprocessor Macros
 */
#define IS_SIMULATOR    (TARGET_IPHONE_SIMULATOR)
#define IS_IPAD         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5     (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA       ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f)

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 *  Loading states
 */

typedef enum {
    PPLoadingStateIdle      = 0,
    PPLoadingStateEmpty,
    PPLoadingStateError,
    PPLoadingStateInitial,
    PPLoadingStateRefresh,
    PPLoadingStateLoading
} PPLoadingState;

/*
 *  Error Codes
 */

typedef enum {
    kPPToolkitOperationCancelledError    = 1,
} PPToolkitErrorCodes;

/*
 *  Other Costants
 */

extern NSString * const kPPToolkitBundleName;
extern NSString * const kPPToolkitErrorDomain;
extern const NSUInteger kPPToolkitFetchBatchSize;

/*
 *  Utilities
 */

extern NSString * PPStringFromBool(BOOL yesOrNo);
extern NSString * PPStringFromInterfaceOrientation(UIInterfaceOrientation interfaceOrientation);
extern NSString * PPStringFromDeviceOrientation(UIDeviceOrientation deviceOrientation);
extern NSString * PPStringFromManagedObjectContextConcurrencyType(NSManagedObjectContextConcurrencyType ct);
extern NSString * PPStringFromLoadingState(PPLoadingState state);

#endif