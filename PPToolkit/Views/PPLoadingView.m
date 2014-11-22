//
//  PPLoadingView.m
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPLoadingView.h"

#define kDefaultImageHeight                 70.0f
#define kDefaultLabelHeight                 21.0f

@implementation PPLoadingView

@synthesize imageView = _imageView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;

#pragma mark Init

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishInitialize];
        [self setLoadingContentState:PPLoadingContentStateNormal];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
        [self setLoadingContentState:PPLoadingContentStateNormal];
    }
    return self;
}

- (void)finishInitialize {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicatorView sizeToFit];
    [self addSubview:_activityIndicatorView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    
    _detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    _detailTextLabel.textColor = [UIColor lightGrayColor];
    _detailTextLabel.backgroundColor = [UIColor clearColor];
    _detailTextLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_detailTextLabel];
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = 0.0f;
    
    if (_imageView.image && !_imageView.hidden) {
        height += kDefaultImageHeight;
    }
    if (!_activityIndicatorView.hidden) {
        height += _activityIndicatorView.bounds.size.height;
    }
    if (_textLabel.text.length && !_textLabel.hidden) {
        height += kDefaultLabelHeight;
    }
    if (_detailTextLabel.text.length && !_detailTextLabel.hidden) {
        height += kDefaultLabelHeight;
    }
    
    height = (self.bounds.size.height - height) * 0.5f;
    
    if (_imageView.image && !_imageView.hidden) {
        _imageView.frame = CGRectMake(floorf((self.bounds.size.width - kDefaultImageHeight) * 0.5f), floorf(height), kDefaultImageHeight, kDefaultImageHeight);
        height += kDefaultImageHeight;
    }
    if (!_activityIndicatorView.hidden) {
        _activityIndicatorView.frame = CGRectMake(floorf((self.bounds.size.width - _activityIndicatorView.bounds.size.width) * 0.5f), floorf(height), _activityIndicatorView.bounds.size.width, _activityIndicatorView.bounds.size.height);
    }
    if (_textLabel.text.length && !_textLabel.hidden) {
        _textLabel.frame = CGRectMake(0.0f, floorf(height), self.bounds.size.width, kDefaultLabelHeight);
        height += kDefaultLabelHeight;
    }
    if (_detailTextLabel.text.length && !_detailTextLabel.hidden) {
        _detailTextLabel.frame = CGRectMake(0.0f, floorf(height), self.bounds.size.width, kDefaultLabelHeight);
    }
}

#pragma mark PPLoadingContentProtocol

- (void)setLoadingContentState:(PPLoadingContentState)state {
    [self setLoadingContentState:state withPreviusState:PPLoadingContentStateUndefined object:nil];
}

- (void)setLoadingContentState:(PPLoadingContentState)newState withPreviusState:(PPLoadingContentState)oldState object:(id)object {
    switch (newState) {
        case PPLoadingContentStateUndefined:
        case PPLoadingContentStateNormal: {
            _imageView.hidden = _activityIndicatorView.hidden = _textLabel.hidden = _detailTextLabel.hidden = YES;
            [_activityIndicatorView stopAnimating];
            break;
        }
        case PPLoadingContentStateLoading: {
            _imageView.hidden = _textLabel.hidden = _detailTextLabel.hidden = YES;
            _activityIndicatorView.hidden = NO;
            [_activityIndicatorView startAnimating];
            break;
        }
        case PPLoadingContentStateEmpty:
        case PPLoadingContentStateError: {
            _imageView.hidden = _textLabel.hidden = _detailTextLabel.hidden = NO;
            _activityIndicatorView.hidden = YES;
            [_activityIndicatorView stopAnimating];
            break;
        }
        default: {
            break;
        }
    }
    
    [self setNeedsLayout];
}
 
@end
