//
//  KMMovieDetailsViewController.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovieDetailsViewController.h"
#import "KMStoryBoardUtilities.h"
#import "KMMovieDetailsCells.h"
#import "KMMovieDetailsSource.h"
#import "KMSimilarMoviesSource.h"
#import "KMSimilarMoviesViewController.h"
#import "UIImageView+WebCache.h"

@interface KMMovieDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) IBOutlet UIView *networkLoadingContainerView;
@property (weak, nonatomic) IBOutlet KMScrollingHeaderView* scrollingHeaderView;
@property (weak, nonatomic) IBOutlet KMGillSansLightLabel *navBarTitleLabel;

@property (strong, nonatomic) NSMutableArray* similarMoviesDataSource;
@property (strong, nonatomic) KMNetworkLoadingViewController* networkLoadingViewController;
@property (assign) CGPoint scrollViewDragPoint;

@end

@implementation KMMovieDetailsViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavbarButtons];
    [self requestMovieDetails];
    [self setupDetailsPageView];
}

#pragma mark - Setup Methods

- (void)setupDetailsPageView
{
    self.scrollingHeaderView.tableView.dataSource = self;
    self.scrollingHeaderView.tableView.delegate = self;
    self.scrollingHeaderView.delegate = self;
    self.scrollingHeaderView.tableView.separatorColor = [UIColor clearColor];
    self.scrollingHeaderView.headerImageViewContentMode = UIViewContentModeTop;

    [self.scrollingHeaderView reloadScrollingHeader];
}

- (void)setupNavbarButtons
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    
    buttonBack.frame = CGRectMake(10, 31, 22, 22);
    [buttonBack setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(popViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:buttonBack];
    
    self.navBarTitleLabel.text = self.movieDetails.movieTitle;
}

#pragma mark - Container Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:[NSString stringWithFormat:@"%s", class_getName([KMNetworkLoadingViewController class])]])
    {
        self.networkLoadingViewController = segue.destinationViewController;
        self.networkLoadingViewController.delegate = self;
    }
}

#pragma mark -
#pragma mark Network Request Methods

- (void)requestSimilarMovies
{
    co_launch(^{
        NSArray *dataArray = [[KMSimilarMoviesSource similarMoviesSource] getSimilarMovies:self.movieDetails.movieId numberOfPages:@"1"];
        if (dataArray != nil)
        {
            [self processSimilarMoviesData:dataArray];
        }
        else
        {
            [self.networkLoadingViewController showErrorView];
        }
    });
    
}

- (void)requestMovieDetails
{
    co_launch(^{
        KMMovieDetailsSource* source = [KMMovieDetailsSource movieDetailsSource];
        KMMovie *movieDetails = [source getMovieDetails:self.movieDetails.movieId];
        if (movieDetails) {
            [self processMovieDetailsData:movieDetails];
        }
        else{
            [self.networkLoadingViewController showErrorView];
        }
    });
}

#pragma mark - Fetched Data Processing

- (void)processSimilarMoviesData:(NSArray *)data
{
    if ([data count] == 0)
    {
        [self.networkLoadingViewController showNoContentView];
    }
    else
    {
        if (!self.similarMoviesDataSource)
        {
            self.similarMoviesDataSource = [[NSMutableArray alloc] init];
        }
        
        self.similarMoviesDataSource = [NSMutableArray arrayWithArray:data];
        
        [self.scrollingHeaderView reloadScrollingHeader];
        
        [self hideLoadingView];
    }
}

- (void)processMovieDetailsData:(KMMovie *)data
{
    self.movieDetails = data;
    
    [self requestSimilarMovies];
}

#pragma mark - Action Methods

- (void)viewAllSimilarMoviesButtonPressed:(id)sender
{
    KMSimilarMoviesViewController* viewController = (KMSimilarMoviesViewController*)[KMStoryBoardUtilities viewControllerForStoryboardName:@"KMSimilarMoviesStoryboard" class:[KMSimilarMoviesViewController class]];
    
    viewController.moviesDataSource = self.similarMoviesDataSource;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would take care of building the cells.
    UITableViewCell* cell = nil;
    
    switch (indexPath.row)
    {
        case 0:
        {
            KMMovieDetailsCell *detailsCell = [tableView dequeueReusableCellWithIdentifier:@"KMMovieDetailsCell"];
            
            if(detailsCell == nil)
                detailsCell = [KMMovieDetailsCell movieDetailsCell];
            
            [detailsCell.co cancel];
            UIImageView *imageView = detailsCell.posterImageView;
            NSString *url = self.movieDetails.movieThumbnailBackdropImageUrl;
            [imageView setImageWithURL:url];

            detailsCell.movieTitleLabel.text = self.movieDetails.movieTitle;
            detailsCell.genresLabel.text = self.movieDetails.movieGenresString;
            
            cell = detailsCell;
            
            break;
        }
        case 1:
        {
            KMMovieDetailsDescriptionCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"KMMovieDetailsDescriptionCell"];
            
            if(descriptionCell == nil)
                descriptionCell = [KMMovieDetailsDescriptionCell movieDetailsDescriptionCell];
            
            descriptionCell.movieDescriptionLabel.text = self.movieDetails.movieSynopsis;
            
            cell = descriptionCell;
        }
            break;
        case 2:
        {
            KMMovieDetailsSimilarMoviesCell *contributionCell = [tableView dequeueReusableCellWithIdentifier:@"KMMovieDetailsSimilarMoviesCell"];
            
            if(contributionCell == nil)
                contributionCell = [KMMovieDetailsSimilarMoviesCell movieDetailsSimilarMoviesCell];
            
            [contributionCell.viewAllSimilarMoviesButton addTarget:self action:@selector(viewAllSimilarMoviesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = contributionCell;
            
            break;
        }
        case 3:
        {
            KMMovieDetailsCommentsCell *commentsCell = [tableView dequeueReusableCellWithIdentifier:@"KMMovieDetailsCommentsCell"];
            
            if(commentsCell == nil)
                commentsCell = [KMMovieDetailsCommentsCell movieDetailsCommentsCell];
            
            commentsCell.usernameLabel.text = @"Kevin Mindeguia";
            commentsCell.commentLabel.text = @"Macaroon croissant I love tiramisu I love chocolate bar chocolate bar. Cheesecake dessert croissant sweet. Muffin gummies gummies biscuit bear claw. ";
            [commentsCell.cellImageView setImage:[UIImage imageNamed:@"kevin_avatar"]];
            
            cell = commentsCell;
            
            break;
        }
        case 4:
        {
            KMMovieDetailsCommentsCell *commentsCell = [tableView dequeueReusableCellWithIdentifier:@"KMMovieDetailsCommentsCell"];
            
            if(commentsCell == nil)
                commentsCell = [KMMovieDetailsCommentsCell movieDetailsCommentsCell];
            
            commentsCell.usernameLabel.text = @"Andrew Arran";
            commentsCell.commentLabel.text = @"Chocolate bar carrot cake candy canes oat cake dessert. Topping bear claw dragée. Sugar plum jelly cupcake.";
            [commentsCell.cellImageView setImage:[UIImage imageNamed:@"scrat_avatar"]];
            
            cell = commentsCell;
            
            break;
        }
        case 5:
        {
            KMMovieDetailsViewAllCommentsCell *viewAllCommentsCell = [tableView dequeueReusableCellWithIdentifier:@"KMMovieDetailsViewAllCommentsCell"];
            
            if(viewAllCommentsCell == nil)
                viewAllCommentsCell = [KMMovieDetailsViewAllCommentsCell movieDetailsAllCommentsCell];
            
            cell = viewAllCommentsCell;
            
            break;
        }
        case 6:
        {
            KMComposeCommentCell *composeCommentCell = [tableView dequeueReusableCellWithIdentifier:@"KMComposeCommentCell"];
            
            if(composeCommentCell == nil)
                composeCommentCell = [KMComposeCommentCell composeCommentsCell];
            
            cell = composeCommentCell;
            
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if ([cell isKindOfClass:[KMMovieDetailsSimilarMoviesCell class]])
    {
        KMMovieDetailsSimilarMoviesCell* similarMovieCell = (KMMovieDetailsSimilarMoviesCell*)cell;
        
        [similarMovieCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    }
    
    if ([cell isKindOfClass:[KMMovieDetailsCommentsCell class]])
    {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would return the cells' height.
    CGFloat height = 0;
    
    switch (indexPath.row)
    {
        case 0:
        {
            height = 120;
            break;
        }
        case 1:
        {
            height = 119;
            break;
        }
        case 2:
        {
            if ([self.similarMoviesDataSource count] == 0)
            {
                height = 0;
            }
            else
            {
                height = 143;
            }
            break;
        }
        case 5:
        {
            height = 46;
            break;
        }
        case 6:
        {
            height = 62;
            break;
        }
            
        default:
        {
            height = 100;
            break;
        }
    }
    
    return height;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [self.similarMoviesDataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    KMSimilarMoviesCollectionViewCell* cell = (KMSimilarMoviesCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"KMSimilarMoviesCollectionViewCell" forIndexPath:indexPath];
    
    [cell.cellImageView setImageWithURL:[[self.similarMoviesDataSource objectAtIndex:indexPath.row] movieThumbnailPosterImageUrl]];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    KMMovieDetailsViewController* viewController = (KMMovieDetailsViewController*)[KMStoryBoardUtilities viewControllerForStoryboardName:@"KMMovieDetailsStoryboard" class:[KMMovieDetailsViewController class]];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController.movieDetails = [self.similarMoviesDataSource objectAtIndex:indexPath.row];
}

#pragma mark - KMScrollingHeaderViewDelegate

- (void)detailsPage:(KMScrollingHeaderView *)detailsPageView headerImageView:(UIImageView *)imageView
{
    [imageView setImageWithURL:[self.movieDetails movieOriginalBackdropImageUrl]];
}

#pragma mark - KMNetworkLoadingViewController

- (void)hideLoadingView
{
    [UIView transitionWithView:self.view duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        
         [self.networkLoadingContainerView removeFromSuperview];
        
     } completion:^(BOOL finished) {
         
         [self.networkLoadingViewController removeFromParentViewController];
         self.networkLoadingContainerView = nil;
         
     }];
    
    self.scrollingHeaderView.navbarView = self.navigationBarView;
}

#pragma mark - KMNetworkLoadingViewDelegate

- (void)retryRequestButtonWasPressed:(KMNetworkLoadingViewController *)viewController
{
    [self requestSimilarMovies];
    [self requestMovieDetails];
}

@end
