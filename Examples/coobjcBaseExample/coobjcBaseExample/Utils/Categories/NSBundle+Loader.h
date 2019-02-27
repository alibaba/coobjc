//
//  NSBundle+Loader.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 24/06/2013.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Loader)

/**
 *  Use this method to fetch data from a bundled resource file
 *
 *  @param resource Resource file path
 *
 *  @return Fetched data
 */
- (NSData * _Nullable)dataFromResource:(NSString *)resource;

/**
 *  Use this method to fetch json data from a bundled resource file
 *
 *  @param resource Resource file path
 *
 *  @return Fetched JSON data
 */
- (id _Nullable)jsonFromResource:(NSString *)resource;

@end

NS_ASSUME_NONNULL_END
