//
//  Pull2RefreshView.m
//  CDPullToRefreshDemo
//
//  Created by 乐星宇 on 13-11-23.
//  Copyright (c) 2013年 cDigger. All rights reserved.
//

#import "Pull2RefreshView.h"
#import <QuartzCore/QuartzCore.h>

@implementation Pull2RefreshView
{
    UILabel     *hintLabel;
    UILabel     *timeLabel;
    
    UIImageView             *arrowImageView;
    UIActivityIndicatorView *indicatorView;
    
    Pull2RefreshViewType refreshType;
}

@synthesize state;

- (id)initWithFrame:(CGRect)frame  type:(Pull2RefreshViewType)type
{
    self = [super initWithFrame:frame];
    if (self)
    {
        refreshType = type;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        //下拉可以刷新、松开可以刷新、刷新中
        hintLabel = [[UILabel alloc] init];
        hintLabel.autoresizingMask =
                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        hintLabel.font = [UIFont boldSystemFontOfSize:13.f];
        hintLabel.textColor        = [UIColor lightGrayColor];
        hintLabel.backgroundColor  = [UIColor clearColor];
        hintLabel.textAlignment    = NSTextAlignmentCenter;
        [self addSubview:hintLabel];

        //上次刷新时间
        timeLabel = [[UILabel alloc] init];
        timeLabel.autoresizingMask =
                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        timeLabel.font = [UIFont systemFontOfSize:10.f];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:timeLabel];
        
        //指示箭头
        arrowImageView = [[UIImageView alloc] init];
        arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        arrowImageView.image = [UIImage imageNamed:@"arrow_up"];
        [arrowImageView layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
        [self addSubview:arrowImageView];
        
        indicatorView = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.hidesWhenStopped  = YES;
        [self addSubview:indicatorView];
        
        UIImageView *shadowView = [[UIImageView alloc] init];
        [self addSubview:shadowView];
        
        switch (type)
        {
            case kPull2RefreshViewTypeHeader:
            {
                shadowView.image = [UIImage imageNamed:@"shadow_down"];
                shadowView.frame = CGRectMake(0, frame.size.height - 5, frame.size.width, 5);
                
                hintLabel.frame = CGRectMake(0, (frame.size.height - 50.f) / 3,
                                                frame.size.width, 30.f);
                timeLabel.frame = CGRectMake(0, (frame.size.height - 50.f) / 3 + 30.f,
                                                frame.size.width, 20.f);
                
                arrowImageView.frame = CGRectMake(25.f, (frame.size.height - 65.f) / 2,
                                                    23.f, 60.f);
                indicatorView.frame = CGRectMake(25.f, (frame.size.height - 20.0f)/2, 20.0f, 20.f);
            }
                break;
            case kPull2RefreshViewTypeFooter:
            {
                shadowView.image = [UIImage imageNamed:@"shadow_up"];
                shadowView.frame = CGRectMake(0, 0, frame.size.width, 5);
                
                hintLabel.frame = CGRectMake(0, (frame.size.height - 30.f) / 2,
                                                frame.size.width, 30.f);
                timeLabel.frame = CGRectZero;
                
                arrowImageView.frame = CGRectZero;
                indicatorView.frame = CGRectMake(100.f, (frame.size.height - 20.f) / 2,
                                                    20.f, 20.f);
            }
                break;
            default:
                break;
        }
        
        //默认状态
        [self setState:kPull2RefreshViewStateDragToRefresh];
    }
    
    return self;
}

#pragma mark - 设置刷新时间
- (void)setUpdateDate:(NSDate*)newDate
{
	if (newDate)
    {
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		timeLabel.text = [NSString stringWithFormat:@"%@%@", @"更新于:", [formatter stringFromDate:newDate]];
	}
    else
    {
		timeLabel.text = @"从未更新";
	}
}

- (void)setCurrentDate
{
	[self setUpdateDate:[NSDate date]];
}

#pragma mark - 设置状态文本
- (void)setState:(Pull2RefreshViewState)newState
{
    state = newState;
	switch (newState)
    {
		case kPull2RefreshViewStateDragToRefresh:
        {
            switch (refreshType)
            {
                case kPull2RefreshViewTypeHeader:
                    hintLabel.text = @"下拉可以刷新";
                    break;
                case kPull2RefreshViewTypeFooter:
                    hintLabel.text = @"上拉加载更多";
                    break;
            }
            
            [self switchImage:NO];
            [self setCurrentDate];
		}
            break;
			
		case kPull2RefreshViewStateLooseToRefresh:
        {
            switch (refreshType)
            {
                case kPull2RefreshViewTypeHeader:
                    hintLabel.text = @"松开立即更新";
                    break;
                case kPull2RefreshViewTypeFooter:
                    hintLabel.text = @"松开加载更多";
                    break;
            }
            
            [self switchImage:NO];
		}
            break;
			
		case kPull2RefreshViewStateRefreshing:
        {
            hintLabel.text = @"加载中...";
            [self switchImage:YES];
		}
	}
}

#pragma mark - 箭头和加载菊花
- (void)flipImageAnimated:(BOOL)animated
{
    static BOOL isFlipped = NO;
    NSTimeInterval duration = animated ? .18 : 0.0;
    [UIView animateWithDuration:duration
                     animations:^()
    {
        arrowImageView.layer.transform = isFlipped ?
        CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) :
        CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
    }];
	
	isFlipped = !isFlipped;
}

- (void)switchImage:(BOOL)shouldShowIndicator
{
	if (shouldShowIndicator)
    {
		[indicatorView startAnimating];
		arrowImageView.hidden = YES;
	}
    else
    {
		[indicatorView stopAnimating];
		arrowImageView.hidden = NO;
	}
}


@end
