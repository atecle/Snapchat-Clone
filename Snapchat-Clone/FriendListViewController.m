//
//  FriendListViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "FriendListViewController.h"

@interface FriendListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (copy, nonatomic) NSArray *friends;

@end

@implementation FriendListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friends = @[];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FriendTableCell class]) bundle:nil] forCellReuseIdentifier:FriendTableCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FriendTableCellIdentifier];
    
    [cell configureForUser:[self.friends objectAtIndex:indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

@end
