//
//  KMMovieDetailsPopularityCell.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovieDetailsPopularityCell.h"

@implementation KMMovieDetailsPopularityCell

#pragma mark - Cell Init Methods

+ (KMMovieDetailsPopularityCell *)movieDetailsPopularityCell
{
    KMMovieDetailsPopularityCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"KMMovieDetailsPopularityCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
