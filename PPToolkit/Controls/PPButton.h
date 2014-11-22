//
//  PPButton.h
//  PPToolkit
//
//  Created by Joachim Kret on 16.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PPButtonImagePositionLeft   = 0,
    PPButtonImagePositionRight,
    PPButtonImagePositionTop,
    PPButtonImagePositionBottom
} PPButtonImagePosition;

@interface PPButton : UIButton

@property (nonatomic, readwrite, assign) PPButtonImagePosition imagePosition;

- (void)finishInitialize;

@end
