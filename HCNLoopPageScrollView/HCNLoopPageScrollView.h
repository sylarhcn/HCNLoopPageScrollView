//
//  Created by Nick Hu on 9/23/14.
//  Copyright (c) 2014 Sudiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PageBlock)(NSInteger pageIndex,UIView *pageView);

@interface HCNLoopPageScrollView : UIView
- (void)setPageCount:(NSUInteger)count;
- (void)setLoadPageBlock:(PageBlock)block;
- (void)setDidSelectPageBlock:(PageBlock)block;
- (void)setAutoSrcoll:(BOOL)isAuto;
@end
