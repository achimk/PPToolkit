//
//  UITabBarController+PPToolkitExtensions.h
//  PPToolkit
//
//  Created by Joachim Kret on 26.07.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPAutorotation.h"

@interface UITabBarController (PPToolkitExtensions)

/**
 * Set how a tab bar controller decides whether it must rotate or not
 *
 * PPAutorotationModeContainer: The original UIKit behavior is used (the child view controllers decide on iOS 4 and 5,
 *                               none on iOS 6)
 * PPAutorotationModeContainerAndNoChildren: No children decide whether rotation occur, and none receive the
 *                                            related events
 * PPAutorotationModeContainerAndTopChildren
 * PPAutorotationModeContainerAndAllChildren: The child view controllers decide whether rotation can occur, and receive
 *                                             the related events
 *
 * The default value is PPAutorotationModeContainer
 */
@property (nonatomic, assign) PPAutorotationMode autorotationMode;

@end
