//
//  KMRelatedMoviesSource.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMSimilarMoviesSource.h"
#import "KMSourceConfig.h"
#import "DataService.h"
#import "KMMovie.h"

#define kSimilarMoviesUrlFormat @"%@/movie/%@/similar?api_key=%@"

@implementation KMSimilarMoviesSource

#pragma mark - Init Methods

+ (KMSimilarMoviesSource *)similarMoviesSource
{
    static dispatch_once_t onceToken;
    static KMSimilarMoviesSource* instance = nil;

    dispatch_once(&onceToken, ^{
        instance = [[KMSimilarMoviesSource alloc] init];
    });
    return instance;
}

#pragma mark - Request Methods

- (NSArray*)getSimilarMovies:(NSString *)movieId numberOfPages:(NSString *)numberOfPages
{
    NSString *url = [NSString stringWithFormat:@"%@&page=%@", [self prepareUrl:movieId], numberOfPages];
    id json = [[DataService sharedInstance] requestJSONWithURL:url];
    NSDictionary* infosDictionary = [self dictionaryFromResponseObject:json jsonPatternFile:@"KMSimilarMoviesSourceJsonPattern.json"];
    return [self processResponseObject:infosDictionary];
}

#pragma mark - Data Parsing

- (NSArray *)processResponseObject:(NSDictionary *)data
{
    if (data)
    {
        NSArray* itemsList = [NSArray arrayWithArray:[data objectForKey:@"results"]];
        NSMutableArray* sortedArray = [[NSMutableArray alloc] init];

        for (NSDictionary* item in itemsList)
        {
            KMMovie* movie = [[KMMovie alloc] initWithDictionary:item];
            [sortedArray addObject:movie];
        }

        return sortedArray;
    }

    return nil;
}


#pragma mark - Private

- (NSString *)prepareUrl:(NSString *)movieId
{
    return [NSString stringWithFormat:kSimilarMoviesUrlFormat, [KMSourceConfig config].hostUrlString, movieId, [KMSourceConfig config].apiKey];
}

@end
