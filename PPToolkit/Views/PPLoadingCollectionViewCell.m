//
//  PPLoadingCollectionViewCell.m
//  PPToolkit
//
//  Created by Joachim Kret on 12.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPLoadingCollectionViewCell.h"

@implementation PPLoadingCollectionViewCell

@synthesize activityIndicatorView = _activityIndicatorView;

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    self.imageView.hidden = YES;
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_activityIndicatorView];
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.hidden = YES;
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
    
    [self.activityIndicatorView stopAnimating];
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.activityIndicatorView sizeToFit];
    _activityIndicatorView.frame = CGRectMake(floorf((self.contentView.bounds.size.width - self.activityIndicatorView.bounds.size.width) * 0.5f), floorf((self.contentView.bounds.size.height - self.activityIndicatorView.bounds.size.height) * 0.5f), self.activityIndicatorView.bounds.size.width, self.activityIndicatorView.bounds.size.height);
}

- (void)configureViews {
    [super configureViews];
    [self.activityIndicatorView startAnimating];
    [self setNeedsDisplay];
}

@end
