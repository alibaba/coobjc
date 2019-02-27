//
//  KM_NSURL+Parameters.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 26/06/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import "NSURL+Parameters.h"


@implementation NSURL (NSURL_Parameters)

+ (NSURL *)URLWithString:(NSString *)urlString additionalParameters:(NSString *)additionalParameters
{
    
    NSURL* url = [NSURL URLWithString:urlString];

    BOOL alreadyHasParameters = url.query.length;
    
    if (alreadyHasParameters)
    {
        urlString = [urlString stringByAppendingString:@"&"];
    }
    else
    {
        urlString = [urlString stringByAppendingString:@"?"];
    }

    urlString = [urlString stringByAppendingString:additionalParameters];

    return [NSURL URLWithString:urlString];
}


@end
