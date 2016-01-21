//
//  FriendTableCell.h
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

extern NSString * const FriendTableCellIdentifier;

@interface FriendTableCell : UITableViewCell

- (void)configureForUser:(User *)user;

@end
