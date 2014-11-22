//
//  PPTableView.m
//  PPToolkit
//
//  Created by Joachim Kret on 24.05.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPTableView.h"


@interface PPTableView () {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    NSMutableDictionary * _cellNibDictionary;
    NSMutableDictionary * _cellClassDictionary;
#endif
    
}

@end

#pragma mark -

@implementation PPTableView

#pragma mark Init

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self finishInitialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    return self;
}

- (void)finishInitialize {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    _cellNibDictionary = [NSMutableDictionary new];
    _cellClassDictionary = [NSMutableDictionary new];
#endif
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark iOS 4.3+ Bridge
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    NSParameterAssert(nib);
    NSParameterAssert(identifier);
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        NSArray * topLevelObjects = [nib instantiateWithOwner:nil options:nil];
#pragma unused(topLevelObjects)
        NSAssert(1 == topLevelObjects.count && [[topLevelObjects objectAtIndex:0] isKindOfClass:[UITableViewCell class]], @"must contain exacly 1 top level object which is a UITableViewCell");
        
        _cellNibDictionary[identifier] = nib;
    }
    else {
        [super registerNib:nib forCellReuseIdentifier:identifier];
    }
}

#endif

#pragma mark iOS 5.0+ Bridge
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    NSParameterAssert(cellClass);
    NSParameterAssert(identifier);
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        _cellClassDictionary[identifier] = cellClass;
    }
    else {
        [super registerClass:cellClass forCellReuseIdentifier:identifier];
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        id cell = [super dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            if (_cellNibDictionary[identifier]) {
                UINib * cellNib = _cellNibDictionary[identifier];
                cell = [[cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
            }
            else if (_cellClassDictionary[identifier]) {
                Class cellClass = _cellClassDictionary[identifier];
                cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
        }
        
        return cell;
    }
    else {
        return [super dequeueReusableCellWithIdentifier:identifier];
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(identifier);
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        return [self dequeueReusableCellWithIdentifier:identifier];
    }
    else {
        return [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    }
}

#endif

@end
