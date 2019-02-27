//
//  KMPhotoTimelineViewAllCommentsCell.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovieDetailsViewAllCommentsCell.h"

@implementation KMMovieDetailsViewAllCommentsCell

#pragma mark - Cell Init Methods

+ (KMMovieDetailsViewAllCommentsCell *)movieDetailsAllCommentsCell;
{
    KMMovieDetailsViewAllCommentsCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"KMMovieDetailsViewAllCommentsCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
