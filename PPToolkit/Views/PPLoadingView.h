//
//  PPLoadingView.h
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

@interface PPLoadingView : UIView <PPLoadingContentProtocol> {
@protected
    UIImageView                 * _imageView;
    UIActivityIndicatorView     * _activityIndicatorView;
    UILabel                     * _textLabel;
    UILabel                     * _detailTextLabel;
}

@property (nonatomic, readonly, strong) UIImageView * imageView;
@property (nonatomic, readonly, strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, readonly, strong) UILabel * textLabel;
@property (nonatomic, readonly, strong) UILabel * detailTextLabel;

- (void)finishInitialize;

@end
