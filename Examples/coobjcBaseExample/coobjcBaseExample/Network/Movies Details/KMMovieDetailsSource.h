//
//  KMMovieDetailsSource.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMBaseSource.h"
#import "DataService.h"

@class KMMovie;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `KMMovieDetailsCompletionBlock` is a completion handler block for the `KMMovieDetailsSource`
 *
 *  @param movieDetails `KMMovie` object containing movie data
 *  @param errorString  An error string
 *
 *  @see `KMMovieDetailsSource`
 */
//typedef void (^KMMovieDetailsCompletionBlock)(KMMovie* _Nullable movieDetails,  NSString* _Nullable  errorString);

/**
 *  `KMMovieDetailsSource` is a network class which can be used to fetch further details for a movie.
 */
@interface KMMovieDetailsSource : KMBaseSource

/**
 *  Class method returning a `KMMovieDetailsSource` shared instance.
 *
 *  @return `KMMovieDetailsSource` instance
 */
+ (KMMovieDetailsSource *)movieDetailsSource;

/**
 *  Use this method to perform a GET request and fetch details for a movie.
 *
 *  @param movieId         The movie id
 *  @param completionBlock A block object to be executed when the request operation finishes. This block has no return value and takes two arguments: the movie details, and the error string in case of a request failure.
 */
- (KMMovie*)getMovieDetails:(NSString *)movieId CO_ASYNC;

@end

NS_ASSUME_NONNULL_END
