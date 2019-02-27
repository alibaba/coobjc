//
//  KMContributionCollectionViewCell.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMSimilarMoviesCollectionViewCell.h"

static CGFloat const kImageViewCornerRadius = 2.0;

@implementation KMSimilarMoviesCollectionViewCell

#pragma mark - Cell Init Methods

+ (KMSimilarMoviesCollectionViewCell *) similarMoviesCollectionViewCell
{
    KMSimilarMoviesCollectionViewCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"KMSimilarMoviesCollectionViewCell" owner:self options:nil] objectAtIndex:0];
    
    return cell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    self.cellImageView.layer.cornerRadius = kImageViewCornerRadius;
    self.cellImageView.layer.masksToBounds = YES;
    
    self.cellBackgroundView.layer.cornerRadius = self.cellImageView.layer.cornerRadius;
    self.cellBackgroundView.layer.masksToBounds = YES;
    self.cellBackgroundView.layer.borderColor =  [UIColor colorWithRed:180/255.0 green:180/225.0 blue:180/255.0 alpha:1.0].CGColor;
    self.cellBackgroundView.layer.borderWidth = 1.0f;
    
    [super awakeFromNib];
}

@end
