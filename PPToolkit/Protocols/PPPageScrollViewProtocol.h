//
//  PPPageScrollViewProtocol.h
//  PPToolkit
//
//  Created by Joachim Kret on 17.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPPageScrollView, PPPageScrollViewCell;

@protocol PPPageScrollViewDelegate <NSObject>

@optional

- (void)pageScrollView:(PPPageScrollView *)pageScrollView willScrollToPage:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index;
- (void)pageScrollView:(PPPageScrollView *)pageScrollView didScrollToPage:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index;

- (NSInteger)pageScrollView:(PPPageScrollView *)pageScrollView willSelectPageAtIndex:(NSInteger)index;
- (void)pageScrollView:(PPPageScrollView *)pageScrollView didSelectPageAtIndex:(NSInteger)index;

- (NSInteger)pageScrollView:(PPPageScrollView *)pageScrollView willDeselectPageAtIndex:(NSInteger)index;
- (void)pageScrollView:(PPPageScrollView *)pageScrollView didDeselectPageAtIndex:(NSInteger)index;

@end

@protocol PPPageScrollViewDataSource <NSObject>

@required
- (NSInteger)numberOfPagesInPageScrollView:(PPPageScrollView *)pageScrollView;
- (PPPageScrollViewCell *)pageScrollView:(PPPageScrollView *)pageScrollView cellForPageAtIndex:(NSInteger)index;

@end
