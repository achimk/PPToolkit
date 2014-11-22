//
//  PPCollectionViewCell.m
//  PPToolkit
//
//  Created by Joachim Kret on 23.05.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPCollectionViewCell.h"

#import "PPCollectionCellBackgroundView.h"

#define ControlStatePresentInMask(state,mask) ({ __typeof__(state) __s = (state); __typeof__(mask) __m = (mask); (__s == UIControlStateNormal) ? (__m == UIControlStateNormal) : ((__m & __s) == __s); })

#define kDefaultMargin  3.0f

@interface PPCollectionViewCell () {
    NSMutableDictionary     * _titleTextAttributesForState;
    NSMutableDictionary     * _detailTextAttributesForState;
}

- (void)_applyTextAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label;
- (void)_setValue:(id)value inStateDictionary:(NSMutableDictionary *)stateDictionary forState:(UIControlState)state;
- (id)_valueInStateDictionary:(NSDictionary *)stateDictionary forState:(UIControlState)state;

@end

#pragma mark -

@implementation PPCollectionViewCell

@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize imageView = _imageView;
@synthesize layoutImagePlaceholder = _layoutImagePlaceholder;
@dynamic controlState;

+ (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
}

+ (Class)defaultCellBackgroundViewClass {
    return [PPCollectionCellBackgroundView class];
}

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
        [self configureViews];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishInitialize];
        [self configureViews];
    }
    
    return self;
}

- (void)finishInitialize {
    _layoutImagePlaceholder = NO;
    
    _textLabel = [UILabel new];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textLabel.numberOfLines = 1;
    _textLabel.textColor = [UIColor darkGrayColor];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textAlignment = UITextAlignmentCenter;
    _textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:_textLabel];
    
    _detailTextLabel = [UILabel new];
    _detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _detailTextLabel.numberOfLines = 1;
    _detailTextLabel.textColor = [UIColor grayColor];
    _detailTextLabel.backgroundColor = [UIColor clearColor];
    _detailTextLabel.textAlignment = UITextAlignmentCenter;
    _detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:_detailTextLabel];
    
    _imageView = [UIImageView new];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_imageView];
    
    _titleTextAttributesForState = [NSMutableDictionary new];
    _detailTextAttributesForState = [NSMutableDictionary new];
    
    if ([[self class] defaultCellBackgroundViewClass]) {
        self.backgroundView = [[[self class] defaultCellBackgroundViewClass] new];
        self.selectedBackgroundView = [[[self class] defaultCellBackgroundViewClass] new];
    }
}

#pragma mark Accessors

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self configureViews];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self configureViews];
}

- (void)setTitleTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state {
    [self _setValue:textAttributes inStateDictionary:_titleTextAttributesForState forState:state];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    if (ControlStatePresentInMask(self.controlState, state)) {
        [self _applyTextAttributes:textAttributes toLabel:self.textLabel];
    }
#endif
    [self setNeedsDisplay];
}

- (void)setDetailTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state {
    [self _setValue:textAttributes inStateDictionary:_detailTextAttributesForState forState:state];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    if (ControlStatePresentInMask(self.controlState, state)) {
        [self _applyTextAttributes:textAttributes toLabel:self.detailTextLabel];
    }
#endif
    [self setNeedsDisplay];
}

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state {
    return [self _valueInStateDictionary:_titleTextAttributesForState forState:state];
}

- (NSDictionary *)detailTextAttributesForState:(UIControlState)state {
    return [self _valueInStateDictionary:_detailTextAttributesForState forState:state];
}

- (UIControlState)controlState {
    if (self.isSelected) {
        return UIControlStateSelected;
    }
    else if (self.isHighlighted) {
        return UIControlStateHighlighted;
    }
    else {
        return UIControlStateNormal;
    }
}

- (UIControlState)controlStateForBackgroundView:(UIView *)backgroundView {
    NSParameterAssert(backgroundView);
    
    if (backgroundView == self.backgroundView) {
        return UIControlStateNormal;
    }
    else if (backgroundView == self.selectedBackgroundView) {
        return [self controlState];
    }
    else {
        return [self controlState];
    }
}

- (void)setLayoutImagePlaceholder:(BOOL)layoutImagePlaceholder {
    if (layoutImagePlaceholder != _layoutImagePlaceholder) {
        _layoutImagePlaceholder = layoutImagePlaceholder;
        [self setNeedsLayout];
    }
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = 0.0f;
    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, [[self class] defaultEdgeInsets]);
    CGSize textLabelSize = CGSizeZero;
    CGSize detailTextLabelSize = CGSizeZero;
    
    if (!self.imageView.hidden && self.imageView.image) {
        height += kDefaultMargin;
    }
    else if (self.layoutImagePlaceholder) {
        height += kDefaultMargin;
    }
    
    if (!self.textLabel.hidden && self.textLabel.text.length) {
        textLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font forWidth:frame.size.width lineBreakMode:self.textLabel.lineBreakMode];
        height += textLabelSize.height + kDefaultMargin;
    }
    
    if (!self.detailTextLabel.hidden && self.detailTextLabel.text.length) {
        detailTextLabelSize = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font forWidth:frame.size.width lineBreakMode:self.detailTextLabel.lineBreakMode];
        height += detailTextLabelSize.height + kDefaultMargin;
    }
    
    if (!self.imageView.hidden && self.imageView.image) {
        CGFloat availableHeight = frame.size.height - height;
        CGFloat widthRatio = (frame.size.width < self.imageView.image.size.width) ? frame.size.width / self.imageView.image.size.width : self.imageView.image.size.width / frame.size.width;
        CGFloat heightRatio = (availableHeight < self.imageView.image.size.height) ? availableHeight / self.imageView.image.size.height : self.imageView.image.size.height / availableHeight;
        CGFloat ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio;
        CGSize imageSize = CGSizeMake(self.imageView.image.size.width * ratio, self.imageView.image.size.height * ratio);
        
        self.imageView.frame = CGRectMake(floorf((frame.size.width - imageSize.width) * 0.5f + frame.origin.x), floorf((availableHeight - imageSize.height) * 0.5f + frame.origin.y), imageSize.width, imageSize.height);
        
        frame.origin.y = floorf(frame.origin.y + availableHeight + kDefaultMargin);
    }
    else if (self.layoutImagePlaceholder) {
        CGFloat availableHeight = frame.size.height - height;
        self.imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, availableHeight);
        frame.origin.y = floorf(frame.origin.y + availableHeight + kDefaultMargin);
    }
    
    if (!self.textLabel.hidden && self.textLabel.text.length) {
        self.textLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, textLabelSize.height);
        frame.origin.y = floorf(frame.origin.y + textLabelSize.height + kDefaultMargin);
    }
    
    if (!self.detailTextLabel.hidden && self.detailTextLabel.text.length) {
        self.detailTextLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, detailTextLabelSize.height);
        frame.origin.y = floorf(frame.origin.y + detailTextLabelSize.height + kDefaultMargin);
    }
}

- (void)configureViews {
    [self _applyTextAttributes:[self titleTextAttributesForState:self.controlState] toLabel:self.textLabel];
    [self _applyTextAttributes:[self detailTextAttributesForState:self.controlState] toLabel:self.detailTextLabel];
    
    [self.backgroundView setNeedsDisplay];
    [self.selectedBackgroundView setNeedsDisplay];
}

- (void)configureForData:(id)dataObject collectionView:(PSUICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [self configureViews];
}

#pragma mark Private Methods

- (void)_applyTextAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label {
    if (!label) {
        return;
    }
    
    if (attributes[UITextAttributeFont]) {
        label.font = attributes[UITextAttributeFont];
    }
    
    if (attributes[UITextAttributeTextColor]) {
        label.textColor = attributes[UITextAttributeTextColor];
        label.highlightedTextColor = attributes[UITextAttributeTextColor];
    }
    
    if (attributes[UITextAttributeTextShadowColor]) {
        label.shadowColor = attributes[UITextAttributeTextShadowColor];
    }
    
    if (attributes[UITextAttributeTextShadowOffset]) {
        label.shadowOffset = [attributes[UITextAttributeTextShadowOffset] CGSizeValue];
    }
}

- (void)_setValue:(id)value inStateDictionary:(NSMutableDictionary *)stateDictionary forState:(UIControlState)state {
    NSAssert(UIControlStateNormal == state || UIControlStateHighlighted == state || UIControlStateSelected == state, @"Queried control states must not be bit masks");
    
    static NSArray * __stateNumbers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __stateNumbers = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected)];
    });
    
    for (NSNumber * stateNumber in __stateNumbers) {
        NSUInteger stateInteger = [stateNumber unsignedIntegerValue];
        BOOL statePresentInMask = (UIControlStateNormal == stateInteger) ? (UIControlStateNormal == state) : (stateInteger == (state & stateInteger));
        
        if (statePresentInMask) {
            stateDictionary[stateNumber] = value;
        }
    }
}

- (id)_valueInStateDictionary:(NSDictionary *)stateDictionary forState:(UIControlState)state {
    NSAssert(UIControlStateNormal == state || UIControlStateHighlighted == state || UIControlStateSelected == state, @"Queried control states must not be bit masks");
    
    id stateDictionaryValue = stateDictionary[@(state)];
    
    if (stateDictionaryValue) {
        return stateDictionaryValue;
    }
    else if (UIControlStateSelected == state && stateDictionary[@(UIControlStateHighlighted)]) {
        return stateDictionary[@(UIControlStateHighlighted)];
    }
    else {
        return stateDictionary[@(UIControlStateNormal)];
    }
}

@end
