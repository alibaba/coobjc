//
//  KMPhotoTimelineDetailsCell.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovieDetailsCell.h"

@implementation KMMovieDetailsCell

#pragma mark - Init Methods

+ (KMMovieDetailsCell *)movieDetailsCell
{
    KMMovieDetailsCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"KMMovieDetailsCell" owner:self options:nil] objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    self.posterImageView.layer.cornerRadius = self.posterImageView.frame.size.width/2;
    self.posterImageView.layer.masksToBounds = YES;
    
    self.watchTrailerButton.layer.borderColor = [UIColor colorWithRed:0/255.0 green:161/225.0 blue:0/255.0 alpha:1.0].CGColor;
    self.watchTrailerButton.layer.cornerRadius = 15.0f;
    
//    self.bookmarkButton.layer.borderColor =  self.bookmarkButton.titleLabel.textColor.CGColor;
//    self.bookmarkButton.layer.borderWidth = 1.0f;
//    self.bookmarkButton.layer.cornerRadius = 15.0f;
    
    [super awakeFromNib];
}

@end

