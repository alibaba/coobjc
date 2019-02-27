//
//  KMBaseSource.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `KMBaseSource` is a base network class providing operation queue management and response parsing tools
 */
@interface KMBaseSource : NSObject

/**
 *  The current operation queue on which a network class instance is running
 */
@property (nonatomic, strong) NSOperationQueue* operationQueue;

/**
 *  Use this method to validate json data.
 *
 *  @param responseData Data received from a network request
 *  @param jsonFile     JSON pattern file to which the received data should conform to
 *
 *  @return `NSDictionary` object
 */
- (NSDictionary * _Nullable)dictionaryFromResponseData:(NSData *)responseData jsonPatternFile:(NSString *)jsonFile;

- (NSDictionary * _Nullable)dictionaryFromResponseObject:(id)responseObject jsonPatternFile:(NSString *)jsonFile;


@end

NS_ASSUME_NONNULL_END
