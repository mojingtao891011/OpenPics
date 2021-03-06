//
//  OPProvider.h
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>

@class OPItem;
@interface OPProvider : NSObject

@property (strong, nonatomic) NSString* providerType;
@property (strong, nonatomic) NSString* providerName;
@property (strong, nonatomic) NSString* providerShortName;

// This means the provider has an initial search, for a more passive experience of browsing
//    DEFAULT:  NO
@property BOOL supportsInitialSearching;

- (id) initWithProviderType:(NSString*) providerType;

- (BOOL) isConfigured;

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure;

- (void) doInitialSearchInSet:(OPItem*) setItem
                  withSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                      failure:(void (^)(NSError* error))failure;

- (void) getItemsInSet:(OPItem*) setItem
        withPageNumber:(NSNumber*) pageNumber
               success:(void (^)(NSArray* items, BOOL canLoadMore))success
               failure:(void (^)(NSError* error))failure;

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure;

- (void) upRezItem:(OPItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPItem* item))completion;

- (void) fullUpRezItem:(OPItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPItem* item))completion;


- (void) contentDMImageInfoWithURL:(NSURL*) url
                          withItem:(OPItem*) item
                      withHostName:(NSString*) hostName
                    withCollection:(NSString*) collectionString
                            withID:(NSString*) idString
                     withURLFormat:(NSString*) urlFormat
                    withCompletion:(void (^)(NSURL *uprezImageUrl, OPItem* item))completion;

@end
