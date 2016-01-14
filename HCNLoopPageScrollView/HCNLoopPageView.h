//
//  Created by Nick Hu on 9/23/14.
//  Copyright (c) 2014 Nick Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCNLoopPageView;
@protocol HCNLoopPageScrollViewDelegate <NSObject>

@required
- (NSInteger)numberOfLoopPage:(HCNLoopPageView*)pView;
/*page之间的间距*/
- (CGFloat)spaceOfLoopPage:(HCNLoopPageView*)pView;
- (UIView *)loopPage:(HCNLoopPageView*)pView pageViewForIndex:(NSInteger)index;
@optional
- (void)loopPage:(HCNLoopPageView*)pView didDisplayPage:(UIView *)cell AtIndex:(NSInteger)index;
- (void)loopPage:(HCNLoopPageView*)pView didSelectPageAtIndex:(NSInteger)index;
@end

@interface HCNLoopPageView : UIView
@property (nonatomic, assign) id<HCNLoopPageScrollViewDelegate> delegate;
@property (nonatomic, readonly, assign) NSInteger pageCount;
@property (nonatomic, assign) BOOL autoPlay;

- (instancetype)initWithDelegate:(id<HCNLoopPageScrollViewDelegate>)delegate;
- (void)reloadData;
@end
