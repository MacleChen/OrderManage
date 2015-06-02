//
//  MainViewController.h
//  OrderManage
//
//  Created by mac on 15/6/1.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "viewOtherDeal.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnItem;




- (IBAction)BarBtnClick:(UIBarButtonItem *)sender;

@end
