//
//  NSBundle+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 05.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#define PPToolkitLocalizedString(key) [[NSBundle ppToolkitBundle] localizedStringForKey:(key) value:@"" table:@"PPToolkit"]

@interface NSBundle (PPToolkitAdditions)

+ (NSBundle *)pp_ToolkitBundle;

@end
