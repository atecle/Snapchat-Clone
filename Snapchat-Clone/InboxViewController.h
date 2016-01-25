//
//  InboxViewController.h
//  Snapchat-Clone
//
//  Created by Adam on 1/20/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "InboxTableCell.h"
#import "APIClient.h"
#import "SnapView.h"


extern NSString * const InboxViewControllerIdentifier;

@interface InboxViewController : UIViewController

- (void)setAPIClient:(APIClient *) APIClient;
- (void)setUser:(User *)user;

@end
