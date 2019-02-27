//
//  KMPhotoTimelineCommentsCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMMovieDetailsCommentsCell : UITableViewCell

/**
 *  The user name label
 */
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

/**
 *  The comment label
 */
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

/**
 *  The user avatar image view
 */
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

/**
 *  Call this method to create and configure a `KMMovieDetailsCommentsCell`
 *
 *  @return `KMMovieDetailsCommentsCell` instance
 */
+ (KMMovieDetailsCommentsCell *)movieDetailsCommentsCell;

@end
