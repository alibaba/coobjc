//
//  NSURL+Parameters.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 26/06/2013.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (NSURL_Parameters)

/**
 *  Use this method to append request parameters to an `NSURL`
 *
 *  @param urlString            The existing url string
 *  @param additionalParameters Request parameters to append to existing url
 *
 *  @return A url with appended parameters
 */
+ (NSURL *)URLWithString:(NSString *)urlString additionalParameters:(NSString *)additionalParameters;

@end

NS_ASSUME_NONNULL_END