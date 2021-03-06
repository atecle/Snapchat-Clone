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

- (void)configureForSnap:(Snap *)snap currentUserID:(NSInteger )currentUserID
{
    
    UIImage *statusImage;
    
    if (snap.fromUserID == currentUserID)
    {
        statusImage = snap.unread ? [UIImage imageNamed:@"red-double-arrow"] : [UIImage imageNamed:@"red-double-arrow-no-fill"];
        self.usernameLabel.text = snap.toUsername;
    }
    else
    {
        statusImage = snap.unread ? [UIImage imageNamed:@"red-filled-circle"] : [UIImage imageNamed:@"empty-red-circle"];
        self.usernameLabel.text = snap.fromUsername;
    }
    
    self.timeLabel.text = [self stringFromDate:snap.createdDate];
    
    [self.seenImageView setImage:statusImage];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *   dateFormatter;
    NSLocale *          enUSPOSIXLocale;
    
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

@end

