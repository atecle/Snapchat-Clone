//
//  APIClient.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "APIClient.h"

static NSString * const baseURL = @"https://snapchat-example-api.herokuapp.com/api/v1/";

NSString * const APIClientErrorDomain = @"APIClientErrorDomain";

@interface APIClient()

@property (strong, nonatomic) NSString *APIToken;

@end

@implementation APIClient

- (instancetype)initWithAPIToken:(NSString *)APIToken
{
    if ((self = [super init]))
    {
        _APIToken = APIToken;
    }
    
    return self;
}

- (void)authenticateForUser:(NSString *)username withPassword:(NSString *)password success:( void (^)(NSInteger))success failure:(void (^)(NSError *))failure
{
    
}

- (void)retrieveFriendsWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    
}

- (void)setAPIToken:(NSString *)APIToken
{
    _APIToken = APIToken;
}

@end
