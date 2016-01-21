//
//  FriendTableCell.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "FriendTableCell.h"

NSString * const FriendTableCellIdentifier = @"FriendTableCell";

@interface FriendTableCell()

@end

@implementation FriendTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForUser:(User *)user
{
    
}

@end
