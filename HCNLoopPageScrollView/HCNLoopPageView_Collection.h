//
//  HCNLoopPageView_Collection.h
//  Example
//
//  Created by Nick on 1/15/16.
//  Copyright © 2016 Nick Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCNLoopPageView_Collection;
@protocol HCNLoopPageView_CollectionDelegate <NSObject>

@required
- (NSInteger)numberOfLoopPage:(HCNLoopPageView_Collection*)pView;
/*page之间的间距*/
- (CGFloat)spaceOfLoopPage:(HCNLoopPageView_Collection*)pView;
- (UIView *)loopPage:(HCNLoopPageView_Collection*)pView pageViewForIndex:(NSInteger)index;
@optional
- (void)loopPage:(HCNLoopPageView_Collection*)pView didDisplayPage:(UIView *)cell AtIndex:(NSInteger)index;
- (void)loopPage:(HCNLoopPageView_Collection*)pView didSelectPageAtIndex:(NSInteger)index;
@end

@interface HCNLoopPageView_Collection : UIView
@property (nonatomic, assign) id<HCNLoopPageView_CollectionDelegate> delegate;
@property (nonatomic, readonly, assign) NSInteger pageCount;
@property (nonatomic, assign) BOOL autoPlay;

- (instancetype)initWithDelegate:(id<HCNLoopPageView_CollectionDelegate>)delegate;
- (void)reloadData;
@end
