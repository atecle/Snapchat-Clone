//
//  APIClient.h
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "User.h"
#import "Snap.h"

extern NSString * const APIClientErrorDomain;

typedef NS_ENUM(NSInteger, APIClientErrorCode)
{
    APIClientErrorCodeNotAnError,
    APIClientErrorCodeServerError,
    APIClientErrorCodeInvalidContentType
};

@interface APIClient : NSObject

- (instancetype)initWithAPIToken:(NSString *)APIToken;

+ (void)authenticateForUser:(NSString *)username withPassword:(NSString *)password success:( void (^)(User *user, NSString *APIToken))success failure:(void (^)(NSError *error))failure;
- (void)retrieveFriendsWithSuccess:(void (^)(NSArray *friends))success failure:(void (^)(NSError *error))failure;
- (void)sendSnapchatWithImage:(UIImage *)image toUsers:(NSArray *)users withSuccess:(void (^)(NSArray *snaps))success failure:(void (^)(NSError *error))failure;


@end
