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
        size.width = self.width * (count + 2);//增加两个page的宽度用于头尾连接过渡
        _scrollView.contentSize = size;
        
        [self loadPageWithPageIndex:0];
        [self loadPageWithPageIndex:2];
        [self loadPageWithPageIndex:1];
        _scrollView.contentOffset = CGPointMake(self.width, 0);
    }
}

- (void)setLoadPageBlock:(PageBlock)block {
    _loadPageBlock = [block copy];
}

- (void)setDidSelectPageBlock:(PageBlock)block {
    _selectPageBlock = [block copy];
}

#pragma mark - actions
- (void)didTappedInContainer {
    if (_selectPageBlock) {
        _selectPageBlock(_pageControl.currentPage,_viewArray[_pageControl.currentPage]);
    }
}

#pragma mark - functions
- (void)autoScrollingRun {
    CGFloat pageWidth = self.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_scrollView setContentOffset:CGPointMake(pageWidth * (page + 1),0)
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
        //只创建count个page，头尾衔接的page由头尾page互相移动位置实现
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
            _loadPageBlock(viewIndex,imageView);//inital
        }
    } else if ( page <= 1 || page >= numberOfPages ) {
        // 移动page到过渡页面的位置
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        imageView.frame = frame;
    }
    if (_pageControl.currentPage == viewIndex) {
        _loadPageBlock(viewIndex,imageView);//reload
    }
}


- (void)loopPage {
//    NSLog(@"loopPage");
    CGFloat pageWidth = self.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    /*翻页到了队列两头衔接的页面，头尾相接，设置offset到正确的页面的位置，
     set contentOffset 之后才会触发一发一次didScroll,*/
    if(page == 0){
        /**/
        _scrollView.contentOffset = CGPointMake(pageWidth * (_pageControl.numberOfPages), 0);
    } else if(page == _pageControl.numberOfPages + 1){
        _scrollView.contentOffset = CGPointMake(pageWidth, 0);
    }
}

- (void)needLoadPage:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSInteger currentPage = page - 1;
//    NSLog(@"%ld,%d",(long)_pageControl.currentPage,page-1);
    /*正常滑动时，翻页到了队列两头衔接的页面，翻页没有完成，
     此时的currentPage不发生改变，等到翻页完成，offset衔接上了，
     再改变currentpage，reloadPage*/
    if (currentPage == _pageControl.numberOfPages) {
        currentPage = _pageControl.numberOfPages - 1 ;
    } else if (currentPage == -1) {
        currentPage = 0;
    }
    if (_pageControl.currentPage != currentPage) {
        _pageControl.currentPage = currentPage;
//        NSLog(@"load page");
        [self loadPageWithPageIndex:page-1];
        [self loadPageWithPageIndex:page];//
        [self loadPageWithPageIndex:page+1];
    }
}
#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self needLoadPage:scrollView];
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
