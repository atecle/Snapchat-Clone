//
//  Snap.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "Snap.h"

@implementation Snap

- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init]))
    {
        _snapID = [dictionary[@"id"] integerValue];
        _fromUserID = [dictionary[@"to_user_id"] integerValue];
        _toUserID = [dictionary[@"from_user_id"] integerValue];
        _fromUsername = dictionary[@"from_user"][@"username"];
        
        if ([dictionary[@"image_url"] isKindOfClass:[NSString class]])
        {
            _imageURL = [NSURL URLWithString: dictionary[@"image_url"]];
        }
        
        _unread = [dictionary[@"unread"] boolValue];
    }
    
    return self;
}

+ (NSArray *)snapsFromDictionaries:(NSDictionary *)dictionaries
{
    NSMutableArray *snaps = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaries)
    {
        Snap *snap = [[Snap alloc] initFromDictionary:dictionary];
        [snaps addObject:snap];
    }
    
    return [snaps copy];
}

+ (NSDictionary *)dictionaryFromSnap:(Snap *)user
{
    return nil;
}

@end
