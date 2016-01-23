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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InboxTableCell class]) bundle:nil] forCellReuseIdentifier:InboxTableCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)retrieveSnaps
{
    __weak typeof(self) weakSelf = self;
    [self.APIClient retrieveSnapchatsWithSuccess:^(NSArray *snaps)
    {
        __strong typeof (self) self = weakSelf;
        self.snaps = snaps;
        [self.tableView reloadData];
    } failure:^(NSError *error)
     {
        NSLog(@"%@", error);
    }];
}

- (void)setAPIClient:(APIClient *) APIClient
{
    _APIClient = APIClient;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InboxTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:InboxTableCellIdentifier];
    
    [cell configureForSnap:[self.snaps objectAtIndex:indexPath.row]];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.snaps count];
}

#pragma  mark - ContainedViewController

- (void)didBecomeVisibleViewControllerInMasterViewController:(MasterViewController *)masterViewController
{
    [self retrieveSnaps];
}

@end