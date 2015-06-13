//
//  MemberListViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISearchBar *tfSearch;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)btnQRcode:(UIBarButtonItem *)sender;

@end
