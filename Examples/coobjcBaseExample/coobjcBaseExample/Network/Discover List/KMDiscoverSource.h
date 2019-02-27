//
//  KMDiscoverMapSource.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//


#import "KMBaseSource.h"
#import "DataService.h"


NS_ASSUME_NONNULL_BEGIN

/**
 *  `KMDiscoverListCompletionBlock` is a completion handler block for the `KMDiscoverSource`
 *
 *  @param dataArray   An array of `KMMovie` objects
 *  @param errorString An error string
 */
typedef void (^KMDiscoverListCompletionBlock)(NSArray* _Nullable dataArray, NSString* _Nullable errorString);

/**
 *  `KMDiscoverSource` is a networking class which can be used to request a list of popular movies to discover.
 */
@interface KMDiscoverSource : KMBaseSource

/**
 *  Class method returning a `KMDiscoverSource` shared instance.
 *
 *  @return `KMDiscoverSource` instance
 */
+ (KMDiscoverSource *)discoverSource;

/**
 *  Use this method to perform a GET request and fetch a list of popular movies to discover.
 *
 *  @param pageLimit       The number of movie pages you would like the API to return
 *  @param completionBlock A block object to be executed when the request operation finishes. This block has no return value and takes two arguments: a collection of movies, and the error string in case of a request failure
 */
- (NSArray*)getDiscoverList:(NSString *)pageLimit CO_ASYNC;

@end

NS_ASSUME_NONNULL_END
