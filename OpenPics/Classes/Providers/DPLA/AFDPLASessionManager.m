//
//  AFDPLASessionManager.m
//  OpenPics
//
//  Created by PJ Gray on 4/13/13.
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


#import "AFDPLASessionManager.h"
#import "OPProviderTokens.h"

static NSString * const kAFDPLABaseURLString = @"http://api.dp.la/v2/";

@implementation AFDPLASessionManager

+ (AFDPLASessionManager *)sharedClient {
    static AFDPLASessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFDPLASessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAFDPLABaseURLString]];
        
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    return self;
}

- (NSURLSessionDataTask *) GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    NSMutableDictionary* mutableParams = [parameters mutableCopy];
#ifdef kOPPROVIDERTOKEN_DPLA
    mutableParams[@"api_key"] = kOPPROVIDERTOKEN_DPLA;
#endif
    
    return [super GET:URLString parameters:mutableParams success:success failure:failure];
}

@end