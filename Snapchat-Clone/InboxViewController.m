//
//  InboxViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/20/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "InboxViewController.h"

NSString * const InboxViewControllerIdentifier = @"InboxViewController";

@interface InboxViewController () <ContainedViewController, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) APIClient *APIClient;
@property (copy, nonatomic) NSArray *snaps;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didBecomeVisibleViewControllerInMasterViewController:(MasterViewController *)masterViewController
{
    NSLog(@"In Inbox VC");
}

- (void)setAPIClient:(APIClient *) APIClient
{
    _APIClient = APIClient;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InboxTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:InboxTableCellIdentifier];
    
    
    return cell;
    
}


@end
