//
//  KMActivityIndicator.h
//  
//
//  Created by Kevin Mindeguia on 19/08/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  `KMActivityIndicator` is a fancy activity indicator showing three dots animating.
 */
@interface KMActivityIndicator : UIView

/**
 *  A Boolean value that controls whether the receiver is hidden when the animation is stopped.
 */
@property (nonatomic) BOOL hidesWhenStopped;

/**
 *  The color of the activity indicator.
 */
@property (nonatomic, strong) UIColor *color;

/**
 *  Starts the animation of the activity indicator.
 */
- (void)startAnimating;

/**
 *  Stops the animation of the activity indicator.
 */
- (void)stopAnimating;

/**
 *  Returns whether the receiver is animating.
 *
 *  @return `YES` if the receiver is animating, otherwise `NO`.
 */
- (BOOL)isAnimating;

@end
