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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
