//
//  KMMoviesCollectionViewController.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 05/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMSimilarMoviesViewController.h"
#import "KMStoryBoardUtilities.h"
#import "KMMovie.h"
#import "KMMoviePosterCell.h"
#import "KMMovieDetailsViewController.h"
#import "UIImageView+WebCache.h"

#define kVerticalMarginForCollectionViewItems 0

@interface KMSimilarMoviesViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;

@end

@implementation KMSimilarMoviesViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)awakeFromNib
{
    if (!self.moviesDataSource)
    {
        self.moviesDataSource = [[NSArray alloc] init];
    }
    
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self setupCollectionViewLayout];
}

#pragma mark - CollectionView Layout

- (void)setupCollectionViewLayout
{
    UICollectionViewFlowLayout* interfaceBuilderFlowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    CGSize viewSize = self.view.bounds.size;
    
    CGFloat cellAspectRatio = interfaceBuilderFlowLayout.itemSize.height / interfaceBuilderFlowLayout.itemSize.width;
    
    UICollectionViewFlowLayout* flowLayoutPort = [UICollectionViewFlowLayout new];
    
    flowLayoutPort.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayoutPort.sectionInset = interfaceBuilderFlowLayout.sectionInset;
    flowLayoutPort.minimumInteritemSpacing = interfaceBuilderFlowLayout.minimumInteritemSpacing;
    flowLayoutPort.minimumLineSpacing = interfaceBuilderFlowLayout.minimumLineSpacing;
    
    if (floor(viewSize.width / interfaceBuilderFlowLayout.itemSize.width) <= 2)
    {
        CGFloat itemHeight = (viewSize.width/2.0 - kVerticalMarginForCollectionViewItems) * cellAspectRatio;
        
        flowLayoutPort.itemSize = CGSizeMake(viewSize.width/2.0 - kVerticalMarginForCollectionViewItems, itemHeight);
        
    }
    else
    {
        CGFloat itemHeight = (viewSize.height/2.0 - kVerticalMarginForCollectionViewItems) * cellAspectRatio;
        
        flowLayoutPort.itemSize = CGSizeMake(viewSize.height/2.0 - kVerticalMarginForCollectionViewItems, itemHeight);
    }
    
    [self.collectionView setCollectionViewLayout:flowLayoutPort];
    
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.moviesDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    KMMoviePosterCell* cell = (KMMoviePosterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"KMMoviePosterCell" forIndexPath:indexPath];
    
    [cell.co cancel];
    UIImageView *imageView = cell.moviePosterImageView;
    [imageView setImageWithURL:[[self.moviesDataSource objectAtIndex:indexPath.row] movieOriginalPosterImageUrl]];

    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    KMMovieDetailsViewController* viewController = (KMMovieDetailsViewController*)[KMStoryBoardUtilities viewControllerForStoryboardName:@"KMMovieDetailsStoryboard" class:[KMMovieDetailsViewController class]];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController.movieDetails = [self.moviesDataSource objectAtIndex:indexPath.row];
}

@end
