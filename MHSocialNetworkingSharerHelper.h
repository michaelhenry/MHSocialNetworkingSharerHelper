//
// MRTSocialService.h
// iamkel.net
//
// Created by Michael henry Pantaleon on 4/30/13.
// Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
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

@class FBSession;
@class ACAccount;

@interface MHSocialNetworkingSharerHelper : NSObject

+ (MHSocialNetworkingSharerHelper *)sharedClient;

- (void) postStatusToTwitter:(NSString*)message account:(ACAccount*)account successBlock:(void(^)(void))successBlock errorBlock:(void(^)(NSError*error))errorBlock;
- (void) postStatusToFacebook:(NSString*)message successBlock:(void(^)(id result))successBlock errorBlock:(void(^)(NSError*error))errorBlock;
- (void) loadFacebookCredentialsWithSuccessBlock:(void(^)(FBSession*session))successBlock errorBlock:(void(^)(NSError*error))errorBlock;
- (void) loadTwitterCredentialsWithSuccessBlock:(void(^)(ACAccount*account))successBlock errorBlock:(void(^)(NSError*error))errorBlock;
@end
