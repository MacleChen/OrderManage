//
//  POSDeviceViewController.h
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCheckBox.h"

@interface POSDeviceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *tfuserID;
@property (weak, nonatomic) IBOutlet UITextField *tfuserTerminalID;
@property (weak, nonatomic) IBOutlet UITextField *tfPOSType;

@property (weak, nonatomic) QCheckBox *ckProduct;
@property (weak, nonatomic) QCheckBox *cktest;

- (IBAction)barBtnSyncClick:(UIBarButtonItem *)sender;
- (IBAction)btnSetInfoClick:(UIButton *)sender;


@end
