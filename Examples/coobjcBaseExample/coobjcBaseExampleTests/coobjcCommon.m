//
//  coobjcCommon.m
//  coobjcBaseExampleTests
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

#import "coobjcCommon.h"
#import "co_queue.h"

#include <sys/stat.h>

static dispatch_queue_t CODefaultIOQueue() {
    static dispatch_queue_t pipeQ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pipeQ = dispatch_queue_create("cco.IOQueue",NULL);
    });
    return pipeQ;
}

@implementation NSData (asyncio)

+ (COChan *)co_dataWithContentOfFile:(NSString *)filePath {
    
    dispatch_queue_t pipe_q = CODefaultIOQueue();
    const char *filePathCStr = [filePath fileSystemRepresentation];
    
    int fd = open(filePathCStr, O_RDONLY | O_NONBLOCK, S_IRUSR);
    if (fd == -1) {
        return nil;
    }
    
    COChan *chan = [COChan chan];
    
    dispatch_io_t pipe_channel = dispatch_io_create(DISPATCH_IO_STREAM,fd,pipe_q,^(int err){
        close(fd);
    });
    
    dispatch_io_set_low_water(pipe_channel,SIZE_MAX);
    
    dispatch_io_read(pipe_channel,0,SIZE_MAX,pipe_q, ^(bool done,dispatch_data_t pipe_data,int err){
        if (done) {
            [chan send_nonblock:@"sdfadsf"];
        }
    });
    return chan;
}

- (COChan *)co_writeToFile:(NSString*)filePath{
    dispatch_queue_t pipe_q = CODefaultIOQueue();
    const char *filePathCStr = [filePath fileSystemRepresentation];
    
    int fd = open(filePathCStr, O_CREAT | O_TRUNC, S_IRUSR);
    if (fd == -1) {
        return nil;
    }
    
    COChan *chan = [COChan chan];
    
    dispatch_io_t pipe_channel = dispatch_io_create(DISPATCH_IO_STREAM,fd,pipe_q,^(int err){
        close(fd);
    });
    
    dispatch_io_set_low_water(pipe_channel,SIZE_MAX);
    
    dispatch_data_t data = dispatch_data_create(self.bytes, self.length, pipe_q, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
    dispatch_queue_t curQueue = co_get_current_queue();
    NSUInteger size = self.length;
    dispatch_io_write(pipe_channel, 0, data, pipe_q, ^(bool done, dispatch_data_t  _Nullable data, int error) {
        if (error) {
            dispatch_async(curQueue, ^{
                [chan send:@(0)];
            });
        }
        else{
            if (done) {
                dispatch_async(curQueue, ^{
                    [chan send:@(size)];
                });
            }
        }

    });

    return chan;
}

+ (COChan *)co_downloadWithURL:(NSString*)url{
    dispatch_queue_t curQueue = co_get_current_queue();

    COChan *chan = [COChan chan];
    [NSURLSession sharedSession].configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:url] completionHandler:
                                      ^(NSURL *location, NSURLResponse *response, NSError *error) {
                                          if (error) {
                                              dispatch_async(curQueue, ^{
                                                  [chan send_nonblock:error];
                                              });
                                              return;
                                          }
                                          else{
                                              NSData *data = [[NSData alloc] initWithContentsOfURL:location];

                                              dispatch_async(curQueue, ^{
                                                  [chan send_nonblock:data];
                                              });
                                              return;
                                          }
                                      }];
    
    [task resume];
    
    
    
    return chan;
}


@end
