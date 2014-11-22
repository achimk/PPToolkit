//
//  PPPageScrollViewCell.h
//  PPToolkit
//
//  Created by Joachim Kret on 17.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPPageScrollViewCell : UIView {
@protected
    NSString    * _reuseIdentifier;
}

@property (nonatomic, readonly, copy) NSString * reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)identifier;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier;

- (void)prepareForReuse;

@end
