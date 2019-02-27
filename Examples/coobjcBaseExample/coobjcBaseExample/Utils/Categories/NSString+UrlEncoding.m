//
//  NSString+UrlEncoding.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 26/06/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//


#import "NSString+UrlEncoding.h"

@implementation NSString (NSString_UrlEncoding)

- (NSString *)urlEncodedString
{
    NSString* unEncodedString = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* encodedString = [unEncodedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return encodedString;
}

@end
