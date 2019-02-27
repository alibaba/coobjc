//
//  KMMovieDetailsSource.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMMovieDetailsSource.h"
#import "KMSourceConfig.h"
#import "KMMovie.h"

#define kSimilarMoviesUrlFormat @"%@/movie/%@?api_key=%@"

@implementation KMMovieDetailsSource

#pragma mark - Init Methods

+ (KMMovieDetailsSource *)movieDetailsSource
{
    static dispatch_once_t onceToken;
    static KMMovieDetailsSource* instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[KMMovieDetailsSource alloc] init];
    });

    return instance;
}

#pragma mark - Request Methods

- (KMMovie*)getMovieDetails:(NSString *)movieId
{
    NSString *url = [self prepareUrl:movieId];
    id json = [[DataService sharedInstance] requestJSONWithURL:url];
    NSDictionary *infosDictionary = [self dictionaryFromResponseObject:json jsonPatternFile:@"KMMovieDetailsSourceJsonPattern.json"];
    return [self processResponseObject:infosDictionary];
}

#pragma mark - Data Parsing

- (KMMovie *)processResponseObject:(NSDictionary*)data
{
    if (data)
    {
        return [[KMMovie alloc] initWithDictionary:data];
    }
    
    return nil;
}

#pragma mark - Private

- (NSString *)prepareUrl:(NSString *)movieId
{
    return [NSString stringWithFormat:kSimilarMoviesUrlFormat, [KMSourceConfig config].hostUrlString, movieId, [KMSourceConfig config].apiKey];
}

@end
