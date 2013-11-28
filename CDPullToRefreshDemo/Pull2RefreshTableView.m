//
//  Pull2RefreshTableView.m
//  CDPullToRefreshDemo
//
//  Created by 乐星宇 on 13-11-23.
//  Copyright (c) 2013年 cDigger. All rights reserved.
//

#import "Pull2RefreshTableView.h"


@implementation Pull2RefreshTableView
{
    Pull2RefreshView *dragHeaderView;
    Pull2RefreshView *dragFooterView;
    
    BOOL headerRefreshing;
    BOOL footerRefreshing;
}

@synthesize shouldShowDragHeader, shouldShowDragFooter, dragHeaderHeight, dragFooterHeight;

- (id)initWithFrame:(CGRect)frame showDragRefreshHeader:(BOOL)showDragRefreshHeader showDragRefreshFooter:(BOOL)showDragRefreshFooter
{
    self = [self initWithFrame:frame];
    if (self)
    {
        self.shouldShowDragHeader = showDragRefreshHeader;
        self.shouldShowDragFooter = showDragRefreshFooter;
        
        if (showDragRefreshHeader)
        {
            [self addDragHeaderView];
        }
        
        if (showDragRefreshFooter)
        {
            [self addDragFooterView];
        }
        
        self.delegate = self;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dragHeaderHeight = 65.f;
        self.dragFooterHeight = 65.f;
    }
    
    return self;
}

- (void)addDragHeaderView
{
    if (self.shouldShowDragHeader && !dragHeaderView)
    {
        CGRect frame = CGRectMake(0, -self.dragHeaderHeight,
                                    self.bounds.size.width, self.dragHeaderHeight);
        dragHeaderView = [[Pull2RefreshView alloc]
                                    initWithFrame:frame type:kPull2RefreshViewTypeHeader];
        [self addSubview:dragHeaderView];
    }
}

- (void)addDragFooterView
{
    if (self.shouldShowDragFooter && !dragFooterView)
    {
        CGFloat height = MAX(self.contentSize.height, self.frame.size.height);
        CGRect frame = CGRectMake(0, height,
                                    self.bounds.size.width, self.dragFooterHeight);
        dragFooterView = [[Pull2RefreshView alloc]
                                    initWithFrame:frame type:kPull2RefreshViewTypeFooter];
        self.tableFooterView = dragFooterView;
    }
}

- (void)removeDragHeaderView
{
    if (dragHeaderView)
    {
        [dragHeaderView removeFromSuperview];
        self.contentInset = UIEdgeInsetsZero;
    }
}

- (void)removeDragFooterView
{
    if (dragFooterView)
    {
        [dragFooterView removeFromSuperview];
        self.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"header:%d", section];
    label.textColor = [UIColor blackColor];
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //按frame.origin.y打印出所有子view
    NSMutableArray *subViews = [tableView.subviews mutableCopy];
    [subViews sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(UIView *subView1, UIView *subView2)
    {
        if (subView1.frame.origin.y > subView2.frame.origin.y)
        {
            return NSOrderedDescending;
        }
        else if (subView1.frame.origin.y < subView2.frame.origin.y)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    
    for (UIView *subView in subViews)
    {
        if (![subView isKindOfClass:[UIImageView class]])
        {
            NSLog(@"%@", subView);
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //added 2013.11.28 动态修改headerView的位置
    if (headerRefreshing)
    {
        if (scrollView.contentOffset.y >= -scrollView.contentInset.top
            && scrollView.contentOffset.y < 0)
        {
            //注意:修改scrollView.contentInset时，若使当前界面显示位置发生变化，会触发scrollViewDidScroll:，从而导致死循环。
            //因此此处scrollView.contentInset.top必须为-scrollView.contentOffset.y
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
        else if (scrollView.contentOffset.y == 0)//到0说明headerView已经在tableView最上方，不需要再修改了
        {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
    
    //other code here...
    
    //拉动足够距离，状态变更为“松开....”
    if (self.shouldShowDragHeader && dragHeaderView)
    {
        if (dragHeaderView.state == kPull2RefreshViewStateDragToRefresh
            && scrollView.contentOffset.y < -self.dragHeaderHeight - 10.f
            && !headerRefreshing
            && !footerRefreshing)
        {
            [dragHeaderView flipImageAnimated:YES];
            [dragHeaderView setState:kPull2RefreshViewStateLooseToRefresh];
        }
    }
    
    if (self.shouldShowDragFooter && dragFooterView)
    {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (dragFooterView.state == kPull2RefreshViewStateDragToRefresh
            && scrollPosition <= self.dragFooterHeight
            && scrollView.contentOffset.y >= 0.f
            && !headerRefreshing
            && !footerRefreshing)
        {
            footerRefreshing = YES;
            [dragFooterView setState:kPull2RefreshViewStateRefreshing];
            //执行数据加载操作
            self.dragEndBlock(kPull2RefreshViewTypeFooter);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //拉动足够距离，松开后，状态变更为“加载中...”
    if (self.shouldShowDragHeader && dragHeaderView)
    {
        if (dragHeaderView.state == kPull2RefreshViewStateLooseToRefresh
            && scrollView.contentOffset.y < -self.dragHeaderHeight - 10.0f
            && !headerRefreshing
            && !footerRefreshing)//每次只允许上拉或者下拉其中一个执行
        {
            headerRefreshing = YES;
            //使refresh panel保持显示
            self.contentInset = UIEdgeInsetsMake(self.dragHeaderHeight, 0, 0, 0);
            [dragHeaderView setState:kPull2RefreshViewStateRefreshing];
        }
    }
    
    //DragFooterView这里不需要做任何事
    
    //执行加载数据操作
    if (headerRefreshing)
    {
        self.dragEndBlock(kPull2RefreshViewTypeHeader);
    }
}

#pragma mark - Other
- (void)completeDragRefresh
{
    Pull2RefreshView *dragView = nil;
    if (headerRefreshing)
    {
        dragView = dragHeaderView;
    }
    else if (footerRefreshing)
    {
        dragView = dragFooterView;
    }
    
    if (dragView)
    {
        //恢复箭头为原始指向，不需要动画效果
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        self.contentInset = UIEdgeInsetsZero;
        [UIView commitAnimations];
        
        [dragView flipImageAnimated:NO];
        [dragView setState:kPull2RefreshViewStateDragToRefresh];
    }
    
    headerRefreshing = NO;
    footerRefreshing = NO;
}


@end
