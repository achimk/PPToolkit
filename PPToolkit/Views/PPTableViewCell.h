//
//  PPTableViewCell.h
//  PPToolkit
//
//  Created by Joachim Kret on 08.02.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPAccessoryView.h"

#pragma mark - PPTableViewCellProtocol

@protocol PPTableViewCellProtocol <NSObject>

@required
- (void)finishInitialize;
- (void)configureViews;
- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - PPTableViewCell

@interface PPTableViewCell : UITableViewCell <PPTableViewCellProtocol>

@property (nonatomic, readonly, strong) UILabel * accessoryTextLabel;
@property (nonatomic, readonly, strong) PPAccessoryView * accessoryCellView;
@property (nonatomic, readonly, assign) UIControlState controlState;

+ (Class)defaultCellBackgroundViewClass;

- (void)setTitleTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setDetailTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setAccessoryTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setAccessoryCellViewColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (NSDictionary *)detailTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (NSDictionary *)accessoryTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIColor *)accessoryCellViewColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
