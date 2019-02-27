//
//  KMRelatedMoviesSource.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMBaseSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  KMSimilarMoviesCompletionBlock is a completion handler block for the `KMSimilarMoviesSource`
 *
 *  @param dataArray   An array of `KMMovie` objects
 *  @param errorString An error string
 *
 *  @see `KMMovie`
 */
//typedef void (^KMSimilarMoviesCompletionBlock)(NSArray* _Nullable dataArray, NSString* _Nullable errorString);

/**
 *  `KMSimilarMoviesSource` is a networking class which can be used to request movies similar to a movie.
 */
@interface KMSimilarMoviesSource : KMBaseSource

/**
 *  Class method returning a `KMSimilarMoviesSource` shared instance.
 *
 *  @return `KMSimilarMoviesSource` instance
 */
+ (KMSimilarMoviesSource *)similarMoviesSource;

/**
 *  Use this method to perform a GET request and fetch similar movies to a movie.
 *
 *  @param movieId         The movie id
 *  @param numberOfPages   The number of similar movies pages
 *  @param completionBlock A block object to be executed when the request operation finishes. This block has no return value and takes two arguments: a collection of movies, and the error string in case of a request failure.
 */
- (NSArray*)getSimilarMovies:(NSString *)movieId numberOfPages:(NSString *)numberOfPages;

@end

NS_ASSUME_NONNULL_END
