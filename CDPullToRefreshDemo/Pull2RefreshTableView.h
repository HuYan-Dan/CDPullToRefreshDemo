//
//  Pull2RefreshTableView.h
//  CDPullToRefreshDemo
//
//  Created by 乐星宇 on 13-11-23.
//  Copyright (c) 2013年 cDigger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pull2RefreshView.h"


typedef void(^DragEndBlock)(Pull2RefreshViewType);

@interface Pull2RefreshTableView : UITableView<UIScrollViewDelegate, UITableViewDelegate>

@property (nonatomic, assign) BOOL shouldShowDragHeader;
@property (nonatomic, assign) BOOL shouldShowDragFooter;

@property (nonatomic, assign) CGFloat dragHeaderHeight;
@property (nonatomic, assign) CGFloat dragFooterHeight;

@property (nonatomic, copy) DragEndBlock dragEndBlock;


- (id)initWithFrame:(CGRect)frame showDragRefreshHeader:(BOOL)showDragRefreshHeader showDragRefreshFooter:(BOOL)showDragRefreshFooter;

- (void)addDragHeaderView;
- (void)addDragFooterView;

- (void)removeDragHeaderView;
- (void)removeDragFooterView;

//数据加载（或其他操作）完成后调用，重新隐藏刷新view
- (void)completeDragRefresh;


@end
