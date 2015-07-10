//
//  QuickComViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface QuickComViewController : UIViewController

@property (strong, nonatomic) NSDictionary *dictResponseData;  // 请求到的网络数据

@property (weak, nonatomic) IBOutlet UISearchBar *tfSearchbar;      // 搜索栏
@property (weak, nonatomic) IBOutlet UITextField *tfCardcon;        // 会员卡消费
@property (weak, nonatomic) IBOutlet UITextField *tfCashcon;        // 现金消费
@property (weak, nonatomic) IBOutlet UITextField *tfUnioncon;       // 银联消费

@property (weak, nonatomic) IBOutlet UILabel *lbCardid;             // 储值卡号
@property (weak, nonatomic) IBOutlet UILabel *lbRemain_time;        // 余额/余次
@property (weak, nonatomic) IBOutlet UILabel *lbCredits;            // 积分
@property (weak, nonatomic) IBOutlet UILabel *lbCdType_discount;    // 卡类/折扣
@property (weak, nonatomic) IBOutlet UILabel *lbName;               // 姓名

@property (weak, nonatomic) IBOutlet UILabel *lbphoneNum;           // 手机
@property (weak, nonatomic) IBOutlet UILabel *lbbirday;             // 生日
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;            // 地址

@property (strong, nonatomic) UIAlertView *alertInputPwdView;       // 输入密码

- (IBAction)btnQRCode:(UIButton *)sender;
- (IBAction)btnSearch:(UIButton *)sender;
- (IBAction)btnSureClick:(UIButton *)sender;




@end
