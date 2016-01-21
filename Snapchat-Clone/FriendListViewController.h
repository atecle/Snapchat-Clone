//
//  FriendListViewController.h
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendTableCell.h"

extern NSString * const FriendListViewControllerIdentifier;

@interface FriendListViewController : UIViewController

@property (copy, nonatomic, readonly) UIImage *image;

- (void)setImage:(UIImage *)image;

@end
