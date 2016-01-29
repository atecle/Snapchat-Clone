//
//  PushNotificationProxy.m
//  Snapchat-Clone
//
//  Created by Adam on 1/29/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "PushNotificationProxy.h"

@interface PushNotificationProxy()

@property (strong, nonatomic) APIClient *APIClient;

@end

@implementation PushNotificationProxy

- (void)registerPushNotificationTokenWithDeviceToken:(NSData *)deviceToken
{

#if TARGET_IPHONE_SIMULATOR
#else
    [self.APIClient sendProviderDeviceToken:deviceToken success:^(NSString *token) {
        
        NSLog(@"Success: %@", token);
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
#endif
    
}

- (void)setAPIClient:(APIClient *)APIClient
{
    _APIClient = APIClient;
}
@end
