//
//  User.h
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, readonly) NSInteger userID;
@property (strong, nonatomic, readonly) NSString *username;

- (instancetype)initFromDictionary:(NSDictionary *)userDictionary;
+ (NSArray *)usersFromUserDictionaries:(NSDictionary *)userDictionaries;
+ (NSDictionary *)dictionaryFromUser:(User *)user;

@end
