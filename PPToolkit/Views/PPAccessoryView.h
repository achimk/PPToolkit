//
//  PPAccessoryView.h
//  PPToolkit
//
//  Created by Joachim Kret on 09.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kPPAccessoryTypeDisclosureIndicator = 0,
    kPPAccessoryTypeCheckmark,
} PPAccessoryType;

@interface PPAccessoryView : UIView

@property (nonatomic, readwrite, assign) PPAccessoryType accessoryType;
@property (nonatomic, readwrite, strong) UIColor * accessoryColor;

@end
