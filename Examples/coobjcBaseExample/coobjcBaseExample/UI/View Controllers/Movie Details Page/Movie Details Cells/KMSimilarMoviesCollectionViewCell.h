//
//  KMSimilarMoviesCollectionViewCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMSimilarMoviesCollectionViewCell : UICollectionViewCell

/**
 *  The movie's poster image view
 */
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

/**
 *  The cell's background view
 */
@property (weak, nonatomic) IBOutlet UIView *cellBackgroundView;

/**
 *  Call this method to create and configure a `KMSimilarMoviesCollectionViewCell`
 *
 *  @return `KMSimilarMoviesCollectionViewCell` instance
 */
+ (KMSimilarMoviesCollectionViewCell *)similarMoviesCollectionViewCell;

@end
