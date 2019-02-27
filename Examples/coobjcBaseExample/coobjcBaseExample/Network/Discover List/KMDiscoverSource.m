//
//  KMDiscoverMapSource.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMDiscoverSource.h"
#import "KMSourceConfig.h"
#import "KMMovie.h"

#define kDiscoverUrlFormat @"%@/discover/movie?api_key=%@&sort_by=popularity.desc"

@implementation KMDiscoverSource

#pragma mark - Init Methods

+ (KMDiscoverSource *)discoverSource;
{
    static dispatch_once_t onceToken;
    static KMDiscoverSource* instance = nil;

    dispatch_once(&onceToken, ^{
        instance = [[KMDiscoverSource alloc] init];
    });
    return instance;
}

#pragma mark - Request Methods

- (NSArray*)getDiscoverList:(NSString *)pageLimit;
{
    NSString *url = [NSString stringWithFormat:@"%@&page=%@", [self prepareUrl], pageLimit];
    id json = [[DataService sharedInstance] requestJSONWithURL:url];
    NSDictionary* infosDictionary = [self dictionaryFromResponseObject:json jsonPatternFile:@"KMDiscoverSourceJsonPattern.json"];
    return [self processResponseObject:infosDictionary];
}

#pragma mark - Data Parsing

- (NSArray *)processResponseObject:(NSDictionary*)data
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

- (NSString *)prepareUrl
{
    return [NSString stringWithFormat:kDiscoverUrlFormat, [KMSourceConfig config].hostUrlString, [KMSourceConfig config].apiKey];
}

@end
