//
//  PPPageScrollView.m
//  PPToolkit
//
//  Created by Joachim Kret on 17.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPPageScrollView.h"
#import "PPPageScrollViewCell.h"
#import "PPTouchView.h"

@interface PPPageScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, strong) UIScrollView * scrollView;
@property (nonatomic, readwrite, strong) PPTouchView * scrollTouchView;
@property (nonatomic, readwrite, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, readwrite, strong) PPPageScrollViewCell * selectedPageCell;
@property (nonatomic, readwrite, assign) NSInteger numberOfPages;

- (void)_finishConstruction;
- (void)_tapGestureRecognizer:(UITapGestureRecognizer *)sender;
- (void)_updateVisiblePages;
- (PPPageScrollViewCell *)_loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex;
- (void)_addPageToScrollView:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index;
- (void)_updateScrolledPage:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index;
- (void)_setFrameForPage:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index;

@end

#pragma mark -

@implementation PPPageScrollView

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize scrollTouchView = _scrollTouchView;
@synthesize scrollView = _scrollView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize selectedPageCell = _selectedPageCell;
@synthesize numberOfPages = _numberOfPages;

#pragma mark Init/Dealloc

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _finishConstruction];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _finishConstruction];
    }
    return self;
}

- (void)_finishConstruction {
    self.clipsToBounds = YES;
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _reusablePages = [[NSMutableDictionary alloc] initWithCapacity:3];
    _visiblePages = [[NSMutableArray alloc] initWithCapacity:3];
    _visibleIndexes.location = 0;
    _visibleIndexes.length = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizer:)];
    _tapGestureRecognizer.delegate = self;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.autoresizesSubviews = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.backgroundColor = [UIColor blackColor];
    
    [_scrollView addGestureRecognizer:_tapGestureRecognizer];
    [self addSubview:_scrollView];
    
    _scrollTouchView = [[PPTouchView alloc] initWithFrame:self.bounds];
    _scrollTouchView.receiver = _scrollView;
    [self addSubview:_scrollTouchView];
}

- (void)dealloc {
    [_scrollView removeGestureRecognizer:_tapGestureRecognizer];
}

#pragma mark Accessors

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        _scrollView.contentSize = CGSizeMake(_numberOfPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
}

- (void)setDataSource:(id<PPPageScrollViewDataSource>)dataSource {
    if (dataSource != _dataSource) {
        [self willChangeValueForKey:@"dataSource"];
        _dataSource = dataSource;
        [self didChangeValueForKey:@"dataSource"];
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (numberOfPages != _numberOfPages) {
        [self willChangeValueForKey:@"numberOfPages"];
        _numberOfPages = numberOfPages;
        [self didChangeValueForKey:@"numberOfPages"];
        
        _scrollView.contentSize = CGSizeMake(_numberOfPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollTouchView.frame = self.bounds;
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.numberOfPages * _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    
    if (self.numberOfPages) {
        for (PPPageScrollViewCell * pageCell in _visiblePages) {
            NSInteger index = [_visiblePages indexOfObject:pageCell];
            
            if (NSNotFound != index) {
                index = _visibleIndexes.location + index;
                [self _setFrameForPage:pageCell atIndex:index];
            }
        }
    }
}

#pragma mark Page Selection

- (PPPageScrollViewCell *)pageAtIndex:(NSInteger)index {
    if (NSNotFound == index                 ||
        index < _visibleIndexes.location    ||
        index > _visibleIndexes.location + _visibleIndexes.length - 1) {
        return nil;
    }
    
    return [_visiblePages objectAtIndex:(index - _visibleIndexes.location)];
}

- (NSInteger)indexForSelectedPage {
    return [self indexForVisiblePage:_selectedPageCell];
}

- (NSInteger)indexForVisiblePage:(PPPageScrollViewCell *)pageCell {
    if (!pageCell) {
        return NSNotFound;
    }
    
    NSInteger index = [_visiblePages indexOfObject:pageCell];
    
    if (NSNotFound != index) {
        return _visibleIndexes.location + index;
    }
    
    return NSNotFound;
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (0 <= index && index < _numberOfPages) {
        CGPoint offset = CGPointMake(index * _scrollView.frame.size.width, 0.0f);
        [_scrollView setContentOffset:offset animated:animated];
    }
}

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (NSNotFound == index || !_numberOfPages) {
        return;
    }
    
    //!!!: Force delegate to inform about page selection change
    if ([self.delegate respondsToSelector:@selector(pageScrollView:willSelectPageAtIndex:)]) {
        [self.delegate pageScrollView:self willSelectPageAtIndex:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(pageScrollView:didSelectPageAtIndex:)]) {
        [self.delegate pageScrollView:self didSelectPageAtIndex:index];
    }
}

- (void)deselectPageAtInex:(NSInteger)index animated:(BOOL)animated {
    NSAssert(NO, @"Not implemented");
}

#pragma mark Data Source

- (PPPageScrollViewCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
    PPPageScrollViewCell * reusablePageCell = nil;
    
    NSArray * reusablePages = [_reusablePages objectForKey:identifier];
    
    if (reusablePages) {
        for (PPPageScrollViewCell * pageCell in reusablePages) {
            if (![_visiblePages containsObject:pageCell]) {
                reusablePageCell = pageCell;
                [pageCell prepareForReuse];
                break;
            }
        }
    }
    
    return reusablePageCell;
}

- (void)reloadData {
    NSInteger selectedIndex = (_selectedPageCell) ? [_visiblePages indexOfObject:_selectedPageCell] : NSNotFound;
    self.numberOfPages = [self.dataSource numberOfPagesInPageScrollView:self];
    
    [_visiblePages makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_visiblePages removeAllObjects];

    
    if (_numberOfPages) {
        //reload visible
        for (NSInteger index = 0; index < _visibleIndexes.length; index++) {
            PPPageScrollViewCell * pageCell = [self _loadPageAtIndex:(_visibleIndexes.location + index) insertIntoVisibleIndex:index];
            [self _addPageToScrollView:pageCell atIndex:(_visibleIndexes.location + index)];
        }
        
        //load any additional views which become visible
        [self _updateVisiblePages];
        
        self.selectedPageCell = [_visiblePages objectAtIndex:((NSNotFound == selectedIndex) ? 0 : selectedIndex)];
    }
    else {
        self.selectedPageCell = nil;
    }
}

- (void)_updateVisiblePages {
    const CGFloat pageWidth = _scrollView.frame.size.width;
    const CGFloat leftOriginX = _scrollView.frame.origin.x - _scrollView.contentOffset.x + _visibleIndexes.location * pageWidth;
    const CGFloat rightOriginX = _scrollView.frame.origin.x - _scrollView.contentOffset.x + (_visibleIndexes.location + _visibleIndexes.length - 1) * pageWidth;
    
    if (0.0f < leftOriginX) {
        //new page is entering the visible range from left
        if (0 < _visibleIndexes.location) {
            _visibleIndexes.length += 1;
            _visibleIndexes.location -= 1;
            
            PPPageScrollViewCell * pageCell = [self _loadPageAtIndex:_visibleIndexes.location insertIntoVisibleIndex:0];
            [self _addPageToScrollView:pageCell atIndex:_visibleIndexes.location];
        }
    }
    else if (leftOriginX < -pageWidth) {
        //left page is exiting the visible range
        PPPageScrollViewCell * pageCell = [_visiblePages objectAtIndex:0];
        [_visiblePages removeObject:pageCell];
        [pageCell removeFromSuperview];
        
        _visibleIndexes.location += 1;
        _visibleIndexes.length -= 1;
    }

    if (rightOriginX > self.frame.size.width) {
        //right page is exiting the visible range
        PPPageScrollViewCell * pageCell = [_visiblePages lastObject];
        [_visiblePages removeObject:pageCell];
        [pageCell removeFromSuperview];
        
        _visibleIndexes.length -= 1;
    }
    else if (rightOriginX + pageWidth < self.frame.size.width) {
        //new page is entering the visible range from right
        if (_visibleIndexes.location + _visibleIndexes.length < _numberOfPages) {
            _visibleIndexes.length += 1;
            
            NSInteger index = _visibleIndexes.location + _visibleIndexes.length - 1;
            PPPageScrollViewCell * pageCell = [self _loadPageAtIndex:index insertIntoVisibleIndex:(_visibleIndexes.length - 1)];
            [self _addPageToScrollView:pageCell atIndex:index];
        }
    }
}

- (PPPageScrollViewCell *)_loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex {
    PPPageScrollViewCell * visiblePageCell = [self.dataSource pageScrollView:self cellForPageAtIndex:index];
    
    if (visiblePageCell.reuseIdentifier) {
        NSMutableArray * reusables = [_reusablePages objectForKey:visiblePageCell.reuseIdentifier];
        
        if (!reusables) {
            reusables = [[NSMutableArray alloc] initWithCapacity:4];
        }

        if (![reusables containsObject:visiblePageCell]) {
            [reusables addObject:visiblePageCell];
        }

        [_reusablePages setObject:reusables forKey:visiblePageCell.reuseIdentifier];
    }
    
    [_visiblePages insertObject:visiblePageCell atIndex:visibleIndex];

    return visiblePageCell;
}

- (void)_addPageToScrollView:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index {
    [self _setFrameForPage:pageCell atIndex:index];
    [_scrollView insertSubview:pageCell atIndex:0];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isPendingScrolledPageUpdateNotification) {
        if ([self.delegate respondsToSelector:@selector(pageScrollView:didScrollToPage:atIndex:)]) {
            NSInteger selectedIndex = [_visiblePages indexOfObject:_selectedPageCell];
            [self.delegate pageScrollView:self didScrollToPage:_selectedPageCell atIndex:selectedIndex];
        }
        
        _isPendingScrolledPageUpdateNotification = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //update visible pages
    [self _updateVisiblePages];
    
    const CGFloat delta = scrollView.contentOffset.x - _selectedPageCell.frame.origin.x;
    BOOL shouldToggle = (fabsf(delta) > scrollView.frame.size.width * 0.5f);
    
    if (shouldToggle && 1 < _visiblePages.count) {
        NSInteger selectedIndex = [_visiblePages indexOfObject:_selectedPageCell];
        BOOL neighborExists = ((0 > delta && 0 < selectedIndex) || (0 < delta && selectedIndex < (_visiblePages.count - 1)));
        
        if (neighborExists) {
            NSInteger neighborPageVisibleIndex = [_visiblePages indexOfObject:_selectedPageCell] + ((0 < delta) ? 1 : -1);
            PPPageScrollViewCell * neighborPageCell = [_visiblePages objectAtIndex:neighborPageVisibleIndex];
            NSInteger neighborIndex = _visibleIndexes.location + neighborPageVisibleIndex;
            
            [self _updateScrolledPage:neighborPageCell atIndex:neighborIndex];
        }
    }
}

- (void)_updateScrolledPage:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index {
    if (pageCell) {
        if ([self.delegate respondsToSelector:@selector(pageScrollView:willScrollToPage:atIndex:)]) {
            [self.delegate pageScrollView:self willScrollToPage:pageCell atIndex:index];
        }
        
        self.selectedPageCell = pageCell;
        
        if (_scrollView.isDragging) {
            _isPendingScrolledPageUpdateNotification = YES;
        }
        else {
            if ([self.delegate respondsToSelector:@selector(pageScrollView:didScrollToPage:atIndex:)]) {
                [self.delegate pageScrollView:self didScrollToPage:pageCell atIndex:index];
            }
            
            _isPendingScrolledPageUpdateNotification = NO;
        }
    }
    else {
        self.selectedPageCell = nil;
    }
}

#pragma mark Tap Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return (!_scrollView.isDecelerating && !_scrollView.isDragging);
}

- (void)_tapGestureRecognizer:(UITapGestureRecognizer *)sender {
    if (_selectedPageCell) {
        NSInteger selectedIndex = [self indexForSelectedPage];
        [self selectPageAtIndex:selectedIndex animated:YES];
    }
}

#pragma mark Private Methods

- (void)_setFrameForPage:(PPPageScrollViewCell *)pageCell atIndex:(NSInteger)index {
    CGRect frame = pageCell.frame;
    frame.origin.x = floorf(index * _scrollView.frame.size.width);
    frame.origin.y = 0.0f;
    frame.size = _scrollView.frame.size;
    pageCell.frame = frame;
}

@end
