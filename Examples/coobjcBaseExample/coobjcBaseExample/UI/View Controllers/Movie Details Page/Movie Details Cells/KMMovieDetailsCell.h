//
//  KMPhotoTimelineDetailsCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMGillSansLabel.h"
#import <coobjc/coobjc.h>

@interface KMMovieDetailsCell : UITableViewCell

@property (nonatomic, strong) COCoroutine *co;

/**
 *  The movie poster image view
 */
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;

/**
 *  The movie title label
 */
@property (weak, nonatomic) IBOutlet KMGillSansLightLabel *movieTitleLabel;

/**
 *  The movie genre label
 */
@property (weak, nonatomic) IBOutlet UILabel *genresLabel;

/**
 *  The watch trailer button
 */
@property (weak, nonatomic) IBOutlet UIButton *watchTrailerButton;

/**
 *  The bookmark action button
 */
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;

/**
 *  Call this method to create and configure a `KMMovieDetailsCell`
 *
 *  @return `KMMovieDetailsCell` instance
 */
+ (KMMovieDetailsCell *)movieDetailsCell;

@end
