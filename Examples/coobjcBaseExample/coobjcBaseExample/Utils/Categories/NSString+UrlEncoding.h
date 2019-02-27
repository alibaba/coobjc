//
//  KM_NSString+UrlEncoding.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 26/06/2013.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `NSString+UrlEncoding` is a category adding url encoding to `NSString`
 */
@interface NSString (NSString_UrlEncoding)

/**
 *  Use this method to url encode a string
 *
 *  @return Url encoded string
 */
- (NSString *)urlEncodedString;

@end

NS_ASSUME_NONNULL_END