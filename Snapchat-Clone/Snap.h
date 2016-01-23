//
//  Snap.h
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Snap : NSObject

@property (nonatomic, readonly) NSInteger snapID, fromUserID, toUserID;
@property (strong, nonatomic, readonly) NSString *fromUsername;
@property (strong, nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) BOOL unread;


- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)snapsFromDictionaries:(NSDictionary *)dictionaries;
+ (NSDictionary *)dictionaryFromSnap:(Snap *)user;

@end
