//
//  InboxViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/20/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "InboxViewController.h"

NSString * const InboxViewControllerIdentifier = @"InboxViewController";

@interface InboxViewController () <ContainedViewController, UITableViewDataSource, UITableViewDelegate, SnapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) LoadingView *loadingView;
@property (strong, nonatomic) APIClient *APIClient;
@property (copy, nonatomic) NSArray *snaps;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) SnapView *snapView;
@property (nonatomic) BOOL currentlyRetrievingSnaps;
@property (nonatomic) BOOL currentlyViewingSnap;

@end

@implementation InboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self configureSnapView];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InboxTableCell class]) bundle:nil] forCellReuseIdentifier:InboxTableCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Set up

- (void)configureSnapView
{
    self.snapView = [[SnapView alloc] init];
    self.snapView.delegate = self;
    self.snapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.snapView.hidden = YES;
    [self.view addSubview:self.snapView];
    [self addConstraintsToSnapView];
}

- (void)addConstraintsToSnapView
{
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.snapView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.snapView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.snapView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.snapView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self.view addConstraint:topConstraint];
    [self.view addConstraint:bottomConstraint];
    [self.view addConstraint:rightConstraint];
    [self.view addConstraint:leftConstraint];
}

#pragma mark - Networking

- (void)retrieveSnaps
{
    
    if (self.currentlyRetrievingSnaps == NO)
    {
        self.currentlyRetrievingSnaps = YES;
        __block LoadingView *loadingView = [LoadingView loadingViewInView:self.view];
        [loadingView show];
        
        __weak typeof(self) weakSelf = self;
        [self.APIClient retrieveSnapchatsWithSuccess:^(NSArray *snaps)
         {
             __strong typeof (self) self = weakSelf;
             self.snaps = snaps;
             [self.tableView reloadData];
             [loadingView hide];
             self.currentlyRetrievingSnaps = NO;
         } failure:^(NSError *error) {
             __strong typeof(self) self = weakSelf;
             [loadingView hide];
             self.currentlyRetrievingSnaps = NO;
             NSLog(@"%@", error);
         }];
    }
    
}

- (void)markSnapRead:(Snap *)snap
{
    __block Snap *unreadSnap = snap;
    
    __weak typeof(self) weakSelf = self;
    [self.APIClient markSnapchatReadWithID:snap.snapID success:^(Snap *snap) {
        
        __strong typeof (self) self = weakSelf;
        [self replaceUnreadSnap:unreadSnap withReadSnap:snap];
        self.snapView.hidden = YES;
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - UI

- (void)showSnap:(Snap *)snap
{
    [self.snapView setImage:[UIImage imageWithData:snap.imageData]];
    self.snapView.hidden = NO;
    [self.view layoutIfNeeded];
    [self.delegate inboxViewControllerDidShowSnap:self];
}


#pragma mark - SnapViewDelegate

- (void)snapViewDidRecieveTapGesture:(SnapView *)snap
{
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    [self markSnapRead:[self.snaps objectAtIndex:selectedRow.row]];
    [self.delegate inboxViewControllerDidDismissSnap:self];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InboxTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:InboxTableCellIdentifier];
    
    [cell configureForSnap:[self.snaps objectAtIndex:indexPath.row] currentUserID:self.user.userID];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.snaps count];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Snap *snap = [self.snaps objectAtIndex:indexPath.row];
    
    if (snap.fromUserID == self.user.userID || snap.unread == NO) return;
    
    [self showSnap:snap];
}

#pragma mark - ContainedViewController

- (void)didBecomeVisibleViewControllerInMasterViewController:(MasterViewController *)masterViewController
{
    [self retrieveSnaps];
}

#pragma mark - Helpers

- (void)setAPIClient:(APIClient *) APIClient
{
    _APIClient = APIClient;
}

- (void)setUser:(User *)user
{
    _user = user;
}

- (void)replaceUnreadSnap:(Snap *)unreadSnap withReadSnap:(Snap *)readSnap
{
    NSMutableArray *tempSnaps = [self.snaps mutableCopy];
    
    [tempSnaps replaceObjectAtIndex:[tempSnaps indexOfObject:unreadSnap] withObject:readSnap];
    self.snaps = [tempSnaps copy];
    [self.tableView reloadData];
}

@end