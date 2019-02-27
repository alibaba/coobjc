//
//  KMCellCollectionView.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 02/12/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  `KMIndexedCollectionView` is a subclass of `UICollectionView` which helps using collection views in UITableViewCells
 */
@interface KMIndexedCollectionView : UICollectionView

/**
 *  The `UITableViewCell` indexPath.row in which the collection view is nested in.
 */
@property (nonatomic, assign) NSInteger index;

@end
