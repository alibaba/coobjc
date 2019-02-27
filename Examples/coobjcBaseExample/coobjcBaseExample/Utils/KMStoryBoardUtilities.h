//
//  StoryBoardUtilities.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 09/02/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/**
 *  `KMStoryBoardUtilities` is a utility class that helps loading view controllers from storyboards
 */
@interface KMStoryBoardUtilities : NSObject

/**
 *  Use this method to load a `UIViewController` from a storyboard
 *
 *  @param storyboardName The storyboard file name
 *  @param class          The view controller's class
 *
 *  @return `UIViewController` instance
 */
+ (UIViewController *)viewControllerForStoryboardName:(NSString *)storyboardName class:(id)class;

@end
