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

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImageView;

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
    self.usernameLabel.text = user.username;
    
}

@end
