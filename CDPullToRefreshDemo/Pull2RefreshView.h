//
//  Pull2RefreshView.h
//  CDPullToRefreshDemo
//
//  Created by 乐星宇 on 13-11-23.
//  Copyright (c) 2013年 cDigger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    kPull2RefreshViewTypeHeader,
    kPull2RefreshViewTypeFooter
}Pull2RefreshViewType;

typedef enum
{
    kPull2RefreshViewStateDragToRefresh,      //下拉可以刷新
    kPull2RefreshViewStateLooseToRefresh,     //松开立即刷新
    kPull2RefreshViewStateRefreshing          //加载中...
}Pull2RefreshViewState;


@interface Pull2RefreshView : UIView

@property (nonatomic, assign) Pull2RefreshViewState state;

- (id)initWithFrame:(CGRect)frame type:(Pull2RefreshViewType)type;

- (void)flipImageAnimated:(BOOL)animated;
- (void)setCurrentDate;


@end
