//
//  SwipeContainerViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/28/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SwipeContainerViewController.h"

typedef NS_ENUM(NSInteger, SwipeContainerSwipeDirection)
{
    SwipeDirectionVertical,
    SwipeDirectionHorizontal
};

@interface SwipeContainerViewController ()

@property (nonatomic) SwipeContainerSwipeDirection direction;

@end

@implementation SwipeContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
