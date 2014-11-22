//
//  PPLoadingTableViewCell.m
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPLoadingTableViewCell.h"

@implementation PPLoadingTableViewCell

@synthesize activityIndicatorView = _activityIndicatorView;

#pragma mark Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_activityIndicatorView];
    }
    return self;
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
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
