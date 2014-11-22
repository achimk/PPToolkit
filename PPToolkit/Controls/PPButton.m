//
//  PPButton.m
//  PPToolkit
//
//  Created by Joachim Kret on 16.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPButton.h"

#import "PPDrawingUtilities.h"

#define kDefaultMargin  4.0f

@implementation PPButton

@synthesize imagePosition = _imagePosition;

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)finishInitialize {
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (PPButtonImagePositionRight == self.imagePosition) {
        CGRect imageRect = self.imageView.frame;
        CGRect labelRect = self.titleLabel.frame;
        
        labelRect.origin.x = floorf(imageRect.origin.x - self.imageEdgeInsets.left + self.imageEdgeInsets.right);
        imageRect.origin.x = floorf(imageRect.origin.x + labelRect.size.width);
        
        self.imageView.frame = imageRect;
        self.titleLabel.frame = labelRect;
    }
    else if (PPButtonImagePositionTop == self.imagePosition) {
        CGFloat height = self.bounds.size.height;
        
        if (!self.titleLabel.hidden && self.titleLabel.text && self.titleLabel.text.length) {
            CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                                    forWidth:self.bounds.size.width
                                               lineBreakMode:self.titleLabel.lineBreakMode];
            
            if (!self.imageView.hidden && self.imageView.image) {
                CGRect frame = CGRectMake(floorf((self.bounds.size.width - size.width) * 0.5f),
                                          floorf(self.bounds.size.height - size.height - kDefaultMargin),
                                          size.width,
                                          size.height);
                self.titleLabel.frame = UIEdgeInsetsInsetRect(frame, self.titleEdgeInsets);
                height -= size.height + kDefaultMargin;
            }
            else {
                CGRect frame = CGRectMake(floorf((self.bounds.size.width - size.width) * 0.5f),
                                          floorf((self.bounds.size.height - size.height) * 0.5f),
                                          size.width,
                                          size.height);
                
                self.titleLabel.frame = UIEdgeInsetsInsetRect(frame, self.titleEdgeInsets);
            }
        }
        
        if (!self.imageView.hidden && self.imageView.image) {
            CGRect frame = self.bounds;
            frame.size.height = height;
            frame.size = CGSizeAspectScaleToSize(self.imageView.image.size, frame.size);
            frame.origin.x = floorf((self.bounds.size.width - frame.size.width) * 0.5f);
            frame.origin.y = floorf((height - frame.size.height) * 0.5f);
            self.imageView.frame = UIEdgeInsetsInsetRect(frame, self.imageEdgeInsets);
        }
    }
    else if (PPButtonImagePositionBottom == self.imagePosition) {
        //TODO: implement
        NSAssert(NO, @"Implement PPButtonImagePositionBottom");
    }
}

@end
