//
//  NSUserDefaults+Coroutine.h
//  cokit
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

#import <Foundation/Foundation.h>
#import <coobjc/COPromise.h>
#import <coobjc/coobjc.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSUserDefaults (COPromise)

/*!
 -objectForKey: will search the receiver's search list for a default with the key 'defaultName' and return it. If another process has changed defaults in the search list, NSUserDefaults will automatically update to the latest values. If the key in question has been marked as ubiquitous via a Defaults Configuration File, the latest value may not be immediately available, and the registered value will be returned instead.
 */
- (COPromise<id>*)async_objectForKey:(NSString *)defaultName;

/*!
 -setObject:forKey: immediately stores a value (or removes the value if nil is passed as the value) for the provided key in the search list entry for the receiver's suite name in the current user and any host, then asynchronously stores the value persistently, where it is made available to other processes.
 */
- (COPromise*)async_setObject:(nullable id)value forKey:(NSString *)defaultName;

/// -removeObjectForKey: is equivalent to -[... setObject:nil forKey:defaultName]
- (COPromise*)async_removeObjectForKey:(NSString *)defaultName;

/// -stringForKey: is equivalent to -objectForKey:, except that it will convert NSNumber values to their NSString representation. If a non-string non-number value is found, nil will be returned.
- (COPromise<NSString*> *)async_stringForKey:(NSString *)defaultName;

/// -arrayForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray.
- (COPromise<NSArray*> *)async_arrayForKey:(NSString *)defaultName;
/// -dictionaryForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSDictionary.
- (COPromise<NSDictionary<NSString *, id>*> *)async_dictionaryForKey:(NSString *)defaultName;
/// -dataForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSData.
- (COPromise<NSData*> *)async_dataForKey:(NSString *)defaultName;
/// -stringForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray<NSString *>. Note that unlike -stringForKey:, NSNumbers are not converted to NSStrings.
- (COPromise<NSArray<NSString *>*> *)async_stringArrayForKey:(NSString *)defaultName;

/*!
 -URLForKey: is equivalent to -objectForKey: except that it converts the returned value to an NSURL. If the value is an NSString path, then it will construct a file URL to that path. If the value is an archived URL from -setURL:forKey: it will be unarchived. If the value is absent or can't be converted to an NSURL, nil will be returned.
 */
- (COPromise<NSURL*> *)async_URLForKey:(NSString *)defaultName API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/// -setInteger:forKey: is equivalent to -setObject:forKey: except that the value is converted from an NSInteger to an NSNumber.
- (COPromise*)async_setInteger:(NSInteger)value forKey:(NSString *)defaultName;
/// -setFloat:forKey: is equivalent to -setObject:forKey: except that the value is converted from a float to an NSNumber.
- (COPromise*)async_setFloat:(float)value forKey:(NSString *)defaultName;
/// -setDouble:forKey: is equivalent to -setObject:forKey: except that the value is converted from a double to an NSNumber.
- (COPromise*)async_setDouble:(double)value forKey:(NSString *)defaultName;
/// -setBool:forKey: is equivalent to -setObject:forKey: except that the value is converted from a BOOL to an NSNumber.
- (COPromise*)async_setBool:(BOOL)value forKey:(NSString *)defaultName;
/// -setURL:forKey is equivalent to -setObject:forKey: except that the value is archived to an NSData. Use -URLForKey: to retrieve values set this way.
- (COPromise*)async_setURL:(nullable NSURL *)url forKey:(NSString *)defaultName API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 -synchronize is deprecated and will be marked with the NS_DEPRECATED macro in a future release.
 
 -synchronize blocks the calling thread until all in-progress set operations have completed. This is no longer necessary. Replacements for previous uses of -synchronize depend on what the intent of calling synchronize was. If you synchronized...
 - ...before reading in order to fetch updated values: remove the synchronize call
 - ...after writing in order to notify another program to read: the other program can use KVO to observe the default without needing to notify
 - ...before exiting in a non-app (command line tool, agent, or daemon) process: call CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
 - ...for any other reason: remove the synchronize call
 */
- (COPromise<NSNumber*>*)async_synchronize;


@end

@interface NSUserDefaults (Coroutine)


/*!
 -objectForKey: will search the receiver's search list for a default with the key 'defaultName' and return it. If another process has changed defaults in the search list, NSUserDefaults will automatically update to the latest values. If the key in question has been marked as ubiquitous via a Defaults Configuration File, the latest value may not be immediately available, and the registered value will be returned instead.
 */
- (id)co_objectForKey:(NSString *)defaultName CO_ASYNC;

/*!
 -setObject:forKey: immediately stores a value (or removes the value if nil is passed as the value) for the provided key in the search list entry for the receiver's suite name in the current user and any host, then asynchronously stores the value persistently, where it is made available to other processes.
 */
- (void)co_setObject:(nullable id)value forKey:(NSString *)defaultName CO_ASYNC;

/// -removeObjectForKey: is equivalent to -[... setObject:nil forKey:defaultName]
- (void)co_removeObjectForKey:(NSString *)defaultName CO_ASYNC;

/// -stringForKey: is equivalent to -objectForKey:, except that it will convert NSNumber values to their NSString representation. If a non-string non-number value is found, nil will be returned.
- (NSString*)co_stringForKey:(NSString *)defaultName CO_ASYNC;

/// -arrayForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray.
- (NSArray*)co_arrayForKey:(NSString *)defaultName CO_ASYNC;
/// -dictionaryForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSDictionary.
- (NSDictionary<NSString *, id> *)co_dictionaryForKey:(NSString *)defaultName CO_ASYNC;
/// -dataForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSData.
- (NSData *)co_dataForKey:(NSString *)defaultName CO_ASYNC;
/// -stringForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray<NSString *>. Note that unlike -stringForKey:, NSNumbers are not converted to NSStrings.
- (NSArray<NSString *> *)co_stringArrayForKey:(NSString *)defaultName CO_ASYNC;
/*!
 -integerForKey: is equivalent to -objectForKey:, except that it converts the returned value to an NSInteger. If the value is an NSNumber, the result of -integerValue will be returned. If the value is an NSString, it will be converted to NSInteger if possible. If the value is a boolean, it will be converted to either 1 for YES or 0 for NO. If the value is absent or can't be converted to an integer, 0 will be returned.
 */
- (NSInteger)co_integerForKey:(NSString *)defaultName CO_ASYNC;
/// -floatForKey: is similar to -integerForKey:, except that it returns a float, and boolean values will not be converted.
- (float)co_floatForKey:(NSString *)defaultName CO_ASYNC;
/// -doubleForKey: is similar to -integerForKey:, except that it returns a double, and boolean values will not be converted.
- (double)co_doubleForKey:(NSString *)defaultName CO_ASYNC;
/*!
 -boolForKey: is equivalent to -objectForKey:, except that it converts the returned value to a BOOL. If the value is an NSNumber, NO will be returned if the value is 0, YES otherwise. If the value is an NSString, values of "YES" or "1" will return YES, and values of "NO", "0", or any other string will return NO. If the value is absent or can't be converted to a BOOL, NO will be returned.
 
 */
- (BOOL)co_boolForKey:(NSString *)defaultName CO_ASYNC;
/*!
 -URLForKey: is equivalent to -objectForKey: except that it converts the returned value to an NSURL. If the value is an NSString path, then it will construct a file URL to that path. If the value is an archived URL from -setURL:forKey: it will be unarchived. If the value is absent or can't be converted to an NSURL, nil will be returned.
 */
- (NSURL *)co_URLForKey:(NSString *)defaultName CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/// -setInteger:forKey: is equivalent to -setObject:forKey: except that the value is converted from an NSInteger to an NSNumber.
- (void)co_setInteger:(NSInteger)value forKey:(NSString *)defaultName CO_ASYNC;
/// -setFloat:forKey: is equivalent to -setObject:forKey: except that the value is converted from a float to an NSNumber.
- (void)co_setFloat:(float)value forKey:(NSString *)defaultName CO_ASYNC;
/// -setDouble:forKey: is equivalent to -setObject:forKey: except that the value is converted from a double to an NSNumber.
- (void)co_setDouble:(double)value forKey:(NSString *)defaultName CO_ASYNC;
/// -setBool:forKey: is equivalent to -setObject:forKey: except that the value is converted from a BOOL to an NSNumber.
- (void)co_setBool:(BOOL)value forKey:(NSString *)defaultName CO_ASYNC;
/// -setURL:forKey is equivalent to -setObject:forKey: except that the value is archived to an NSData. Use -URLForKey: to retrieve values set this way.
- (void)co_setURL:(nullable NSURL *)url forKey:(NSString *)defaultName CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 -synchronize is deprecated and will be marked with the NS_DEPRECATED macro in a future release.
 
 -synchronize blocks the calling thread until all in-progress set operations have completed. This is no longer necessary. Replacements for previous uses of -synchronize depend on what the intent of calling synchronize was. If you synchronized...
 - ...before reading in order to fetch updated values: remove the synchronize call
 - ...after writing in order to notify another program to read: the other program can use KVO to observe the default without needing to notify
 - ...before exiting in a non-app (command line tool, agent, or daemon) process: call CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
 - ...for any other reason: remove the synchronize call
 */
- (BOOL)co_synchronize CO_ASYNC;

@end

NS_ASSUME_NONNULL_END
