//
//  InboxTableCell.h
//  Snapchat-Clone
//
//  Created by Adam on 1/22/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Snap.h"

extern NSString * const InboxTableCellIdentifier;

@interface InboxTableCell : UITableViewCell

- (void)configureForSnap:(Snap *)snap currentUserID:(NSInteger) currentUserID;

@end
