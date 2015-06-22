//
//  PayBillViewController.h
//  OrderManage
//
//  Created by mac on 15/6/21.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayBillViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lbCustomCount;

- (IBAction)itemBtnClearClick:(UIBarButtonItem *)sender;
- (IBAction)btnSurePayBillClick:(UIButton *)sender;

@end
