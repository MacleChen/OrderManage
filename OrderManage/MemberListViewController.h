//
//  MemberListViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Global.h"
#import "PullTableView.h"

@interface MemberListViewController : UITableViewController

@property (strong, nonatomic) UISearchBar *Searchbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnItemQRcode;

@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

@property (weak, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图

- (IBAction)btnQRcode:(UIBarButtonItem *)sender;

@end
