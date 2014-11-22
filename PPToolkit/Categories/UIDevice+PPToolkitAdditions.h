//
//  UIDevice+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 19.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (PPToolkitAdditions)

- (BOOL)pp_isSimulator;
- (BOOL)pp_isCrappy;

@end
