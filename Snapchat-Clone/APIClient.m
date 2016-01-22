//
//  APIClient.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "APIClient.h"

static NSString * const baseURL = @"https://snapchat-example-api.herokuapp.com/api/v1";

NSString * const APIClientErrorDomain = @"APIClientErrorDomain";

@interface APIClient()

@property (strong, nonatomic) NSString *APIToken;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionConfiguration *configuration;

@end

@implementation APIClient

- (instancetype)initWithAPIToken:(NSString *)APIToken
{
    if ((self = [super init]))
    {
        _APIToken = APIToken;
    }
    
    _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:self.configuration];
    return self;
}

+ (void)authenticateForUser:(NSString *)username withPassword:(NSString *)password success:( void (^)(User *, NSString *APIToken))success failure:(void (^)(NSError *))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/users/authenticate", baseURL];
    
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullPath]];
    [URLRequest setHTTPMethod:@"POST"];
    
    NSDictionary *parameters = @{@"username" : username, @"password" : password};
    NSError *JSONError = nil;

    NSData *parameterJSON = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&JSONError];
    
    if (parameterJSON == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(JSONError);
        });
        return;
    }
    
    [URLRequest setHTTPBody:parameterJSON];
    
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode > 299)
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeServerError userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        if (![[HTTPResponse.allHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"application/json"])
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeInvalidContentType userInfo:nil];
            failure(error);
            return;
        }
        
        NSError *JSONError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
        
        
        if (dictionary == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(JSONError);
            });
            return;
        }
      
        NSDictionary *userDictionary = dictionary[@"user"];
        User *user = [[User alloc] initFromDictionary:userDictionary];
        NSString *APIToken = dictionary[@"api_token"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(user, APIToken);
        });
    }];
    
    [dataTask resume];
}

- (void)retrieveFriendsWithSuccess:(void (^)(NSArray *friends))success failure:(void (^)(NSError *error))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/users/friends", baseURL];
    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullPath]];
   
    [URLRequest setHTTPMethod:@"GET"];
    
    [URLRequest setValue:self.APIToken forHTTPHeaderField:@"X-Api-Token"];
    
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode > 299)
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeServerError userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        if (![[HTTPResponse.allHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"application/json"])
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeInvalidContentType userInfo:nil];
            failure(error);
            return;
        }
        
        NSError *JSONError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
        
        
        if (dictionary == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(JSONError);
            });
            return;
        }
        
        NSArray *friends = [User usersFromUserDictionaries:dictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(friends);
        });
        
    }];
    
    [dataTask resume];
    
}

- (void)sendSnapchatWithImage:(UIImage *)image toUsers:(NSArray *)users withSuccess:(void (^)(NSArray *snaps))success failure:(void (^)(NSError *error))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/snaps", baseURL];
    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullPath]];
    
    NSError *JSONError;
    
    NSDictionary *parameters = @{@"to" : users};
    
    NSData *parameterData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&JSONError];
    
    [URLRequest setHTTPMethod:@"POST"];
    
    [URLRequest setHTTPBody:parameterData];
    
    [URLRequest setValue:self.APIToken forHTTPHeaderField:@"X-Api-Token"];
    
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
    
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode > 299)
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeServerError userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        if (![[HTTPResponse.allHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"application/json"])
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeInvalidContentType userInfo:nil];
            failure(error);
            return;
        }
        
        NSError *JSONError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
        
        
        if (dictionary == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(JSONError);
            });
            return;
        }
        
        NSArray *snaps = [Snap snapsFromDictionaries:dictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(snaps);
        });
    }];
    
    [dataTask resume];
}


- (void)retrieveSnapchatsWithSuccess:(void (^)(NSArray *snaps))success failure:(void (^)(NSError *error))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/snaps", baseURL];
    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullPath]];
    
    [URLRequest setHTTPMethod:@"GET"];
    
    [URLRequest setValue:self.APIToken forHTTPHeaderField:@"X-Api-Token"];
    
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode > 299)
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeServerError userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        if (![[HTTPResponse.allHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"application/json"])
        {
            NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeInvalidContentType userInfo:nil];
            failure(error);
            return;
        }
        
        NSError *JSONError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
        
        
        if (dictionary == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(JSONError);
            });
            return;
        }
        
        NSArray *snaps = [Snap snapsFromDictionaries:dictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(snaps);
        });

    }];
    
    [dataTask resume];
}


- (void)setAPIToken:(NSString *)APIToken
{
    _APIToken = APIToken;
}

@end
