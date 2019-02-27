//
//  KMSourceConfig.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "KMSourceConfig.h"
#import "NSDictionary+SafeValues.h"

#define kConfigVersionKey @"version"
#define kConfigBuildKey @"build"
#define kConfigTheMovieDbHostKey @"themoviedb_host"
#define kConfigApiKey @"api_key"

@implementation KMSourceConfig

#pragma mark - Init Methods

+ (KMSourceConfig *)config
{
    static dispatch_once_t onceToken;
    static KMSourceConfig* instance = nil;

    dispatch_once(&onceToken, ^{
        instance = [[KMSourceConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        NSBundle* bundle = [NSBundle bundleForClass:[self class]];
        NSDictionary* config = [[NSDictionary alloc]initWithContentsOfFile:[bundle pathForResource:@"KMSourceConfig" ofType:@"plist"]];

        _hostUrlString = [config safeStringForKey:kConfigTheMovieDbHostKey];
        _version = [config safeStringForKey:kConfigVersionKey];
        _build = [config safeStringForKey:kConfigBuildKey];
        _apiKey = [config safeStringForKey:kConfigApiKey];
    }
    
    return self;
}

@end
