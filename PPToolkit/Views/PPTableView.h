//
//  PPTableView.h
//  PPToolkit
//
//  Created by Joachim Kret on 24.05.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPTableView : UITableView

- (void)finishInitialize;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
#endif

@end
