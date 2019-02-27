//
//  KMDetailsPageViewController.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMScrollingHeaderView.h"

/**
 *  Change these values to customize you details page
 *
 *  @define kDefaultImagePagerHeight : The header imageView's height. Increase value to show a bigger image.
 *  @define kDefaultTableViewHeaderMargin : Tableview's header height margin.
 *  @define kDefaultImageScalingFactor : Image view scale factor. Increase value to decrease scaling effect and vice versa.
 *
 */
#define kDefaultImagePagerHeight 375.0f
#define kDefaultTableViewHeaderMargin 95.0f
#define kDefaultImageScalingFactor 450.0f

@interface KMScrollingHeaderView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIButton* imageButton;

@end

@implementation KMScrollingHeaderView

#pragma mark - Init Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _headerImageViewHeight = kDefaultImagePagerHeight;
    _headerImageViewScalingFactor = kDefaultImageScalingFactor;
    _headerImageViewContentMode = UIViewContentModeScaleAspectFit;

    [self setupTableView];
    [self setupTableViewHeader];
    [self setupImageView];

    self.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - View layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _navbarViewFadingOffset = _headerImageViewHeight - (CGRectGetHeight(_navbarView.frame) + kDefaultTableViewHeaderMargin);
    
    if (!self.tableView)
        [self setupTableView];
    
    if (!self.tableView.tableHeaderView)
        [self setupTableViewHeader];
    
    if(!self.imageView)
        [self setupImageView];
    
    [self setupBackgroundColor];

    [self setupImageButton];
    
}

#pragma mark - Setup Methods

- (void)setupTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    void *context = (__bridge void *)self;

    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:context];
    
    [self addSubview:self.tableView];
}

- (void)setupTableViewHeader
{
    CGRect tableHeaderViewFrame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.headerImageViewHeight - kDefaultTableViewHeaderMargin);
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)setupImageButton
{
    if (!self.imageButton)
        self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.headerImageViewHeight)];
    
    [self.imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView.tableHeaderView addSubview:self.imageButton];
}

- (void)setupImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0, self.tableView.frame.size.width, self.headerImageViewHeight)];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = self.headerImageViewContentMode;
    
    [self insertSubview:self.imageView belowSubview:self.tableView];
    
    if ([self.delegate respondsToSelector:@selector(detailsPage:headerImageView:)])
            [self.delegate detailsPage:self headerImageView:self.imageView];

}

- (void)setupBackgroundColor
{
    self.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)setupImageViewGradient
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.imageView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], [(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], nil];
    
    gradientLayer.startPoint = CGPointMake(0.6f, 0.6);
    gradientLayer.endPoint = CGPointMake(0.6f, 1.0f);
    
    self.imageView.layer.mask = gradientLayer;
}

#pragma mark - Data Reload

- (void)reloadScrollingHeader;
{
    if ([self.delegate respondsToSelector:@selector(detailsPage:headerImageView:)])
        [self.delegate detailsPage:self headerImageView:self.imageView];

    [self.tableView reloadData];
}

#pragma mark - Setters

- (void)setNavbarView:(UIView *)navbarView
{
    if (_navbarView == navbarView)
    {
        return;
    }
    _navbarView = navbarView;

    [_navbarView setAlpha:0.0];
    [_navbarView setHidden:YES];
}

- (void)setHeaderImageViewContentMode:(UIViewContentMode)headerImageViewContentMode
{
    if (_headerImageViewContentMode == headerImageViewContentMode)
    {
        return;
    }

    _headerImageViewContentMode = headerImageViewContentMode;

    self.imageView.contentMode = _headerImageViewContentMode;
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != (__bridge void *)self)
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ((object == self.tableView) && ([keyPath isEqualToString:@"contentOffset"] == YES))
    {
        [self scrollViewDidScrollWithOffset:self.tableView.contentOffset.y];
        return;
    }
}

#pragma mark - Action Methods

- (void)imageButtonPressed:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(detailsPage:headerImageViewWasSelected:)])
        [self.delegate detailsPage:self headerImageViewWasSelected:self.imageView];
}

#pragma mark - ScrollView Methods

- (void)scrollViewDidScrollWithOffset:(CGFloat)scrollOffset
{
    CGPoint scrollViewDragPoint = self.tableView.contentOffset;
    
    if (scrollOffset < 0)
    {
        self.imageView.transform = CGAffineTransformMakeScale(1 - (scrollOffset / self.headerImageViewScalingFactor), 1 - (scrollOffset / self.headerImageViewScalingFactor));
    }
    else
    {
        self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }

    [self animateNavigationBar:scrollOffset draggingPoint:scrollViewDragPoint];
}

- (void)animateNavigationBar:(CGFloat)scrollOffset draggingPoint:(CGPoint)scrollViewDragPoint
{
    if(scrollOffset > _navbarViewFadingOffset && _navbarView.alpha == 0.0)
    {
        _navbarView.alpha = 0;
        _navbarView.hidden = NO;

        [UIView animateWithDuration:0.3 animations:^{
            self->_navbarView.alpha = 1;
        }];
    }
    else if(scrollOffset < _navbarViewFadingOffset && _navbarView.alpha == 1.0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self->_navbarView.alpha = 0;
        } completion: ^(BOOL finished) {
            self->_navbarView.hidden = YES;
        }];
    }
}

@end
