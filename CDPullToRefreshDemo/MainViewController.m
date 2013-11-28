//
//  MainViewController.m
//  CDPullToRefreshDemo
//
//  Created by cDigger on 13-11-23.
//  Copyright (c) 2013年 cDigger. All rights reserved.
//

#import "MainViewController.h"
#import "Pull2RefreshTableView.h"

const NSInteger pull2RefreshHeaderHeight = 65;
const NSInteger pull2RefreshFooterHeight = 50;

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    Pull2RefreshTableView *pull2RefreshTableView;
    
    NSMutableArray        *dataSource;
    BOOL                  reload;
}

@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    pull2RefreshTableView = [[Pull2RefreshTableView alloc] initWithFrame:self.view.bounds showDragRefreshHeader:YES showDragRefreshFooter:NO];
    pull2RefreshTableView.dragHeaderHeight = pull2RefreshHeaderHeight;
    pull2RefreshTableView.dragFooterHeight = pull2RefreshFooterHeight;
    
    __weak MainViewController *vc = self;
    pull2RefreshTableView.dragEndBlock = ^(Pull2RefreshViewType type)
    {
        if (type == kPull2RefreshViewTypeHeader)
        {
            [vc reloadInitDataInOtherThread];
        }
        else
        {
            [vc addMoreDataInOtherThread];
        }
    };
    pull2RefreshTableView.dataSource = self;
    
    [self.view addSubview:pull2RefreshTableView];
    
    [self addMoreData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataSource ? dataSource.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < dataSource.count)
    {
        return [[dataSource objectAtIndex:section] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Row";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - 模拟获取数据
- (void)addMoreDataInOtherThread
{
    [NSThread detachNewThreadSelector:@selector(addMoreData) toTarget:self withObject:nil];
}

- (void)addMoreData
{
    sleep(2);
    
    if (!dataSource)
    {
        dataSource = [NSMutableArray new];
    }
    
    NSArray *moreDataArr = [NSArray arrayWithObjects:@"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", nil];
    [dataSource addObject:moreDataArr];
    
    [pull2RefreshTableView reloadData];
    [pull2RefreshTableView completeDragRefresh];
    
    pull2RefreshTableView.shouldShowDragFooter = YES;
    [pull2RefreshTableView addDragFooterView];
}

- (void)reloadInitDataInOtherThread
{
    [NSThread detachNewThreadSelector:@selector(reloadInitData) toTarget:self withObject:nil];
}

- (void)reloadInitData
{
    sleep(20);
    if (dataSource.count > 0)
    {
        [dataSource removeAllObjects];
    }
    
    NSArray *initDataArr = [NSArray arrayWithObjects:@"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", @"Row", nil];
    [dataSource addObject:initDataArr];
    
    [pull2RefreshTableView reloadData];
    [pull2RefreshTableView completeDragRefresh];
}

@end
