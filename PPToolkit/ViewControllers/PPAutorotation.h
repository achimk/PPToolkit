//
//  PPAutorotation.h
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

/**
 * Define the several ways for a container view controller to behave when interface rotation occurs. This means:
 *   - which view controllers decide whether rotation can occur or not
 *   - which view controllers receive rotation events (for children, this always occur from the topmost to the bottommost
 *     view controller, if they are involved)
 *
 * The default values are currently:
 *   - for iOS 4 and 5: PPAutorotationModeContainerAndTopChildren
 *   - for iOS 6: PPAutorotationModeContainer
 */
typedef enum {
    PPAutorotationModeEnumBegin = 0,
    PPAutorotationModeContainer = PPAutorotationModeEnumBegin,            // Default: The container implementation decides which view controllers are involved
    // and which ones receive events (for UIKit containers this might vary between iOS
    // versions)
    PPAutorotationModeContainerAndNoChildren,                              // The container only decides and receives events
    PPAutorotationModeContainerAndTopChildren,                             // The container and its top children decide and receive events. A container might have
    // several top children if it displays several view controllers next to each other
    PPAutorotationModeContainerAndAllChildren,                             // The container and all its children (even those not visible) decide and receive events
    PPAutorotationModeEnumEnd,
    PPAutorotationModeEnumSize = PPAutorotationModeEnumEnd - PPAutorotationModeEnumBegin
} PPAutorotationMode;


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

// Enum available starting with the iOS 6 SDK, here made available for previous SDK versions as well
typedef enum {
    UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
} UIInterfaceOrientationMask;

#endif
