//
//  DataService.m
//  coobjcBaseExample
//
//  Copyright © 2018 Alibaba Group Holding Limited All rights reserved.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

#import "DataService.h"
#import <CommonCrypto/CommonDigest.h>


@interface DataService ()

@property (nonatomic, strong) dispatch_queue_t jsonQueue;
@property (nonatomic, strong) dispatch_queue_t networkQueue;
@property (nonatomic, strong) dispatch_queue_t cacheQueue;
@property (nonatomic, strong) dispatch_queue_t imageQueue;
@property (nonatomic, strong) COActor *networkActor;
@property (nonatomic, strong) COActor *jsonActor;
@property (nonatomic, strong) COActor *imageActor;
@property (nonatomic, strong) COActor *cacheActor;
@property (nonatomic, strong) NSString *cachePath;

@end

@implementation DataService

+ (instancetype)sharedInstance{
    static DataService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataService alloc] init];
    });
    return instance;
}



- (NSString*)cachePathForFileName:(NSString*)name{
    return [self.cachePath stringByAppendingPathComponent:name];
}

- (COPromise*)_getDataWithURL:(NSString*)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [NSURLSession sharedSession].configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                reject(error);
            }
            else{
                resolve(data);
            }
        }];
        [task resume];
    } onQueue:_networkQueue];
    
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cachePath = [paths[0] stringByAppendingPathComponent:@"coobjc_cache"];
        _networkQueue = dispatch_queue_create("com.coobjc.network", NULL);
        _jsonQueue = dispatch_queue_create("com.coobjc.json", NULL);
        _cacheQueue = dispatch_queue_create("com.coobjc.cache", NULL);
        _imageQueue = dispatch_queue_create("com.coobjc.image", NULL);
        _networkActor = co_actor_onqueue(_networkQueue, ^(COActorChan *channel) {
            for (COActorMessage *message in channel) {
                NSString *url = [message stringType];
                if (url.length > 0) {
                    message.complete(await([self _getDataWithURL:url]));
                }
                else{
                    message.complete(nil);
                }
            }
        });
        
        _cacheActor = co_actor_onqueue(_cacheQueue, ^(COActorChan *channel) {
            for (COActorMessage *message in channel) {
                NSDictionary *dict = [message dictType];
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"save"]) {
                    NSString *identifier = dict[@"id"];
                    NSData *data = dict[@"data"];
                    NSString *fileName = [self cachedFileNameForKey:identifier];
                    NSString *filePath = [self cachePathForFileName:fileName];
                    if (fileName.length > 0 && data.length > 0) {
                        if (![[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
                            [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath withIntermediateDirectories:NO attributes:nil error:nil];
                        }
                        [data writeToFile:filePath atomically:YES];
                    }
                }
                else if ([type isEqualToString:@"load"]) {
                    NSString *identifier = dict[@"id"];
                    NSString *fileName = [self cachedFileNameForKey:identifier];
                    NSString *filePath = [self cachePathForFileName:fileName];
                    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                    message.complete(data);
                }
                else if([type isEqualToString:@"clean"]){
                    NSString *identifier = dict[@"id"];
                    NSString *fileName = [self cachedFileNameForKey:identifier];
                    NSString *filePath = [self cachePathForFileName:fileName];
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
                else if([type isEqualToString:@"clean_all"]){
                    [[NSFileManager defaultManager] removeItemAtPath:self.cachePath error:nil];
                    [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath withIntermediateDirectories:NO attributes:nil error:nil];
                }
            }
        });
        
        _imageActor = co_actor_onqueue(_imageQueue, ^(COActorChan *channel) {
            NSData *data = nil;
            UIImage *image = nil;
            COActorCompletable *completable = nil;
            NSCache *memoryCache = [[NSCache alloc] init];
            memoryCache.countLimit = 50;
            for (COActorMessage *message in channel) {
                image = nil;
                NSString *url = [message stringType];
                if (url.length > 0) {
                    image = [memoryCache objectForKey:url];
                    if (image) {
                        message.complete(image);
                        continue;
                    }
                    completable = [self.cacheActor sendMessage:@{@"type":@"load", @"id":url}];
                    data = await(completable);
                    if (data) {
                        image = [[UIImage alloc] initWithData:data];
                    }
                    else{
                        completable = [self.networkActor sendMessage:url];
                        data = await(completable);
                        if (data) {
                            image = [[UIImage alloc] initWithData:data];
                        }
                    }
                    message.complete(image);
                    if (image) {
                        [memoryCache setObject:image forKey:url];
                    }
                }
                else{
                    message.complete(nil);
                }
            }
        });
        _jsonActor = co_actor_onqueue(_jsonQueue, ^(COActorChan *channel) {
            NSData *data = nil;
            id json = nil;
            COActorCompletable *completable = nil;
            for (COActorMessage *message in channel) {
                NSString *url = [message stringType];
                json = nil;
                if (url.length > 0) {
                    completable = [self.networkActor sendMessage:url];
                    data = await(completable);
                    if (data) {
                        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    }
                    message.complete(json);
                }
                else{
                    message.complete(nil);
                }
            }
        });
    }
    return self;
}

- (id)requestJSONWithURL:(NSString*)url CO_ASYNC{
    SURE_ASYNC
    return await([self.jsonActor sendMessage:url]);
}

- (void)saveDataToCache:(NSData*)data
         withIdentifier:(NSString*)identifier CO_ASYNC{
    SURE_ASYNC
    NSDictionary *msg = @{@"type":@"save", @"data":data, @"id":identifier};
    await([self.cacheActor sendMessage:msg]);
}

- (NSData*)getDataWithIdentifier:(NSString*)identifier CO_ASYNC{
    SURE_ASYNC
    NSDictionary *msg = @{@"type":@"load",  @"id":identifier};
    return await([self.cacheActor sendMessage:msg]);
}

- (UIImage*)imageWithURL:(NSString*)url CO_ASYNC{
    SURE_ASYNC
    return await([self.imageActor sendMessage:url]);
}

@end
