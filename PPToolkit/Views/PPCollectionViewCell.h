//
//  PPCollectionViewCell.h
//  PPToolkit
//
//  Created by Joachim Kret on 23.05.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PSTCollectionView.h"
#import "PSTCollectionViewCell.h"

#pragma mark - PPCollectionViewCellProtocol

@protocol PPCollectionViewCellProtocol <NSObject>

@required
- (void)finishInitialize;
- (void)configureViews;
- (void)configureForData:(id)dataObject collectionView:(PSUICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - PPCollectionViewCell

@interface PPCollectionViewCell : PSUICollectionViewCell <PPCollectionViewCellProtocol>

@property (nonatomic, readonly, strong) UILabel * textLabel;
@property (nonatomic, readonly, strong) UILabel * detailTextLabel;
@property (nonatomic, readonly, strong) UIImageView * imageView;
@property (nonatomic, readonly, assign) UIControlState controlState;
@property (nonatomic, readwrite, assign) BOOL layoutImagePlaceholder;

+ (UIEdgeInsets)defaultEdgeInsets;
+ (Class)defaultCellBackgroundViewClass;

- (UIControlState)controlStateForBackgroundView:(UIView *)backgroundView;
- (void)setTitleTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setDetailTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (NSDictionary *)detailTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
