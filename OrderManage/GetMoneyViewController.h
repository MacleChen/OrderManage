//
//  GetMoneyViewController.h
//  OrderManage
//
//  Created by mac on 15/6/4.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "viewOtherDeal.h"
#import "MBProgressHUD+MJ.h"


@interface GetMoneyViewController : UIViewController

@property (strong, nonatomic) NSDictionary *listDict;   // 注册页面数据
@property (strong, nonatomic) NSDictionary *ReceDict;   // 根据注册页面请求到的数据

@property (weak, nonatomic) IBOutlet UITextField *tfCashpay;        // 现金支付
@property (weak, nonatomic) IBOutlet UITextField *tfUnionpay;       // 银联支付
@property (weak, nonatomic) IBOutlet UITextField *tfCoupons;        // 优惠劵
@property (weak, nonatomic) IBOutlet UITextField *tfGuide1;         // 导购一
@property (weak, nonatomic) IBOutlet UITextField *tfGuide2;         // 导购二

@property (weak, nonatomic) IBOutlet UILabel *lbRecMoney;           // 应收
@property (weak, nonatomic) IBOutlet UILabel *lbPaidMoney;          // 已付
@property (weak, nonatomic) IBOutlet UILabel *lbGapMoney;           // 差额
@property (weak, nonatomic) IBOutlet UILabel *lbOriginMoney;        // 原价
@property (weak, nonatomic) IBOutlet UILabel *lbName;               // 会员姓名
@property (weak, nonatomic) IBOutlet UILabel *lbCard_discount;      // 卡类/折扣
@property (weak, nonatomic) IBOutlet UILabel *lbRemain_Times;       // 余额/余次
@property (weak, nonatomic) IBOutlet UILabel *lbCredits;            // 积分

@property (weak, nonatomic) UILabel *lbInfo;   // 窗口提示信息

@property (weak, nonatomic) UIPickerView *pickerViewCardType;   //  数据滚轴
@property (weak, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图


- (IBAction)btnCashPay:(UIButton *)sender;          // 现金支付点击
- (IBAction)btnUnionpay:(UIButton *)sender;         // 银联支付点击
- (IBAction)btnCoupons:(UIButton *)sender;          // 优惠券点击
- (IBAction)btnSureClick:(UIButton *)sender;        // 确认


@end
