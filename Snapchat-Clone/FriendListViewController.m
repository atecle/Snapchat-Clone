//
//  FriendListViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "FriendListViewController.h"

NSString * const FriendListViewControllerIdentifier = @"FriendListViewController";

@interface FriendListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *sendSnapView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendSnapButton;

@property (nonatomic) CGFloat sendSnapViewHeight;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) APIClient *APIClient;
@property (strong, nonatomic) User *user;
@property (copy, nonatomic) NSArray *friends;

@end

@implementation FriendListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friends = @[];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    [self hideSendSnapViewAnimated:NO];
    
    
    //UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Test", nil) style:UIBarButtonItemStyleDone target:self action:@selector(hideSendSnapView)];
    // self.navigationItem.rightBarButtonItem = testButton;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FriendTableCell class]) bundle:nil] forCellReuseIdentifier:FriendTableCellIdentifier];
    
    [self retrieveFriends];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)retrieveFriends
{
    __weak typeof(self) weakSelf = self;
    [self.APIClient retrieveFriendsWithSuccess:^(NSArray *friends) {
    
        __strong typeof(self) self = weakSelf;
    
        self.friends = friends;
        [self.tableView reloadData];
    } failure:^(NSError *error)
     {
         NSLog(@"%@", error);
     }];
}

- (void)hideSendSnapViewAnimated:(BOOL)animated
{
    void (^work)() = ^{
        self.sendViewTopLayoutConstraint.constant = -1 * self.sendSnapView.bounds.size.height;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            work();
            [self.view layoutIfNeeded];
        }];
    }
    else
    {
        work();
    }
}

- (void)showSendSnapViewAnimated:(BOOL)animated
{
    void (^work)() = ^{
        self.sendViewTopLayoutConstraint.constant = 0;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            work();
            [self.view layoutIfNeeded];
        }];
    }
    else
    {
        work();
    }
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.tableView indexPathsForSelectedRows] count] == 1)
    {
        [self showSendSnapViewAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.tableView indexPathsForSelectedRows] count] == 0)
    {
        [self hideSendSnapViewAnimated:YES];
    }

}

#pragma mark - User Interaction

- (IBAction)sendSnapButtonPressed:(id)sender
{
    NSArray *friendIDs = [self selectedFriends];

    __weak typeof(self) weakSelf = self;
    [self.APIClient sendSnapchatWithImageURL:nil toUsers:friendIDs withSuccess:^(NSArray *snaps) {
        
        __strong typeof(self) self = weakSelf;
        [self.delegate friendListViewControllerDidSendSnap:self];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Helpers

- (void)setImage:(UIImage *)image
{
    _image = image;
}

- (void)setAPIClient:(APIClient *)APIClient
{
    _APIClient = APIClient;
}

- (void)setUser:(User *)user
{
    _user = user;
}

- (NSArray *)selectedFriends
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSArray *userIDs = @[];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        User *friend = [self.friends objectAtIndex:indexPath.row];
        NSNumber *userID = [NSNumber numberWithInt:(int)friend.userID];
        userIDs = [userIDs arrayByAddingObject:userID];
    }
    
    return userIDs;
}

@end
