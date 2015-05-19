//
//  ViewController.m
//  Example
//
//  Created by Nick Hu on 15/5/19.
//  Copyright (c) 2015年 Nick Hu. All rights reserved.
//

#import "ViewController.h"
#import "HCNLoopPageScrollView.h"

@interface ViewController ()
{
    HCNLoopPageScrollView *_pageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageView = [[HCNLoopPageScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [_pageView setLoadPageBlock:^(NSInteger pageIndex, UIView *contentView) {
        contentView.backgroundColor = [UIColor redColor];
        UILabel *label = (UILabel *)[contentView viewWithTag:99];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:contentView.bounds];
            label.font = [UIFont systemFontOfSize:32];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 99;
            [contentView addSubview:label];
        }
        NSString *pageName = [NSString stringWithFormat:@"page %ld.",(long)pageIndex+1];
        label.text = pageName;
    }];
    [_pageView setDidSelectPageBlock:^(NSInteger pageIndex, UIView *pageView) {
        NSLog(@"SelectPage %ld",(long)pageIndex);
    }];
    [_pageView setPageCount:6];
//    [_pageView setAutoSrcoll:YES];
    
    [self.view addSubview:_pageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
