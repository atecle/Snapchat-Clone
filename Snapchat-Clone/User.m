//
//  User.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initFromDictionary:(NSDictionary *)userDictionary
{
    if ((self = [super init]))
    {
        _userID = [userDictionary[@"id"] integerValue];
        _username = userDictionary[@"username"];
        
    }
    
    return self;
}

+ (NSArray *)usersFromUserDictionaries:(NSDictionary *)userDictionaries
{
    NSMutableArray *users = [NSMutableArray array];
    
    for (NSDictionary *dictionary in userDictionaries)
    {
        User *user = [[User alloc] initFromDictionary:dictionary];
        [users addObject:user];
    }
    
    return [users copy];
    
}

+ (NSDictionary *)dictionaryFromUser:(User *)user
{
    return @{@"id" : [NSNumber numberWithInt: (int)user.userID], @"username": user.username };
}

@end
