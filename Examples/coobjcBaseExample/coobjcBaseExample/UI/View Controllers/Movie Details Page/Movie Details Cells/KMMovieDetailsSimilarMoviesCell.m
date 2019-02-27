//
//  KMPhotoTimelineContributionsCell.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovieDetailsSimilarMoviesCell.h"

@implementation KMMovieDetailsSimilarMoviesCell

#pragma mark - Cell Init Methods

+ (KMMovieDetailsSimilarMoviesCell *)movieDetailsSimilarMoviesCell
{
    KMMovieDetailsSimilarMoviesCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"KMMovieDetailsSimilarMoviesCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - CollectionView Datasource Setup

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    UINib *nib = [UINib nibWithNibName:@"KMSimilarMoviesCollectionViewCell" bundle: nil];
    
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"KMSimilarMoviesCollectionViewCell"];
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.index = index;
    
    [self.collectionView reloadData];
}

@end
