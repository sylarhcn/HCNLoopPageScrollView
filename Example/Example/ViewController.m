//
//  ViewController.m
//  Example
//
//  Created by Nick Hu on 15/5/19.
//  Copyright (c) 2015年 Nick Hu. All rights reserved.
//

#import "ViewController.h"
#import "HCNLoopPageView.h"
#import "HCNLoopPageView_Collection.h"
@interface ViewController () <HCNLoopPageScrollViewDelegate,HCNLoopPageView_CollectionDelegate> {
    HCNLoopPageView_Collection *_pageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageView = [[HCNLoopPageView_Collection alloc] initWithFrame:self.view.bounds];
    _pageView.backgroundColor = [UIColor grayColor];
    _pageView.delegate = self;
    _pageView.autoPlay = YES;
    [self.view addSubview:_pageView];
    
}

#pragma mark - HCNLoopPageScrollViewDelegate
- (NSInteger)numberOfLoopPage:(HCNLoopPageView *)pView {
    return 5;
}

- (void)loopPage:(HCNLoopPageView *)pView didDisplayPage:(UIView *)cell AtIndex:(NSInteger)index {
    NSLog(@"didDisplayPageAtIndex : %ld",(long)index);
}

- (CGFloat)spaceOfLoopPage:(HCNLoopPageView *)pView {
    return 0;
}

- (UIView *)loopPage:(HCNLoopPageView *)pView pageViewForIndex:(NSInteger)index {
    UILabel *label = [[UILabel alloc] initWithFrame:pView.bounds];
    label.backgroundColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:32];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"page %ld.",(long)index+1];
    return label;
}

- (void)loopPage:(HCNLoopPageView *)pView didSelectPageAtIndex:(NSInteger)index {
    NSLog(@"didSelectPageAtIndex : %ld",(long)index);
}
@end
