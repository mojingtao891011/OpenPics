//
//  OPImageManager.m
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

#import "OPImageManager.h"
#import "UIImageView+Hourglass.h"
#import "OPImageItem.h"
#import "AFHTTPRequestOperation.h"

@interface OPImageManager () {
    NSMutableDictionary* _imageOperations;
}

@end

@implementation OPImageManager

-(id) init {
    self = [super init];
    if (self) {
        _imageOperations = @{}.mutableCopy;
    }
    return self;
}

+ (NSOperationQueue *)imageRequestOperationQueue {
    static NSOperationQueue *_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _imageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _imageRequestOperationQueue;
}

- (void) cancelImageOperationAtIndexPath:(NSIndexPath*)indexPath {
    AFHTTPRequestOperation* operation = _imageOperations[indexPath];
    if (operation.isExecuting) {
        NSLog(@"Not visible, cancelling operation for item: %ld", (long)indexPath.item);
        [operation cancel];
        
    }
}

- (void) getImageWithRequestForItem:(OPImageItem*) item
                      withIndexPath:(NSIndexPath*) indexPath
                        withSuccess:(void (^)(UIImage* image))success
                        withFailure:(void (^)(void))failure {
    // if not found in cache, create request to download image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:item.imageUrl];
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage* image = (UIImage*) responseObject;
        
        // if this item url is equal to the request one - continue (avoids flashyness on fast scrolling)
        if ([item.imageUrl.absoluteString isEqualToString:request.URL.absoluteString]) {
            if (success) {
                success(image);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
            NSLog(@"error getting image: %@", operation.request.URL);
            if (failure) {
                failure();
            }
        }
    }];
    _imageOperations[indexPath] = operation;
    [[[self class] imageRequestOperationQueue] addOperation:operation];
}

- (BOOL) isCellVisibleAtIndexPath:(NSIndexPath*) indexPath forCollectionView:(UICollectionView*) collectionView {
    for (NSIndexPath* thisIndexPath in collectionView.indexPathsForVisibleItems) {
        if (indexPath.item == thisIndexPath.item) {
            return YES;
        }
    }
    
    return NO;
}

- (void) loadImageFromItem:(OPImageItem*) item
               toImageView:(UIImageView*) imageView
               atIndexPath:(NSIndexPath*) indexPath
          onCollectionView:(UICollectionView*) cv
           withContentMode:(UIViewContentMode)contentMode
{
    [imageView fadeInHourglassWithCompletion:^{
        [self getImageWithRequestForItem:item withIndexPath:indexPath withSuccess:^(UIImage *image) {
            // if this cell is currently visible, continue drawing - this is for when scrolling fast (avoids flashyness)
            if ([self isCellVisibleAtIndexPath:indexPath forCollectionView:cv]) {
                // then dispatch back to the main thread to set the image
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // fade out the hourglass image
                    [UIView animateWithDuration:0.25 animations:^{
                        imageView.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        imageView.contentMode = contentMode;
                        imageView.image = image;
                        
                        // fade in image
                        [UIView animateWithDuration:0.5 animations:^{
                            imageView.alpha = 1.0;
                        }];
                        
                        //if we have no size information yet, save the information in item, and force a re-layout
                        if (!item.size.height) {
                            item.size = image.size;
                            [cv.collectionViewLayout invalidateLayout];
                        }
                    }];
                });
            }
        } withFailure:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25 animations:^{
                    imageView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    imageView.image = [UIImage imageNamed:@"image_cancel"];
                    [UIView animateWithDuration:0.5 animations:^{
                        imageView.alpha = 1.0;
                    }];
                }];
            });
        }];
    }];
}

@end
