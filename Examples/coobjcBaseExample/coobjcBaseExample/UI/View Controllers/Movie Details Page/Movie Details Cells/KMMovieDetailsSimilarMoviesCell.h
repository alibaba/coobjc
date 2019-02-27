//
//  KMPhotoTimelineContributionsCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMGillSansLabel.h"
#import "KMIndexedCollectionView.h"

@interface KMMovieDetailsSimilarMoviesCell : UITableViewCell

/**
 *  The similar movies cell collection view
 */
@property (weak, nonatomic) IBOutlet KMIndexedCollectionView *collectionView;

/**
 *  The similar movies action button
 *
 *  @discussion Action button which takes user to `KMSimilarMoviesViewController`
 *
 *  @see `KMSimilarMoviesViewController`
 */
@property (weak, nonatomic) IBOutlet UIButton *viewAllSimilarMoviesButton;

/**
 *  Call this method to create and configure a `KMMovieDetailsSimilarMoviesCell`
 *
 *  @return `KMMovieDetailsSimilarMoviesCell` instance
 */
+ (KMMovieDetailsSimilarMoviesCell *)movieDetailsSimilarMoviesCell;

/**
 *  Use this method to set the collectionView's dataSource and delegate
 *
 *  @param dataSourceDelegate The delegate object to which the collectionView should hold a reference to.
 *  @param index              The indexPath.row of this UITableViewCell in it's tableView.
 */
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
