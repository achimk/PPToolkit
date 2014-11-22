//
//  PPToolkitDefines.m
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPToolkitDefines.h"

#pragma mark - Other Constants

NSString * const kPPToolkitBundleName       = @"PPToolkitResources.bundle";
NSString * const kPPToolkitErrorDomain      = @"com.PPToolkit.ErrorDomain";
const NSUInteger kPPToolkitFetchBatchSize   = 10;

#pragma mark - Utilities

NSString * PPStringFromBool(BOOL yesOrNo) {
    return yesOrNo ? @"YES" : @"NO";
}

NSString * PPStringFromInterfaceOrientation(UIInterfaceOrientation interfaceOrientation) {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            return @"UIInterfaceOrientationPortrait";
        }
            
        case UIInterfaceOrientationPortraitUpsideDown: {
            return @"UIInterfaceOrientationPortraitUpsideDown";
        }
            
        case UIInterfaceOrientationLandscapeLeft: {
            return @"UIInterfaceOrientationLandscapeLeft";
        }
            
        case UIInterfaceOrientationLandscapeRight: {
            return @"UIInterfaceOrientationLandscapeRight";
        }
            
        default: {
            return @"Unknown interface orientation";
        }
    }
}

NSString * PPStringFromDeviceOrientation(UIDeviceOrientation deviceOrientation) {
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            return @"UIDeviceOrientationPortrait";
        }
            
        case UIDeviceOrientationPortraitUpsideDown: {
            return @"UIDeviceOrientationPortraitUpsideDown";
        }
            
        case UIDeviceOrientationLandscapeLeft: {
            return @"UIDeviceOrientationLandscapeLeft";
        }
            
        case UIDeviceOrientationLandscapeRight: {
            return @"UIDeviceOrientationLandscapeRight";
        }
            
        default: {
            return @"Unknown device orientation";
        }
    }
}

NSString * PPStringFromManagedObjectContextConcurrencyType(NSManagedObjectContextConcurrencyType ct) {
    switch (ct) {
        case NSConfinementConcurrencyType: {
            return @"NSConfinementConcurrencyType";
        }
        case NSPrivateQueueConcurrencyType: {
            return @"NSPrivateQueueConcurrencyType";
        }
        case NSMainQueueConcurrencyType: {
            return @"NSMainQueueConcurrencyType";
        }
        default: {
            return @"Unknown concurency type";
        }
    }
}

NSString * PPStringFromLoadingState(PPLoadingState state) {
    switch (state) {
        case PPLoadingStateIdle: {
            return @"PPLoadingStateIdle";
        }
        case PPLoadingStateEmpty: {
            return @"PPLoadingStateEmpty";
        }
        case PPLoadingStateError: {
            return @"PPLoadingStateError";
        }
        case PPLoadingStateInitial: {
            return @"PPLoadingStateInitial";
        }
        case PPLoadingStateRefresh: {
            return @"PPLoadingStateRefresh";
        }
        case PPLoadingStateLoading: {
            return @"PPLoadingStateLoading";
        }
        default: {
            return @"Undefined";
        }
    }
}

