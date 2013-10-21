//
// MRTSocialService.m
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

#import "MHSocialNetworkingSharerHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define TWITTER_API @"http://api.twitter.com"
#define TWITTER_API_VERSION @"1.1"

#define SOCIAL_ERROR_DOMAIN @"net.iamkel.mhsocialnetworkingsharerhelper"

@interface MHSocialNetworkingSharerHelper()
- (NSError*) errorCode:(NSInteger) code errorMessage:(NSString*)errorMessage;
@end

@implementation MHSocialNetworkingSharerHelper

+ (MHSocialNetworkingSharerHelper *)sharedClient
{
    static MHSocialNetworkingSharerHelper *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[MHSocialNetworkingSharerHelper alloc] init];
    });
    
    return client;
}

#pragma mark - Social Posting
- (void) postStatusToTwitter:(NSString*)message account:(ACAccount*)account successBlock:(void(^)(void))successBlock errorBlock:(void(^)(NSError*error))errorBlock {
    
    SLRequest * postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@",TWITTER_API,TWITTER_API_VERSION,@"statuses",@"update.json"]] parameters:@{@"status":message}];
    
    [postRequest setAccount:account];
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if(error){
             errorBlock(error);
         } else {
             NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
             if([urlResponse statusCode]==200) {
                 successBlock();
             }else if([urlResponse statusCode]==403)  {
                 errorBlock([self errorCode:22 errorMessage:@"Duplicate Twitter status"]);
             }else {
                 errorBlock([self errorCode:23 errorMessage:@"Unknown error from twitter"]);
             }
         }
     }];
}

- (void) postStatusToFacebook:(NSString*)message successBlock:(void(^)(id result))successBlock errorBlock:(void(^)(NSError*error))errorBlock{
    /*
     NSDictionary * params = [@{
     @"link" : @"https://google.com",
     @"picture" : @"https://graph.facebook.com/ken119/picture",
     @"name" : @"NAME HERE",
     @"caption" : @"CAPTION",
     @"description" : @"DESCRIPTION"
     } mutableCopy];
     */
    
    NSDictionary * params = @{@"message":message};
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:params
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         if (error) {
             errorBlock(error);
         } else {
             successBlock(result);
         }
     }];
}


#pragma mark - Social Credentials
- (void) loadFacebookCredentialsWithSuccessBlock:(void(^)(FBSession*session))successBlock errorBlock:(void(^)(NSError*error))errorBlock{
    if ([[FBSession activeSession]isOpen]) {
        /*
         * if the current session has no publish permission we need to reauthorize
         */
        if ([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound) {
            
            [[FBSession activeSession] requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_action"] defaultAudience:FBSessionDefaultAudienceFriends
                                                  completionHandler:^(FBSession *session,NSError *error){
                                                      // ADD NEW PUBLIC PERMISSION
                                                      if(error) {
                                                          errorBlock(error);
                                                      }else {
                                                          successBlock(session);
                                                      }
                                                  }];
        }else{
            successBlock([FBSession activeSession]);
        }
    }else{
        /*
         * open a new session with publish permission
         */
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceOnlyMe
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if(error) {
                                                 errorBlock(error);
                                             }else {
                                                 successBlock(session);
                                             }
                                         }];
    }
}

- (void) loadTwitterCredentialsWithSuccessBlock:(void(^)(ACAccount*account))successBlock errorBlock:(void(^)(NSError*error))errorBlock {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to access their Twitter account
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(!error){
            if (granted == YES)
            {
                NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                if ([arrayOfAccounts count] > 0)
                {
                    //use the first account available
                    ACAccount *acct = [arrayOfAccounts objectAtIndex:0];
                    successBlock(acct);
                }else {
                    // No Twitter Accounts
                    errorBlock([self errorCode:21 errorMessage:@"Please add a Twitter account to your phone setting. Thank you!"]);
                }
            }else {
                // Please allow Twitter in Phone setting
                errorBlock([self errorCode:20 errorMessage:@"Please allow twitter in your phone setting. Thank you!"]);
            }
        }else {
            // Unexpected Error
            errorBlock(error);
        }

    }];
}

- (NSError*) errorCode:(NSInteger) code errorMessage:(NSString*)errorMessage{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
    return  [NSError errorWithDomain:SOCIAL_ERROR_DOMAIN code:code userInfo:errorDetail];
}
@end