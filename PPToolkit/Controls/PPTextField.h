//
//  PPTextField.h
//  PPToolkit
//
//  Created by Joachim Kret on 16.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPTextField : UITextField

@property (nonatomic, readwrite, strong) UIColor * placeholderTextColor;
@property (nonatomic, readwrite, assign) UIEdgeInsets textEdgeInsets;
@property (nonatomic, readwrite, assign) UIEdgeInsets clearButtonEdgeInsets;

- (void)finishInitialize;

@end
