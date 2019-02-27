//
//  KMMoviePosterCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 05/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <coobjc/coobjc.h>

/**
 *  `KMMoviePosterCell` is a `UICollectionViewCell` displaying a movie poster image.
 */
@interface KMMoviePosterCell : UICollectionViewCell

/**
 *  The movie poster image view.
 */
@property (weak, nonatomic) IBOutlet UIImageView *moviePosterImageView;
@property (nonatomic, strong) COCoroutine *co;

@end
