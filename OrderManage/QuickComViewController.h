//
//  QuickComViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickComViewController : UIViewController

@property (strong, nonatomic) NSDictionary *dictResponseData;  // 请求到的网络数据

@property (weak, nonatomic) IBOutlet UISearchBar *tfSearchbar;
@property (weak, nonatomic) IBOutlet UITextField *tfCardcon;
@property (weak, nonatomic) IBOutlet UITextField *tfCashcon;
@property (weak, nonatomic) IBOutlet UITextField *tfUnioncon;

@property (weak, nonatomic) IBOutlet UILabel *lbCardid; // 储值卡号
@property (weak, nonatomic) IBOutlet UILabel *lbRemain_time;       // 余额/余次
@property (weak, nonatomic) IBOutlet UILabel *lbCredits;        // 积分
@property (weak, nonatomic) IBOutlet UILabel *lbCdType_discount;        // 卡类/折扣
@property (weak, nonatomic) IBOutlet UILabel *lbName;       // 姓名

@property (weak, nonatomic) IBOutlet UILabel *lbphoneNum;       // 手机
@property (weak, nonatomic) IBOutlet UILabel *lbbirday;     // 生日
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;            // 地址

- (IBAction)btnQRCode:(UIButton *)sender;
- (IBAction)btnSearch:(UIButton *)sender;
- (IBAction)btnSureClick:(UIButton *)sender;




@end
