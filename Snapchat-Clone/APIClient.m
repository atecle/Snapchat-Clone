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
        self.APIToken = APIToken;
    }
    
    self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:self.configuration];
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
    
    NSURLRequest *URLRequest = [self requestWithPath:fullPath parameters:nil HTTPMethod:@"GET" failure:failure];
    
    if (URLRequest == nil) return;

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        NSDictionary *dictionary = [self dictionaryFromData:data response:response error:error failure:failure];
        
        NSArray *friends = [User usersFromUserDictionaries:dictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(friends);
        });
        
    }];
    
    [dataTask resume];
    
}

- (void)sendSnapchatWithImageURL:(NSURL *)imageURL toUsers:(NSArray *)users withSuccess:(void (^)(NSArray *snaps))success failure:(void (^)(NSError *error))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/snaps", baseURL];
   
    NSDictionary *parameters = @{@"to" : users, @"image_url" : imageURL.absoluteString};

    NSURLRequest *URLRequest = [self requestWithPath:fullPath parameters:parameters HTTPMethod:@"POST" failure:failure];
    
    if (URLRequest == nil) return;
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSDictionary *dictionary = [self dictionaryFromData:data response:response error:error failure:failure];

        NSArray *snaps = [Snap snapsFromDictionaries:dictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(snaps);
        });
    }];
    
    [dataTask resume];
}


- (void)retrieveSnapchatsWithSuccess:(void (^)(NSArray *snaps))success failure:(void (^)(NSError *error))failure
{
    NSLog(@"In retrieve snapchats w/ success");
    NSString *fullPath = [NSString stringWithFormat:@"%@/snaps", baseURL];
    
    NSURLRequest *URLRequest = [self requestWithPath:fullPath parameters:nil HTTPMethod:@"GET" failure:failure];

    if (URLRequest == nil) return;

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        NSDictionary *dictionary = [self dictionaryFromData:data response:response error:error failure:failure];

        NSArray *snaps = [Snap snapsFromDictionaries:dictionary];
        
        NSArray *reverseSnaps = [[snaps reverseObjectEnumerator] allObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(reverseSnaps);
        });

    }];
    
    [dataTask resume];
}

- (void)retrieveSnapchatWithID:(NSInteger) snapID success:(void (^)(Snap *snap))success failure:(void (^)(NSError *error))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/snaps/%ld", baseURL, (long)snapID];
    
    NSURLRequest *URLRequest = [self requestWithPath:fullPath parameters:nil HTTPMethod:@"GET" failure:failure];

    if (URLRequest == nil) return;

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *dictionary = [self dictionaryFromData:data response:response error:error failure:failure];
        
        Snap *snap = [[Snap alloc] initFromDictionary: dictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(snap);
        });
        
    }];
    
    [dataTask resume];
}


- (void)uploadImage:(UIImage *)image withSuccess:(void (^)(NSURL *))success failure:(void (^)(NSError *))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/media/upload", baseURL];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
  
    NSURLRequest *URLRequest = [self multipartRequestWithPath:fullPath HTTPMethod:@"POST" data:imageData];

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *dictionary = [self dictionaryFromData:data response:response error:error failure:failure];
        
        if (dictionary == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }
        
        NSURL *imageURL = [NSURL URLWithString: dictionary[@"image_url"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(imageURL);
        });
        
    }];
    
    [dataTask resume];
}

- (void)markSnapchatReadWithID:(NSInteger) snapID success:(void (^)(Snap *snap))success failure:(void (^)(NSError *error))failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/snaps/%ld/read", baseURL, (long)snapID];
    
    NSURLRequest *URLRequest = [self requestWithPath:fullPath parameters:nil HTTPMethod:@"PUT" failure:failure];

    if (URLRequest == nil) return;

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *dictionary = [self dictionaryFromData:data response:response error:error failure:failure];

        Snap *snap = [[Snap alloc] initFromDictionary:dictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(snap);
        });
    }];
    
    [dataTask resume];
}

# pragma mark - Helpers

- (NSURLRequest *)requestWithPath:(NSString *)fullPath parameters:(NSDictionary *)parameters HTTPMethod:(NSString *)HTTPMethod failure:(void (^)(NSError *error))failure
{
    NSError *JSONError = nil;
    NSData *parameterJSON = nil;
    
    if (parameters != nil)
    {
        parameterJSON = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&JSONError];
        if (parameterJSON == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(JSONError);
            });
            return nil;
        }
    }
    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullPath]];
    
    [URLRequest setHTTPMethod:HTTPMethod];
    [URLRequest setHTTPBody:parameterJSON];
    
    [URLRequest setValue:self.APIToken forHTTPHeaderField:@"X-Api-Token"];
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [URLRequest copy];
}

- (NSDictionary *)dictionaryFromData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error failure:(void (^)(NSError *error))failure
{
    if (error != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
        return nil;
    }
    
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode > 299)
    {
        NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeServerError userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
        return nil;
    }
    
    if (![[HTTPResponse.allHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"application/json"])
    {
        NSError *error = [NSError errorWithDomain:APIClientErrorDomain code:APIClientErrorCodeInvalidContentType userInfo:nil];
        failure(error);
        return nil;
    }
    
    NSError *JSONError = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
    
    
    if (dictionary == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(JSONError);
        });
        return nil;
    }
    
    
    return dictionary;
}

- (NSURLRequest *)multipartRequestWithPath:(NSString *)fullPath HTTPMethod:(NSString *)method data:(NSData *)data
{
    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullPath]];
    
    [URLRequest setHTTPMethod:method];
    [URLRequest setValue:self.APIToken forHTTPHeaderField:@"X-Api-Token"];
    
    NSData *randomStringData = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *boundary = [randomStringData base64EncodedStringWithOptions:kNilOptions];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [URLRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSData *bodyBoundaryBegin = [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *bodyBoundaryEnd = [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *parameterName = @"file";
    NSString *fileName = @"file.jpg";
    NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameterName, fileName];
    NSString *dataType = @"Content-Type: application/octet-stream\r\n\r\n";
    
    NSMutableData *HTTPBody = [[NSMutableData alloc] init];
    
    [HTTPBody appendData:bodyBoundaryBegin];
    
    [HTTPBody appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
    [HTTPBody appendData:[dataType dataUsingEncoding:NSUTF8StringEncoding]];
    
    [HTTPBody appendData:data];
    
    [HTTPBody appendData:bodyBoundaryEnd];
    
    [URLRequest setHTTPBody:HTTPBody];
    
    return URLRequest;
}

- (void)setAPIToken:(NSString *)APIToken
{
    _APIToken = APIToken;
}

@end
