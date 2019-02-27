//
//  KMScrollingHeaderView.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMScrollingHeaderView;

/**
 *  `KMScrollingHeaderViewDelegate` is a delegate protocol used for notifying its delegate of some events triggered by the `KMScrollingHeaderView`
 */
@protocol KMScrollingHeaderViewDelegate <NSObject>

@required
/**
 *  Asks the delegate to set the header's imageview.
 *
 *  @param scrollingHeaderView A scrolling header view object requesting the imageview.
 *  @param imageView           The scrolling header view's imageview.
 */
- (void)detailsPage:(KMScrollingHeaderView *)scrollingHeaderView headerImageView:(UIImageView *)imageView;

@optional
/**
 *  Notifies the delegate that the header image view was selected
 *
 *  @param scrollingHeaderView A scrolling header view object
 *  @param imageView           The selected image ciew
 */
- (void)detailsPage:(KMScrollingHeaderView *)scrollingHeaderView headerImageViewWasSelected:(UIImageView *)imageView;

@end

/**
 *  `KMScrollingHeaderView` is an easy way to display fancy headers to scrolling content. It uses a UITableView as an easy way to layout the scrolling content.
 */
@interface KMScrollingHeaderView : UIView

/**
*  The height of the header imageView. Default: 375.0f.
*/
@property (nonatomic) CGFloat headerImageViewHeight;

/**
 *  Zoom scaling factor for the header imageView. Default value is 300.0f.
 *
 *  @discussion Increasing the value will dicrease the scaling animation rendering. Decreasing the value will increase the scaling animation rendering.
 */
@property (nonatomic) CGFloat headerImageViewScalingFactor;

/**
 *  The scrolling offset to which the navbarView should start fading.
 *
 *  @discussion If value is image header height, user will have to scroll to the top of the screen to make the nav bar appear. Default value is nav bar's height.
 */
@property (nonatomic) CGFloat navbarViewFadingOffset;

/**
 *  The tableview containing the scrolling data.
 */
@property (nonatomic, strong) UITableView* tableView;

/**
 *  The Navigation Bar view which should be displayed when the scrolling content covers the header.
 */
@property (nonatomic, strong) UIView* navbarView;

/**
 *  The header image view content mode. Defaults to UIViewContentModeScaleAspectFit.
 */
@property (nonatomic) UIViewContentMode headerImageViewContentMode;

/**
 *  The object that acts as the delegate of the scrolling header view.
 */
@property (nonatomic, weak) id<KMScrollingHeaderViewDelegate> delegate;

/**
 *  Reloads the header image view and the scrolling header layout. Also reloads the rows and sections of the table view.
 */
- (void)reloadScrollingHeader;

@end
