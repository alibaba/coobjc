//
//  KMComposeCommentCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMComposeCommentCell : UITableViewCell

/**
 *  The compose comment action button.
 */
@property (weak, nonatomic) IBOutlet UIButton *composeCommentButton;

/**
 *  Call this method to create and configure a `KMComposeCommentCell`
 *
 *  @return `KMComposeCommentCell` instance
 */
+ (KMComposeCommentCell *)composeCommentsCell;

@end
