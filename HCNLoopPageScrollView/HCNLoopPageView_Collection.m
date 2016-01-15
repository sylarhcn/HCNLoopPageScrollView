//
//  HCNLoopPageView_Collection.m
//  Example
//
//  Created by Nick on 1/15/16.
//  Copyright © 2016 Nick Hu. All rights reserved.
//

#import "HCNLoopPageView_Collection.h"
@interface HCNLoopPageView_Collection () <UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {
    NSMutableArray *_viewArray;
    BOOL _isScrolling;
    NSTimer *_autoTimer;
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    UIPageControl *_pageControl;
}
@end

@implementation HCNLoopPageView_Collection
#pragma mark - life cycle

- (void)setup {
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 0;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor lightGrayColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"UICollectionViewCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [self addSubview:_collectionView];
    }
    _collectionView.frame = self.bounds;
    _layout.itemSize = _collectionView.bounds.size;
    _layout.minimumInteritemSpacing = [_delegate spaceOfLoopPage:self];
    _collectionView.collectionViewLayout = _layout;
    
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.pageCount == 0) {
        return;
    }
    
    if (_collectionView.contentOffset.x == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self totalCount]/2 inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self totalCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell"
                                                                           forIndexPath:indexPath];
    /*判断是否是过渡页面*/
    NSUInteger viewIndex;//实际pageView的index
    viewIndex = indexPath.item%self.pageCount;
    UIView *pageView = [_viewArray objectAtIndex:viewIndex];
    if ((NSNull *)pageView == [NSNull null]) {
        pageView = [_delegate loopPage:self pageViewForIndex:viewIndex];
        NSAssert(pageView != nil, @"[loopPage:pageViewForIndex:] can not return nil");
        pageView.frame = cell.bounds;
        [_viewArray replaceObjectAtIndex:viewIndex withObject:pageView];
        [cell addSubview:pageView];
    }
    [pageView removeFromSuperview];
    [cell addSubview:pageView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath  {
//    /*判断是否是过渡页面*/
    NSLog(@"%d",indexPath.item);
    NSIndexPath *toIndex;
    if (indexPath.item == 0) {
        toIndex = [NSIndexPath indexPathForItem:[self totalCount]/2+1 inSection:0];
        [_collectionView scrollToItemAtIndexPath:toIndex
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
        [_collectionView setNeedsLayout];
    } else if (indexPath.item == [self totalCount] - 1) {
        toIndex = [NSIndexPath indexPathForItem:[self totalCount]/2-2 inSection:0];
        [_collectionView scrollToItemAtIndexPath:toIndex
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
                [_collectionView setNeedsLayout];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate loopPage:self didSelectPageAtIndex:indexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    if ([self totalCount] == 0) {
        return;
    }
    
    int itemIndex = (scrollView.contentOffset.x +
                     _collectionView.bounds.size.width * 0.5) / _collectionView.bounds.size.width;
    itemIndex = itemIndex % self.pageCount;
    _pageControl.currentPage = itemIndex;
}

#pragma mark - private function
/**
 *  自动轮播
 */
- (void)autoScrollingRun {
    NSIndexPath *index = [_collectionView indexPathForItemAtPoint:CGPointMake(_collectionView.contentOffset.x, 0)];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index.item+1 inSection:0]
                            atScrollPosition:UICollectionViewScrollPositionNone
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

- (void)setupDataSource {
    if (self.pageCount == 0) {
        return;
    }
    if (_viewArray) {
        [self clearData];
    }
    if (!_viewArray) {
        _viewArray = [@[] mutableCopy];
    }
    
    for (int i = 0; i < self.pageCount; i ++) {
        //用空补足序列
        [_viewArray addObject:[NSNull null]];
    }
    
    _pageControl.numberOfPages = self.pageCount;
    _pageControl.currentPage = 0;
    
    [_collectionView reloadData];
}

#pragma mark - public functinos

- (instancetype)initWithDelegate:(id<HCNLoopPageView_CollectionDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)reloadData {
    [self clearData];
    [self setupDataSource];
}

#pragma mark - setter/getter
- (NSInteger)totalCount {
    return self.pageCount * 2;
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

- (void)setDelegate:(id<HCNLoopPageView_CollectionDelegate>)delegate {
    _delegate = delegate;
    [self setup];
}
@end
