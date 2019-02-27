//
//  KMMovieDetailsPopularityCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMMovieDetailsPopularityCell : UITableViewCell

/**
 *  The popularity label
 */
@property (weak, nonatomic) IBOutlet UILabel *popularityLabel;

/**
 *  The  vote count label
 */
@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;

/**
 *  The average vote score label
 */
@property (weak, nonatomic) IBOutlet UILabel *voteAverageLabel;

/**
 *  Call this method to create and configure a `KMMovieDetailsPopularityCell`
 *
 *  @return `KMMovieDetailsPopularityCell` instance
 */
+ (KMMovieDetailsPopularityCell *)movieDetailsPopularityCell;

@end
