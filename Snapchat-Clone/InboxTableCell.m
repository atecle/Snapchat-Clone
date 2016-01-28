//
//  InboxTableCell.m
//  Snapchat-Clone
//
//  Created by Adam on 1/22/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "InboxTableCell.h"

NSString * const InboxTableCellIdentifier = @"InboxTableCell";

@interface InboxTableCell()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seenImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation InboxTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)configureForSnap:(Snap *)snap currentUserID:(NSInteger )userID
{
    
    UIImage *statusImage;
    
    if (snap.fromUserID == userID)
    {
        statusImage = snap.unread ? [UIImage imageNamed:@"red-double-arrow"] : [UIImage imageNamed:@"empty-red-circle"];
        self.usernameLabel.text = snap.toUsername;
    }
    else
    {
        statusImage = snap.unread ? [UIImage imageNamed:@"red-filled-circle"] : [UIImage imageNamed:@"empty-red-circle"];
        self.usernameLabel.text = snap.fromUsername;

    }
    

    [self.seenImageView setImage:statusImage];
}

@end

