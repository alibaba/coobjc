//
//  NSFileManager+Coroutine.h
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
#import <coobjc/co_tuple.h>
#import <coobjc/coobjc.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSFileManager (COPromise)

/* createDirectoryAtURL:withIntermediateDirectories:attributes:error: creates a directory at the specified URL. If you pass 'NO' for withIntermediateDirectories, the directory must not exist at the time this call is made. Passing 'YES' for withIntermediateDirectories will create any necessary intermediate directories. This method returns YES if all directories specified in 'url' were created and attributes were set. Directories are created with attributes specified by the dictionary passed to 'attributes'. If no dictionary is supplied, directories are created according to the umask of the process. This method returns NO if a failure occurs at any stage of the operation. If an error parameter was provided, a presentable NSError will be returned by reference.
 */
- (COPromise<NSNumber*>*)async_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));

/* createSymbolicLinkAtURL:withDestinationURL:error: returns YES if the symbolic link that point at 'destURL' was able to be created at the location specified by 'url'. 'destURL' is always resolved against its base URL, if it has one. If 'destURL' has no base URL and it's 'relativePath' is indeed a relative path, then a relative symlink will be created. If this method returns NO, the link was unable to be created and an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 */
- (COPromise<NSNumber*>*)async_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL  API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));

/* setAttributes:ofItemAtPath:error: returns YES when the attributes specified in the 'attributes' dictionary are set successfully on the item specified by 'path'. If this method returns NO, a presentable NSError will be provided by-reference in the 'error' parameter. If no error is required, you may pass 'nil' for the error.
 
 This method replaces changeFileAttributes:atPath:.
 */
- (COPromise<NSNumber*>*)async_setAttributes:(NSDictionary<NSFileAttributeKey, id> *)attributes ofItemAtPath:(NSString *)path API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* createDirectoryAtPath:withIntermediateDirectories:attributes:error: creates a directory at the specified path. If you pass 'NO' for createIntermediates, the directory must not exist at the time this call is made. Passing 'YES' for 'createIntermediates' will create any necessary intermediate directories. This method returns YES if all directories specified in 'path' were created and attributes were set. Directories are created with attributes specified by the dictionary passed to 'attributes'. If no dictionary is supplied, directories are created according to the umask of the process. This method returns NO if a failure occurs at any stage of the operation. If an error parameter was provided, a presentable NSError will be returned by reference.
 
 This method replaces createDirectoryAtPath:attributes:
 */
- (COPromise<NSNumber*>*)async_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* contentsOfDirectoryAtPath:error: returns an NSArray of NSStrings representing the filenames of the items in the directory. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. If the directory contains no items, this method will return the empty array.
 
 This method replaces directoryContentsAtPath:
 */
- (COPromise<NSArray<NSString *>*> *)async_contentsOfDirectoryAtPath:(NSString *)path API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* subpathsOfDirectoryAtPath:error: returns an NSArray of NSStrings representing the filenames of the items in the specified directory and all its subdirectories recursively. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. If the directory contains no items, this method will return the empty array.
 
 This method replaces subpathsAtPath:
 */
- (COPromise<NSArray<NSString *>*> *)async_subpathsOfDirectoryAtPath:(NSString *)path API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* attributesOfItemAtPath:error: returns an NSDictionary of key/value pairs containing the attributes of the item (file, directory, symlink, etc.) at the path in question. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 
 This method replaces fileAttributesAtPath:traverseLink:.
 */
- (COPromise<NSDictionary<NSFileAttributeKey, id>*> *)async_attributesOfItemAtPath:(NSString *)path API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* attributesOfFileSystemForPath:error: returns an NSDictionary of key/value pairs containing the attributes of the filesystem containing the provided path. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 
 This method replaces fileSystemAttributesAtPath:.
 */
- (COPromise<NSDictionary<NSFileAttributeKey, id>*> *)async_attributesOfFileSystemForPath:(NSString *)path API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* createSymbolicLinkAtPath:withDestination:error: returns YES if the symbolic link that point at 'destPath' was able to be created at the location specified by 'path'. If this method returns NO, the link was unable to be created and an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 
 This method replaces createSymbolicLinkAtPath:pathContent:
 */
- (COPromise<NSNumber*>*)async_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* destinationOfSymbolicLinkAtPath:error: returns an NSString containing the path of the item pointed at by the symlink specified by 'path'. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter.
 
 This method replaces pathContentOfSymbolicLinkAtPath:
 */
- (COPromise<NSString *>*)async_destinationOfSymbolicLinkAtPath:(NSString *)path API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* These methods replace their non-error returning counterparts below. See the NSFileManagerDelegate protocol below for methods that are dispatched to the NSFileManager instance's delegate.
 */
- (COPromise<NSNumber*>*)async_copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
- (COPromise<NSNumber*>*)async_moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
- (COPromise<NSNumber*>*)async_linkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
- (COPromise<NSNumber*>*)async_removeItemAtPath:(NSString *)path API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));


/* These methods are URL-taking equivalents of the four methods above. Their delegate methods are defined in the NSFileManagerDelegate protocol below.
 */
- (COPromise<NSNumber*>*)async_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (COPromise<NSNumber*>*)async_moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (COPromise<NSNumber*>*)async_linkItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (COPromise<NSNumber*>*)async_removeItemAtURL:(NSURL *)URL API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* trashItemAtURL:resultingItemURL:error: returns YES if the item at 'url' was successfully moved to a Trash. Since the operation may require renaming the file to avoid collisions, it also returns by reference the resulting URL that the item was moved to. If this method returns NO, the item was not moved and an NSError will be returned by reference in the 'error' parameter.
 
 To easily discover if an item is in the Trash, you may use [fileManager getRelationship:&result ofDirectory:NSTrashDirectory inDomain:0 toItemAtURL:url error:&error] && result == NSURLRelationshipContains.
 */
- (COPromise<NSNumber*>*)async_trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL * _Nullable * _Nullable)outResultingURL API_AVAILABLE(macos(10.8), ios(11.0)) API_UNAVAILABLE(watchos, tvos);


/* The following methods are of limited utility. Attempting to predicate behavior based on the current state of the filesystem or a particular file on the filesystem is encouraging odd behavior in the face of filesystem race conditions. It's far better to attempt an operation (like loading a file or creating a directory) and handle the error gracefully than it is to try to figure out ahead of time whether the operation will succeed.
 */
- (COPromise<COTuple2<NSNumber*, NSNumber*>*>*)async_fileExistsAtPath:(NSString *)path;
- (COPromise<NSNumber*>*)async_isReadableFileAtPath:(NSString *)path;
- (COPromise<NSNumber*>*)async_isWritableFileAtPath:(NSString *)path;
- (COPromise<NSNumber*>*)async_isExecutableFileAtPath:(NSString *)path;
- (COPromise<NSNumber*>*)async_isDeletableFileAtPath:(NSString *)path;

/* -contentsEqualAtPath:andPath: does not take into account data stored in the resource fork or filesystem extended attributes.
 */
- (COPromise<NSNumber*>*)async_contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2;


/* subpathsAtPath: returns an NSArray of all contents and subpaths recursively from the provided path. This may be very expensive to compute for deep filesystem hierarchies, and should probably be avoided.
 */
- (COPromise<NSArray<NSString *>*> *)async_subpathsAtPath:(NSString *)path;

/* These methods are provided here for compatibility. The corresponding methods on NSData which return NSErrors should be regarded as the primary method of creating a file from an NSData or retrieving the contents of a file as an NSData.
 */
- (COPromise<NSData*> *)async_contentsAtPath:(NSString *)path;
- (COPromise<NSNumber*>*)async_createFileAtPath:(NSString *)path contents:(nullable NSData *)data attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attr;

/* -replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error: is for developers who wish to perform a safe-save without using the full NSDocument machinery that is available in the AppKit.
 
 The `originalItemURL` is the item being replaced.
 `newItemURL` is the item which will replace the original item. This item should be placed in a temporary directory as provided by the OS, or in a uniquely named directory placed in the same directory as the original item if the temporary directory is not available.
 If `backupItemName` is provided, that name will be used to create a backup of the original item. The backup is placed in the same directory as the original item. If an error occurs during the creation of the backup item, the operation will fail. If there is already an item with the same name as the backup item, that item will be removed. The backup item will be removed in the event of success unless the `NSFileManagerItemReplacementWithoutDeletingBackupItem` option is provided in `options`.
 For `options`, pass `0` to get the default behavior, which uses only the metadata from the new item while adjusting some properties using values from the original item. Pass `NSFileManagerItemReplacementUsingNewMetadataOnly` in order to use all possible metadata from the new item.
 */
- (COPromise<NSNumber*>*)async_replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL backupItemName:(nullable NSString *)backupItemName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL * _Nullable * _Nullable)resultingURL API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

@end


@interface NSFileManager (Coroutine)

/* createDirectoryAtURL:withIntermediateDirectories:attributes:error: creates a directory at the specified URL. If you pass 'NO' for withIntermediateDirectories, the directory must not exist at the time this call is made. Passing 'YES' for withIntermediateDirectories will create any necessary intermediate directories. This method returns YES if all directories specified in 'url' were created and attributes were set. Directories are created with attributes specified by the dictionary passed to 'attributes'. If no dictionary is supplied, directories are created according to the umask of the process. This method returns NO if a failure occurs at any stage of the operation. If an error parameter was provided, a presentable NSError will be returned by reference.
 */
- (BOOL)co_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));

/* createSymbolicLinkAtURL:withDestinationURL:error: returns YES if the symbolic link that point at 'destURL' was able to be created at the location specified by 'url'. 'destURL' is always resolved against its base URL, if it has one. If 'destURL' has no base URL and it's 'relativePath' is indeed a relative path, then a relative symlink will be created. If this method returns NO, the link was unable to be created and an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 */
- (BOOL)co_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL error:(NSError**)error CO_ASYNC  API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));

/* setAttributes:ofItemAtPath:error: returns YES when the attributes specified in the 'attributes' dictionary are set successfully on the item specified by 'path'. If this method returns NO, a presentable NSError will be provided by-reference in the 'error' parameter. If no error is required, you may pass 'nil' for the error.
 
 This method replaces changeFileAttributes:atPath:.
 */
- (BOOL)co_setAttributes:(NSDictionary<NSFileAttributeKey, id> *)attributes ofItemAtPath:(NSString *)path error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* createDirectoryAtPath:withIntermediateDirectories:attributes:error: creates a directory at the specified path. If you pass 'NO' for createIntermediates, the directory must not exist at the time this call is made. Passing 'YES' for 'createIntermediates' will create any necessary intermediate directories. This method returns YES if all directories specified in 'path' were created and attributes were set. Directories are created with attributes specified by the dictionary passed to 'attributes'. If no dictionary is supplied, directories are created according to the umask of the process. This method returns NO if a failure occurs at any stage of the operation. If an error parameter was provided, a presentable NSError will be returned by reference.
 
 This method replaces createDirectoryAtPath:attributes:
 */
- (BOOL)co_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* contentsOfDirectoryAtPath:error: returns an NSArray of NSStrings representing the filenames of the items in the directory. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. If the directory contains no items, this method will return the empty array.
 
 This method replaces directoryContentsAtPath:
 */
- (NSArray<NSString *> *)co_contentsOfDirectoryAtPath:(NSString *)path error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* subpathsOfDirectoryAtPath:error: returns an NSArray of NSStrings representing the filenames of the items in the specified directory and all its subdirectories recursively. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. If the directory contains no items, this method will return the empty array.
 
 This method replaces subpathsAtPath:
 */
- (NSArray<NSString *> *)co_subpathsOfDirectoryAtPath:(NSString *)path error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* attributesOfItemAtPath:error: returns an NSDictionary of key/value pairs containing the attributes of the item (file, directory, symlink, etc.) at the path in question. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 
 This method replaces fileAttributesAtPath:traverseLink:.
 */
- (NSDictionary<NSFileAttributeKey, id> *)co_attributesOfItemAtPath:(NSString *)path error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* attributesOfFileSystemForPath:error: returns an NSDictionary of key/value pairs containing the attributes of the filesystem containing the provided path. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 
 This method replaces fileSystemAttributesAtPath:.
 */
- (NSDictionary<NSFileAttributeKey, id> *)co_attributesOfFileSystemForPath:(NSString *)path error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* createSymbolicLinkAtPath:withDestination:error: returns YES if the symbolic link that point at 'destPath' was able to be created at the location specified by 'path'. If this method returns NO, the link was unable to be created and an NSError will be returned by reference in the 'error' parameter. This method does not traverse a terminal symlink.
 
 This method replaces createSymbolicLinkAtPath:pathContent:
 */
- (BOOL)co_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* destinationOfSymbolicLinkAtPath:error: returns an NSString containing the path of the item pointed at by the symlink specified by 'path'. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter.
 
 This method replaces pathContentOfSymbolicLinkAtPath:
 */
- (NSString *)co_destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* These methods replace their non-error returning counterparts below. See the NSFileManagerDelegate protocol below for methods that are dispatched to the NSFileManager instance's delegate.
 */
- (BOOL)co_copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
- (BOOL)co_moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
- (BOOL)co_linkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
- (BOOL)co_removeItemAtPath:(NSString *)path error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));


/* These methods are URL-taking equivalents of the four methods above. Their delegate methods are defined in the NSFileManagerDelegate protocol below.
 */
- (BOOL)co_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (BOOL)co_moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (BOOL)co_linkItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (BOOL)co_removeItemAtURL:(NSURL *)URL error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* trashItemAtURL:resultingItemURL:error: returns YES if the item at 'url' was successfully moved to a Trash. Since the operation may require renaming the file to avoid collisions, it also returns by reference the resulting URL that the item was moved to. If this method returns NO, the item was not moved and an NSError will be returned by reference in the 'error' parameter.
 
 To easily discover if an item is in the Trash, you may use [fileManager getRelationship:&result ofDirectory:NSTrashDirectory inDomain:0 toItemAtURL:url error:&error] && result == NSURLRelationshipContains.
 */
- (BOOL)co_trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL * _Nullable * _Nullable)outResultingURL error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.8), ios(11.0)) API_UNAVAILABLE(watchos, tvos);


/* The following methods are of limited utility. Attempting to predicate behavior based on the current state of the filesystem or a particular file on the filesystem is encouraging odd behavior in the face of filesystem race conditions. It's far better to attempt an operation (like loading a file or creating a directory) and handle the error gracefully than it is to try to figure out ahead of time whether the operation will succeed.
 */
- (BOOL)co_fileExistsAtPath:(NSString *)path isDirectory:(BOOL* _Nullable)isDirectory CO_ASYNC;
- (BOOL)co_isReadableFileAtPath:(NSString *)path CO_ASYNC;
- (BOOL)co_isWritableFileAtPath:(NSString *)path CO_ASYNC;
- (BOOL)co_isExecutableFileAtPath:(NSString *)path CO_ASYNC;
- (BOOL)co_isDeletableFileAtPath:(NSString *)path CO_ASYNC;

/* -contentsEqualAtPath:andPath: does not take into account data stored in the resource fork or filesystem extended attributes.
 */
- (BOOL)co_contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2 CO_ASYNC;


/* subpathsAtPath: returns an NSArray of all contents and subpaths recursively from the provided path. This may be very expensive to compute for deep filesystem hierarchies, and should probably be avoided.
 */
- (NSArray<NSString *> *)co_subpathsAtPath:(NSString *)path CO_ASYNC;

/* These methods are provided here for compatibility. The corresponding methods on NSData which return NSErrors should be regarded as the primary method of creating a file from an NSData or retrieving the contents of a file as an NSData.
 */
- (NSData *)co_contentsAtPath:(NSString *)path CO_ASYNC;
- (BOOL)co_createFileAtPath:(NSString *)path contents:(nullable NSData *)data attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attr CO_ASYNC;

/* -replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error: is for developers who wish to perform a safe-save without using the full NSDocument machinery that is available in the AppKit.
 
 The `originalItemURL` is the item being replaced.
 `newItemURL` is the item which will replace the original item. This item should be placed in a temporary directory as provided by the OS, or in a uniquely named directory placed in the same directory as the original item if the temporary directory is not available.
 If `backupItemName` is provided, that name will be used to create a backup of the original item. The backup is placed in the same directory as the original item. If an error occurs during the creation of the backup item, the operation will fail. If there is already an item with the same name as the backup item, that item will be removed. The backup item will be removed in the event of success unless the `NSFileManagerItemReplacementWithoutDeletingBackupItem` option is provided in `options`.
 For `options`, pass `0` to get the default behavior, which uses only the metadata from the new item while adjusting some properties using values from the original item. Pass `NSFileManagerItemReplacementUsingNewMetadataOnly` in order to use all possible metadata from the new item.
 */
- (BOOL)co_replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL backupItemName:(nullable NSString *)backupItemName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL * _Nullable * _Nullable)resultingURL  error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

@end

NS_ASSUME_NONNULL_END
