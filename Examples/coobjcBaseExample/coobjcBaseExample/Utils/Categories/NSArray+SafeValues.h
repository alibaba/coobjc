//
//  NSArray+SafeValues.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `NSArray+SafeValues` is a category providing convenient methods for fetching objects safely from an array
 */
@interface NSArray (NSArray_SafeValues)

/**
 *  Use this method to fetch a string in an `NSArray` at a given index
 *
 *  @param index The object index
 *
 *  @return The string at the specified index
 *
 *  @discussion If string is not found at the given index, will return an empty string: @""
 *
 */
- (NSString *)safeStringAtIndex:(NSUInteger)index;

/**
 *  Use this method to fetch a number in an `NSArray` at a given index
 *
 *  @param index The object index
 *
 *  @return The number at the specified index
 *
 *  @discussion If number is not found at the given index, will return 0
 */
- (NSNumber *)safeNumberAtIndex:(NSUInteger)index;

/**
 *  Use this method to fetch a dictionary in an `NSArray` at a given index
 *
 *  @param index The dictionary at the specified index
 *
 *  @return The dictionary at the specified index
 *
 *  @discussion If number is not found at the given index, will return an empty initialized `NSDictionary`
 */
- (NSDictionary *)safeDictionaryAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END