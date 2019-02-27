//
//  KMPhotoTimelineCommentsCell.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovieDetailsCommentsCell.h"

@implementation KMMovieDetailsCommentsCell

#pragma mark - Cell Init Methods

+ (KMMovieDetailsCommentsCell *)movieDetailsCommentsCell
{
    KMMovieDetailsCommentsCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"KMMovieDetailsCommentsCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    self.cellImageView.layer.cornerRadius = self.cellImageView.frame.size.width/2;
    self.cellImageView.layer.masksToBounds = YES;
    
    [super awakeFromNib];
}

@end
