//
//  PPDefaultTableViewCell.h
//  PPToolkit
//
//  Created by Joachim Kret on 22.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPTableViewCell.h"

@interface PPDefaultTableViewCell : PPTableViewCell

+ (UITableViewCellStyle)defaultTableViewCellStyle;
+ (NSString *)defaultTableViewCellIdentifier;
+ (NSString *)defaultTableViewCellNibName;
+ (UINib *)defaultNib;
+ (CGFloat)defaultTableViewCellHeight;

+ (UITableViewCell *)cellForTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib;

@end
