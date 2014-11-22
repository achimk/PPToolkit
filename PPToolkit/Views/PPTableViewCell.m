//
//  PPTableViewCell.m
//  PPToolkit
//
//  Created by Joachim Kret on 08.02.2013.
//  Copyright (c) 2013 Joachi Kret. All rights reserved.
//

#import "PPTableViewCell.h"
#import "PPTableCellBackgroundView.h"

#define ControlStatePresentInMask(state,mask) ({ __typeof__(state) __s = (state); __typeof__(mask) __m = (mask); (__s == UIControlStateNormal) ? (__m == UIControlStateNormal) : ((__m & __s) == __s); })

@interface PPTableViewCell () {
    NSMutableDictionary     * _titleTextAttributesForState;
    NSMutableDictionary     * _detailTextAttributesForState;
    NSMutableDictionary     * _accessoryTextAttributesForState;
    NSMutableDictionary     * _accessoryCellViewColorForState;
}

- (void)_applyTextAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label;
- (void)_setValue:(id)value inStateDictionary:(NSMutableDictionary *)stateDictionary forState:(UIControlState)state;
- (id)_valueInStateDictionary:(NSDictionary *)stateDictionary forState:(UIControlState)state;

@end

#pragma mark -

@implementation PPTableViewCell

@synthesize accessoryTextLabel = _accessoryTextLabel;
@synthesize accessoryCellView = _accessoryCellView;
@dynamic controlState;

+ (Class)defaultCellBackgroundViewClass {
    return [PPTableCellBackgroundView class];
}

#pragma mark Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self finishInitialize];
        [self configureViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self finishInitialize];
    [self configureViews];
}

- (void)finishInitialize {
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
#warning Implement display accessory text label
    _accessoryTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _accessoryTextLabel.backgroundColor = [UIColor clearColor];
    
    _accessoryCellView = [[PPAccessoryView alloc] initWithFrame:CGRectZero];
    _accessoryCellView.backgroundColor = [UIColor clearColor];
    
    _titleTextAttributesForState = [NSMutableDictionary new];
    _detailTextAttributesForState = [NSMutableDictionary new];
    _accessoryTextAttributesForState = [NSMutableDictionary new];
    _accessoryCellViewColorForState = [NSMutableDictionary new];
    
    if ([[self class] defaultCellBackgroundViewClass]) {
        self.backgroundView = [[[self class] defaultCellBackgroundViewClass] new];
        self.selectedBackgroundView = [[[self class] defaultCellBackgroundViewClass] new];
    }
}

#pragma mark Accessors

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    
    switch (accessoryType) {
        case UITableViewCellAccessoryNone: {
            [self.accessoryView removeFromSuperview];
            self.accessoryView = nil;
            break;
        }
        case UITableViewCellAccessoryDisclosureIndicator: {
            self.accessoryCellView.accessoryType = kPPAccessoryTypeDisclosureIndicator;
            [self.accessoryCellView sizeToFit];
            self.accessoryView = self.accessoryCellView;
            
            if (!self.accessoryView.superview) {
                [self.contentView addSubview:self.accessoryView];
            }
            
            break;
        }
        case UITableViewCellAccessoryCheckmark: {
            self.accessoryCellView.accessoryType = kPPAccessoryTypeCheckmark;
            [self.accessoryCellView sizeToFit];
            self.accessoryView = self.accessoryCellView;
            
            if (!self.accessoryView.superview) {
                [self.contentView addSubview:self.accessoryView];
            }

            break;
        }
        case UITableViewCellAccessoryDetailDisclosureButton: {
            break;
        }
        default: {
            break;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animate {
    [super setSelected:selected animated:animate];
    [self configureViews];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
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

- (void)setAccessoryTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state {
    [self _setValue:textAttributes inStateDictionary:_accessoryTextAttributesForState forState:state];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    if (ControlStatePresentInMask(self.controlState, state)) {
        [self _applyTextAttributes:textAttributes toLabel:self.accessoryTextLabel];
    }
#endif
    [self setNeedsDisplay];
}

- (void)setAccessoryCellViewColor:(UIColor *)color forState:(UIControlState)state {
    [self _setValue:color inStateDictionary:_accessoryCellViewColorForState forState:state];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    if (ControlStatePresentInMask(self.controlState, state)) {
        self.accessoryCellView.accessoryColor = color;
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

- (NSDictionary *)accessoryTextAttributesForState:(UIControlState)state {
    return [self _valueInStateDictionary:_accessoryTextAttributesForState forState:state];
}

- (UIColor *)accessoryCellViewColorForState:(UIControlState)state {
    return [self _valueInStateDictionary:_accessoryCellViewColorForState forState:state];
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

#pragma mark Prepare for Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.imageView.image = nil;
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (UITableViewCellAccessoryCheckmark == self.accessoryType) {
        self.accessoryView.frame = CGRectOffset(self.accessoryView.frame, 0.0f, 2.0f);
    }
}

- (void)configureViews {
    [self _applyTextAttributes:[self titleTextAttributesForState:self.controlState] toLabel:self.textLabel];
    [self _applyTextAttributes:[self detailTextAttributesForState:self.controlState] toLabel:self.detailTextLabel];
    [self _applyTextAttributes:[self accessoryTextAttributesForState:self.controlState] toLabel:self.accessoryTextLabel];

    self.accessoryCellView.accessoryColor = [self accessoryCellViewColorForState:self.controlState];
    
    [self.backgroundView setNeedsDisplay];
}

- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
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
