//
//  PPPageScrollViewCell.m
//  PPToolkit
//
//  Created by Joachim Kret on 17.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPPageScrollViewCell.h"

@implementation PPPageScrollViewCell

@synthesize reuseIdentifier = _reuseIdentifier;

#pragma mark Init

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame reuseIdentifier:NSStringFromClass([self class])];
}

- (id)initWithReuseIdentifier:(NSString *)identifier {
    return [self initWithFrame:CGRectZero reuseIdentifier:identifier];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    
    if (self = [super initWithFrame:frame]) {
        _reuseIdentifier = [identifier copy];
    }
    
    return self;
}

#pragma mark Reuse

- (void)prepareForReuse {
}

@end
