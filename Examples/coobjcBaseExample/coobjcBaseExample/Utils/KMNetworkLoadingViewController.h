//
//  KMNetworkLoadingViewController.h
//  BigCentral
//
//  Created by Kevin Mindeguia on 19/11/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMActivityIndicator.h"

@class KMNetworkLoadingViewController;

/**
 *  `KMNetworkLoadingViewDelegate` is a delegate protocol for the `KMNetworkLoadingViewController`
 */
@protocol KMNetworkLoadingViewDelegate <NSObject>

/**
 *  Notifies the delegate that the `KMNetworkLoadingViewController` retry button has been pressed
 */
-(void)retryRequestButtonWasPressed:(KMNetworkLoadingViewController *)viewController;

@end

/**
 *  `KMNetworkLoadingViewController` is a view controller managing network error statuses
 */
@interface KMNetworkLoadingViewController : UIViewController

/**
 *  The object that acts as the delegate of the view controller.
 */
@property (weak, nonatomic) id <KMNetworkLoadingViewDelegate> delegate;

/**
 *  Display the loading view.
 */
- (void)showLoadingView;

/**
 *  Display the no content view
 */
- (void)showNoContentView;

/**
 *  Display the error view.
 */
- (void)showErrorView;


@end
