//
//  KM_NSDictionary+SafeValues.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 26/06/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `NSDictionary+SafeValues` is a category providing convenient methods for fetching objects safely from a dictionary
 */
@interface NSDictionary (NSDictionary_SafeValues)

/**
 *  Use this method to fetch a string in an `NSDictionary` for a given key
 *
 *  @param key The object's hash key
 *
 *  @return The string found at the specified key
 *
 *  @discussion If string is not found at for the given key, will return an empty string: @""
 *
 */
- (NSString *)safeStringForKey:(id)key;

/**
 *  Use this method to fetch a number in an `NSDictionary` for a given key
 *
 *  @param key The object's hash key
 *
 *  @return The number found at the specified key
 *
 *  @discussion If number is not found at for the given key, will return 0
 *
 */
- (NSNumber *)safeNumberForKey:(id)key;

/**
 *  Use this method to fetch an array in an `NSDictionary` for a given key
 *
 *  @param key The object's hash key
 *
 *  @return The array found at the specified key
 *
 *  @discussion If array is not found at for the given key, will return an empty initialized array
 *
 */
- (NSArray *)safeArrayForKey:(id)key;

/**
 *  Use this method to fetch a dictionary in an `NSDictionary` for a given key
 *
 *  @param key The object's hash key
 *
 *  @return The dictionary found at the specified key
 *
 *  @discussion If dictionary is not found at for the given key, will return an empty initialized dictionary.
 *
 */
- (NSDictionary *)safeDictionaryForKey:(id)key;

@end

NS_ASSUME_NONNULL_END