//
//  StoryBoardUtilities.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 09/02/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import "KMStoryBoardUtilities.h"

@implementation KMStoryBoardUtilities

+ (UIViewController*)viewControllerForStoryboardName:(NSString*)storyboardName class:(id)class
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    NSString* className = nil;
    
    if ([class isKindOfClass:[NSString class]])
        className = [NSString stringWithFormat:@"%@", class];
    else
        className = [NSString stringWithFormat:@"%s", class_getName([class class])];
    
    UIViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@", className]];
    
    return viewController;
}

@end
