//
//  KMSourceConfig.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  `KMSourceConfig` provides network classes with host information.
 */
@interface KMSourceConfig : NSObject

/**
 *  Class method returning a `KMSourceConfig` shared instance.
 *
 *  @return `KMSourceConfig` instance
 */
+ (KMSourceConfig *)config;

/**
 *  The current app version
 */
@property (nonatomic, copy, readonly) NSString* version;

/**
 *  The current build version
 */
@property (nonatomic, copy, readonly) NSString* build;

/**
 *  The API host url string
 */
@property (nonatomic, copy, readonly) NSString* hostUrlString;

/**
 *  The API secret key.
 */
@property (nonatomic, copy, readonly) NSString* apiKey;

@end
