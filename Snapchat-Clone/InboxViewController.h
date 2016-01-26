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

@class InboxViewController;

@protocol InboxViewControllerDelegate <NSObject>

- (void)inboxViewControllerDidShowSnap:(InboxViewController *)inboxViewController;
- (void)inboxViewControllerDidDismissSnap:(id)inboxViewController;

@end
@interface InboxViewController : UIViewController

@property (weak, nonatomic) id<InboxViewControllerDelegate> delegate;

- (void)setAPIClient:(APIClient *) APIClient;
- (void)setUser:(User *)user;

@end
