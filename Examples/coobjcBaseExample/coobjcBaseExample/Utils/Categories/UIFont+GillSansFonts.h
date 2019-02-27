//
//  UIFont+GillSansFonts.h
//  BigCentral
//
//  Created by Kevin Mindeguia on 24/06/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (GillSansFonts)

/**
 *  Use this method to load GillSansBold font
 *
 *  @param fontSize The desired font size
 *
 *  @return The loaded font
 */
+ (UIFont *)gillSansBoldFontWithSize:(CGFloat)fontSize;

/**
 *  Use this method to load GillSansMedium font
 *
 *  @param fontSize The desired font size
 *
 *  @return The loaded font
 */
+ (UIFont *)gillSansMediumFontWithSize:(CGFloat)fontSize;

/**
 *  Use this method to load GillSansRegular font
 *
 *  @param fontSize The desired font size
 *
 *  @return The loaded font
 */
+ (UIFont *)gillSansRegularFontWithSize:(CGFloat)fontSize;

/**
 *  Use this method to load GillSansLight font
 *
 *  @param fontSize The desired font size
 *
 *  @return The loaded font
 */
+ (UIFont *)gillSansLightFontWithSize:(CGFloat)fontSize;

@end
