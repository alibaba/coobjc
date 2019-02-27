//
//  KMMovie.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovie.h"
#import "NSDictionary+SafeValues.h"

#define kMovieTitle @"original_title"
#define kMovieId @"id"
#define kMovieYearDate @"year"
#define kMovieSynopsis @"overview"
#define kMovieOriginalPosterImageUrl @"poster_path"
#define kMovieBackdropPosterImageUrl @"backdrop_path"
#define kMovieDetailedPosterImageUrl @"thumbnail"
#define kMoviePosterRelatedMovies @"similar"
#define kMovieGenres @"genres"
#define kMoviePopularity @"popularity"
#define kMovieVoteCount @"vote_count"
#define kMovieVoteAverage @"vote_average"

@implementation KMMovie

#pragma mark -
#pragma mark Init Methods

- (void)initialiseWithSafeValues
{
    _movieId = @"";
    _movieSynopsis = @"";
    _movieYear = @"";
    _movieOriginalPosterImageUrl = @"";
    _movieThumbnailPosterImageUrl = @"";
    _movieOriginalBackdropImageUrl = @"";
    _movieThumbnailBackdropImageUrl = @"";
    _movieGenresString = @"";
    _moviePopularity = @"";
    _movieVoteAverage = @"";
    _movieVoteCount = @"";
    _movieTitle = @"";
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];

    if (self)
    {
        [self initialiseWithSafeValues];
        [self processDictionary:dictionary];
    }
    return self;
}

#pragma mark -
#pragma mark Dictionary Parsing

- (void)processDictionary:(NSDictionary*)dictionary
{
    if (dictionary)
    {
        _movieId = [NSString stringWithFormat:@"%d", [[dictionary safeNumberForKey:kMovieId] intValue]];
        _movieTitle = [dictionary safeStringForKey:kMovieTitle];
        _movieSynopsis = [dictionary safeStringForKey:kMovieSynopsis];

        _movieThumbnailPosterImageUrl = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w92/%@", [dictionary safeStringForKey:kMovieOriginalPosterImageUrl]];
        _movieOriginalBackdropImageUrl = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w780/%@", [dictionary safeStringForKey:kMovieBackdropPosterImageUrl]];
        _movieThumbnailBackdropImageUrl = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w300/%@", [dictionary safeStringForKey:kMovieBackdropPosterImageUrl]];
        _movieOriginalPosterImageUrl = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [dictionary safeStringForKey:kMovieOriginalPosterImageUrl]];

        _movieGenresString = [self processGenresIntoString:[dictionary safeArrayForKey:kMovieGenres]];
        _movieVoteCount = [NSString stringWithFormat:@"%d", [[dictionary safeNumberForKey:kMovieVoteCount] intValue]];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setPositiveFormat:@"#0.0"];
        
        _moviePopularity = [formatter stringFromNumber:[dictionary safeNumberForKey:kMoviePopularity]];
        _movieVoteAverage = [formatter stringFromNumber:[dictionary safeNumberForKey:kMovieVoteAverage]];
        
        if ([_moviePopularity length] >= 2)
        {
            [_moviePopularity substringToIndex:2];
        }
        if ([_movieVoteAverage length] >= 2)
        {
            [_movieVoteAverage substringToIndex:2];
        }
    }
}

- (NSString*)processGenresIntoString:(NSArray*)genres
{
    if ([genres count] == 0)
    {
        return @"";
    }

    NSMutableString* genresString = [[NSMutableString alloc] init];

    for (NSDictionary* genre in genres)
    {
        [genresString appendFormat:@"%@, ", [genre safeStringForKey:@"name"]];
    }
    [genresString replaceCharactersInRange:NSMakeRange([genresString length]-2, 2) withString:@""];

    return genresString;
}

@end
