//
//  KMMovie.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The KMMovie object defines a movie object with its properties
 */
@interface KMMovie : NSObject

/**
 *  The movie's title
 */
@property (nonatomic, copy) NSString* movieTitle;

/**
 *  The movie's id
 */
@property (nonatomic, copy) NSString* movieId;

/**
 *  The movie's synopsis
 */
@property (nonatomic, copy) NSString* movieSynopsis;

/**
 *  The year the movie was released
 */
@property (nonatomic, copy) NSString* movieYear;

/**
 *  The original sized backdrop image url
 */
@property (nonatomic, copy) NSString* movieOriginalBackdropImageUrl;

/**
 *  The original sized poster image url
 */
@property (nonatomic, copy) NSString* movieOriginalPosterImageUrl;

/**
 *  The thumbnail sized poster image url
 */
@property (nonatomic, copy) NSString* movieThumbnailPosterImageUrl;

/**
 *  The thumbnail sized backdrop image url
 */
@property (nonatomic, copy) NSString* movieThumbnailBackdropImageUrl;

/**
 *  The movie's genre
 */
@property (nonatomic, copy) NSString* movieGenresString;

/**
 *  The movie's vote count string
 */
@property (nonatomic, copy) NSString* movieVoteCount;

/**
 *  The movie's vote average score
 */
@property (nonatomic, copy) NSString* movieVoteAverage;

/**
 *  The movie's popularity score
 */
@property (nonatomic, copy) NSString* moviePopularity;

/**
 *  Designated Initializer
 *
 *  @param dictionary The dictionary containing the movie data
 *
 *  @return KMMovie instance
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;

/**
 *  Unavailable, use the designated initializer.
 *
 *  @return nil
 */
+ (instancetype)new __attribute__((unavailable("Use -initWithFontSpecification: instead")));

/**
 *  Unavailable, use the designated initializer.
 *
 *  @return nil
 */
- (instancetype)init __attribute__((unavailable("Use -initWithFontSpecification: instead")));

NS_ASSUME_NONNULL_END

@end
