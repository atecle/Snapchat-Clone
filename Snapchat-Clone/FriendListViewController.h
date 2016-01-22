//
//  FriendListViewController.h
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendTableCell.h"
#import  "APIClient.h"

extern NSString * const FriendListViewControllerIdentifier;

@class FriendListViewController;

@protocol FriendListViewControllerDelegate <NSObject>

- (void)friendListViewControllerDidSendSnap:(FriendListViewController *)friendListViewController;

@end

@interface FriendListViewController : UIViewController

@property (weak, nonatomic) id<FriendListViewControllerDelegate> delegate;

- (void)setImage:(UIImage *)image;
- (void)setUser:(User *)user;
- (void)setAPIClient:(APIClient *)APIClient;

@end
