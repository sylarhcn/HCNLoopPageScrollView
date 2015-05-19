//
//  View_BoxGroup.m
//  wolaila
//
//  Created by Nick Hu on 9/23/14.
//  Copyright (c) 2014 Sudiyi. All rights reserved.
//

#import "HCNLoopPageScrollView.h"

@interface HCNLoopPageScrollView () <UIScrollViewDelegate>
{
    NSMutableArray *_viewArray;
    BOOL _isScrolling;
    PageBlock _loadPageBlock;
    PageBlock _selectPageBlock;
    NSTimer *_autoTimer;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}
@end

@implementation HCNLoopPageScrollView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     frame.size.width,
                                                                     frame.size.height)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self
                                                action:@selector(didTappedInContainer)];
        [_scrollView addGestureRecognizer:tap];
        
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.center = CGPointMake(self.center.x,
                                          self.bounds.size.height - _pageControl.bounds.size.height - 20);
        [self addSubview:_scrollView];
        [self addSubview:_pageControl];
    }
    return self;
}

#pragma mark - public functinos
- (void)setAutoSrcoll:(BOOL)isAuto {
    if (isAuto) {
        if (_pageControl.numberOfPages == 1) {
            return;//只有一页时不需要timer
        }
        if (!_autoTimer) {
            _autoTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:self
                                                        selector:@selector(autoScrollingRun)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    } else {
        [_autoTimer invalidate];
        _autoTimer = nil;
    }
}

- (void)setPageCount:(NSUInteger)count{
    NSAssert(count > 0, @"page count can not be 0");
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
        [self loadPageWithPageIndex:0];
    } else {
        CGSize size = _scrollView.contentSize;
        size.width = self.width * (count + 2);//增加两个用于头尾连接过渡
        _scrollView.contentSize = size;
        
        [self loadPageWithPageIndex:0];
        [self loadPageWithPageIndex:1];
        [self loadPageWithPageIndex:2];
        
        _scrollView.contentOffset = CGPointMake(self.width, 0);
    }
}

- (void)setLoadPageBlock:(PageBlock)block {
    _loadPageBlock = [block copy];
}

- (void)setDidSelectPageBlock:(PageBlock)block {
    _selectPageBlock = [block copy];
}

#pragma mark - functions
- (void)autoScrollingRun {
    CGFloat pageWidth = self.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_scrollView setContentOffset:CGPointMake(pageWidth * (page + 1),
                                              0)
                         animated:YES];
}

- (BOOL)clearData {
    for (UIView *view in _viewArray) {
        if ((NSNull *)view == [NSNull null]) {
            continue;
        }
        [view removeFromSuperview];
    }
    [_viewArray removeAllObjects];
    return YES;
}

- (void)loadPageWithPageIndex:(NSInteger)page {
    NSUInteger numberOfPages = _pageControl.numberOfPages;
    if (page < 0)
        return;
    if (page >= numberOfPages + 2)
        return;
    
    NSUInteger viewIndex;
    if (page == 0) {
        viewIndex = numberOfPages - 1;
    } else if (page == numberOfPages + 1) {
        viewIndex = 0;
    } else {
        viewIndex = page - 1;
    }
    
    UIImageView *imageView = [_viewArray objectAtIndex:viewIndex];
    if ((NSNull *)imageView == [NSNull null]) {
        imageView = [[UIImageView alloc] init];
        [_viewArray replaceObjectAtIndex:viewIndex withObject:imageView];
    }
    
    if (imageView.superview == nil) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        imageView.frame = frame;
        [_scrollView addSubview:imageView];
        if (_loadPageBlock) {
            _loadPageBlock(viewIndex,imageView);
        }
    } else if ( page <= 1 || page >= numberOfPages ) {
        // move the controller's view to the correct page if it's a repeated one
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        imageView.frame = frame;
    }
}

- (void)loopPage {
    CGFloat pageWidth = self.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page == 0){
        _scrollView.contentOffset = CGPointMake(pageWidth * (_pageControl.numberOfPages), 0);
    } else if(page == _pageControl.numberOfPages + 1){
        _scrollView.contentOffset = CGPointMake(pageWidth, 0);
    }
}

- (void)didTappedInContainer {
    if (_selectPageBlock) {
        _selectPageBlock(_pageControl.currentPage,_viewArray[_pageControl.currentPage]);
    }
}
#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page - 1;
    
    [self loadPageWithPageIndex:page - 1];
    [self loadPageWithPageIndex:page];
    [self loadPageWithPageIndex:page + 1];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loopPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self loopPage];
}

#pragma mark - getter/setter
- (CGFloat)width
{
    return self.bounds.size.width;
}
@end
