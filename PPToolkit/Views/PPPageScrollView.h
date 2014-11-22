//
//  PPPageScrollView.h
//  PPToolkit
//
//  Created by Joachim Kret on 17.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

@class PPPageScrollViewCell, PPTouchView;

@interface PPPageScrollView : UIView <UIScrollViewDelegate> {
@protected
    UIScrollView            * _scrollView;
    PPTouchView             * _scrollTouchView;
    UITapGestureRecognizer  * _tapGestureRecognizer;
    
    NSMutableDictionary     * _reusablePages;
    NSMutableArray          * _visiblePages;
    NSRange                 _visibleIndexes;
    
    NSInteger               _numberOfPages;
    PPPageScrollViewCell    * _selectedPageCell;
    BOOL                    _isPendingScrolledPageUpdateNotification;
}

@property (nonatomic, readwrite, assign) id<PPPageScrollViewDelegate> delegate;
@property (nonatomic, readwrite, assign) id<PPPageScrollViewDataSource> dataSource;

@property (nonatomic, readonly, strong) UIScrollView * scrollView;
@property (nonatomic, readonly, strong) PPTouchView * scrollTouchView;
@property (nonatomic, readonly, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, readonly, assign) NSInteger numberOfPages;

- (PPPageScrollViewCell *)pageAtIndex:(NSInteger)index;
- (NSInteger)indexForSelectedPage;
- (NSInteger)indexForVisiblePage:(PPPageScrollViewCell *)pageCell;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)deselectPageAtInex:(NSInteger)index animated:(BOOL)animated;

- (PPPageScrollViewCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier;
- (void)reloadData;

@end
