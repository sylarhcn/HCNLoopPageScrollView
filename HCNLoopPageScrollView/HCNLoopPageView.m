//
//  View_BoxGroup.m
//  
//
//  Created by Nick Hu on 9/23/14.
//  Copyright (c) 2014 Nick Hu. All rights reserved.
//

#import "HCNLoopPageView.h"

@interface HCNLoopPageView () <UIScrollViewDelegate> {
    NSMutableArray *_viewArray;
    BOOL _isScrolling;
    CGFloat _pageWidth;
    NSTimer *_autoTimer;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}
@end

@implementation HCNLoopPageView

#pragma mark - life cycle
- (instancetype)initWithDelegate:(id<HCNLoopPageScrollViewDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setup];
}

- (void)setup {
    _pageWidth = self.frame.size.width + [_delegate spaceOfLoopPage:self];
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(didTappedInContainer)];
        [_scrollView addGestureRecognizer:tap];
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _pageWidth, self.frame.size.height);
    self.clipsToBounds = YES;
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        [self addSubview:_pageControl];
    }
    _pageControl.center = CGPointMake(self.frame.size.width/2, 0);
    CGRect frame = _pageControl.frame;
    frame.origin.y = self.frame.size.height - _pageControl.frame.size.height - 25;
    _pageControl.frame = frame;
    
    [self reloadData];
}

#pragma mark - private functions
- (void)pauseTimer {
    if (_autoTimer) {
        [_autoTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)startTimer {
    if (_autoTimer) {
        [_autoTimer performSelector:@selector(setFireDate:)
                         withObject:[NSDate distantPast]
                         afterDelay:5];
    }
}


/**
 *  自动轮播
 */
- (void)autoScrollingRun {
//    _scrollView.userInteractionEnabled = NO;
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_scrollView setContentOffset:CGPointMake(pageWidth * (page + 1),0)
                         animated:YES];
}

/**
 *  清除所有数据
 *
 */
- (void)clearData {
    for (UIView *view in _viewArray) {
        if ((NSNull *)view == [NSNull null]) {
            continue;
        }
        [view removeFromSuperview];
    }
    [_viewArray removeAllObjects];
}

/**
 *  读取位于index处的内容
 *
 *  @param index 根据屏幕位移得到index
 */

- (void)loadPageWithIndex:(NSInteger)index {
    NSUInteger numberOfPages = self.pageCount;
    if (index < 0)
        return;
    if (index >= numberOfPages + 2)
        return;
    
    /*判断是否是过渡页面*/
    NSUInteger viewIndex;//实际pageView的index
    if (index == 0) {
        viewIndex = numberOfPages - 1;
    } else if (index == numberOfPages + 1) {
        viewIndex = 0;
    } else {
        viewIndex = index - 1;
    }
    
    UIView *pageView = [_viewArray objectAtIndex:viewIndex];
    if ((NSNull *)pageView == [NSNull null]) {
        pageView = [_delegate loopPage:self pageViewForIndex:viewIndex];
        NSAssert(pageView != nil, @"[loopPage:pageViewForIndex:] can not return nil");
        CGRect frame = self.frame;
        frame.origin.x = _scrollView.frame.size.width * index;
        frame.origin.y = 0;
        pageView.frame = frame;
        [_scrollView addSubview:pageView];
        [_viewArray replaceObjectAtIndex:viewIndex withObject:pageView];
    }
    if ( index <= 1 || index >= numberOfPages ) {
        // 移动需要重复的过渡view到现在page所在的位置
        CGRect frame = self.frame;
        frame.origin.x = _scrollView.frame.size.width * index;
        frame.origin.y = 0;
        pageView.frame = frame;
    }
    if (_pageControl.currentPage == viewIndex) {
        if ([_delegate respondsToSelector:@selector(loopPage:didDisplayPage:AtIndex:)]) {
            [_delegate loopPage:self didDisplayPage:pageView AtIndex:viewIndex];
        }
    }
}


- (void)paging {
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (_pageControl.currentPage != page - 1) {
        if(page == self.pageCount + 1 || page == 0){
            //头尾相接
            page = page - self.pageCount;
            _scrollView.contentOffset = CGPointMake(pageWidth * abs(page), 0);
            [_scrollView scrollRectToVisible:CGRectMake(pageWidth * abs(page), 0, 1, 1) animated:YES];
            [self loadPageWithIndex:abs(page)];
            [self loadPageWithIndex:abs(page - 1)];
            _pageControl.currentPage = abs(page) - 1;
        } else {
            NSInteger lastPage = _pageControl.currentPage;
            _pageControl.currentPage = page - 1;
            if (_pageControl.currentPage > lastPage && _pageControl.currentPage == self.pageCount - 2) {
                //正常移动到尾部
                [self loadPageWithIndex:page + 1];
                [self loadPageWithIndex:page + 2];
            } else if (_pageControl.currentPage < lastPage && _pageControl.currentPage == 1) {
                //正常移动到头部
                [self loadPageWithIndex:page - 1];
                [self loadPageWithIndex:page - 2];
            }
        }
    }
}

- (void)didTappedInContainer {
    if ([_delegate respondsToSelector:@selector(loopPage:didSelectPageAtIndex:)]) {
        [_delegate loopPage:self didSelectPageAtIndex:_pageControl.currentPage];
    }
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self paging];
    self.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self paging];
}

#pragma mark - public functinos
- (void)reloadData {
    [self clearData];
    [self setPageCount:self.pageCount];
}

#pragma mark - setter/getter
- (void)setPageCount:(NSUInteger)count{
    if (count == 0) {
        return;
    }
    if (_viewArray) {
        [self clearData];
    }
    if (!_viewArray) {
        _viewArray = [@[] mutableCopy];
    }
    
    for (int i = 0; i < count; i ++) {
        //用空补足序列
        [_viewArray addObject:[NSNull null]];
    }
    
    _pageControl.numberOfPages = count;
    _pageControl.currentPage = 0;
    _scrollView.pagingEnabled = YES;
    
    if (count == 1) {
        [self loadPageWithIndex:0];
    } else {
        CGSize size = _scrollView.contentSize;
        //增加两个用于头尾连接过渡
        size.width = _pageWidth * (count + 2);
        
        _scrollView.contentSize = size;
        for (int i = 0; i < count; i++) {
            [self loadPageWithIndex:i];
        }
//        [self loadPageWithIndex:0];
//        [self loadPageWithIndex:2];
//        [self loadPageWithIndex:1];
        _scrollView.contentOffset = CGPointMake(_pageWidth, 0);
    }
}

- (NSInteger)pageCount {
    return [_delegate numberOfLoopPage:self];
}

- (void)setAutoPlay:(BOOL)autoPlay {
    _autoPlay = autoPlay;
    if (_autoPlay) {
        if (self.pageCount == 1) {
            return;//只有一页时不需要timer
        }
        if (!_autoTimer) {
            _autoTimer = [NSTimer timerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(autoScrollingRun)
                                               userInfo:nil
                                                repeats:YES];
            // 只有在App正常状态下才会回调定时器，在应用滚动scrollview等时，会自动切换模式，也就不会回调定时器
            [[NSRunLoop currentRunLoop] addTimer:_autoTimer forMode:NSDefaultRunLoopMode];
        }
    } else {
        [_autoTimer invalidate];
        _autoTimer = nil;
    }
}

- (void)setDelegate:(id<HCNLoopPageScrollViewDelegate>)delegate {
    _delegate = delegate;
    [self setup];
}
@end
