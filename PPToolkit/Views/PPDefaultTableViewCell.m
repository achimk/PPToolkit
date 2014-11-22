//
//  PPDefaultTableViewCell.m
//  PPToolkit
//
//  Created by Joachim Kret on 22.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPDefaultTableViewCell.h"

#define kDefaultTableViewCellHeight     44.0f

@implementation PPDefaultTableViewCell

+ (UITableViewCellStyle)defaultTableViewCellStyle {
    return UITableViewCellStyleDefault;
}

+ (NSString *)defaultTableViewCellIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)defaultTableViewCellNibName {
    return nil;
}

+ (UINib *)defaultNib {
    if ([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        return [UINib nibWithNibName:[self defaultTableViewCellNibName] bundle:bundle];
    }
    
    return nil;
}

+ (CGFloat)defaultTableViewCellHeight {
    if ([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length]) {
        NSArray * nibObjects = [[self defaultNib] instantiateWithOwner:nil options:nil];
        NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", [self defaultTableViewCellNibName], NSStringFromClass([self class]));
        UITableViewCell * cell = (UITableViewCell *)[nibObjects objectAtIndex:0];
        return cell.bounds.size.height;
    }
    
    return kDefaultTableViewCellHeight;
}

+ (UITableViewCell *)cellForTableView:(UITableView *)tableView {
    NSParameterAssert(tableView);
    
    UITableViewCell * cell = nil;
    
    if ([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length]) {
        cell = [self cellForTableView:tableView fromNib:[self defaultNib]];
    }
    else {
        NSAssert([self defaultTableViewCellIdentifier] && [[self defaultTableViewCellIdentifier] length], @"Default table view cell identifier is empty");
        
        NSString * cellIdentifier = [self defaultTableViewCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            [tableView registerClass:[self class] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
    }
    
    return cell;
}

+ (UITableViewCell *)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib {
    NSParameterAssert(tableView);
    NSParameterAssert(nib);
    NSAssert([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length], @"Default table view cell nib name is empty");
    
    NSString * cellIdentifier = [self defaultTableViewCellNibName];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    return cell;
}

#pragma mark Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return (self = [super initWithStyle:[[self class] defaultTableViewCellStyle] reuseIdentifier:reuseIdentifier]);
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
 
    if (UITableViewCellStyleSubtitle == [[self class] defaultTableViewCellStyle]) {
        self.detailTextLabel.frame = CGRectOffset(self.detailTextLabel.frame, 0.0f, -2.0f);
    }
}

@end
