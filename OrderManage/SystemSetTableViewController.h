//
//  SystemSetTableViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCheckBox.h"

@interface SystemSetTableViewController : UITableViewController


@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) QCheckBox *ckBluePrint;
@property (strong, nonatomic) QCheckBox *ckWebPrint;
@property (strong, nonatomic) QCheckBox *ckPosPrint;

@end
