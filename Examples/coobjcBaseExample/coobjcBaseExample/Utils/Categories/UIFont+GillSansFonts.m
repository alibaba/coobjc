//
//  UIFont+GillSansFonts.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 24/06/2013.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "UIFont+GillSansFonts.h"

@implementation UIFont (RotoboFonts)

+ (UIFont *)gillSansBoldFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"GillSans-Bold" size:fontSize];
}

+ (UIFont *)gillSansMediumFontWithSize:(CGFloat)fontSize
{
    return  [UIFont fontWithName:@"GillSans-Medium" size:fontSize];
}

+ (UIFont *)gillSansRegularFontWithSize:(CGFloat)fontSize
{
    return  [UIFont fontWithName:@"GillSans-Regular" size:fontSize];
}

+ (UIFont *)gillSansLightFontWithSize:(CGFloat)fontSize
{
    return  [UIFont fontWithName:@"GillSans-Light" size:fontSize];
}

@end
