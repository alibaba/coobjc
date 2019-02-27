//
//  KMMoviesCollectionViewController.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 05/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMSimilarMoviesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

/**
 *  The collection of `KMMovie` objects to be displayed as similar movies.
 */
@property (strong, nonatomic) NSArray* moviesDataSource;

@end
