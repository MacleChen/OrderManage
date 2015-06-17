//
//  HandOverViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HandOverViewController : UIViewController

@property (strong, nonatomic) NSDictionary *dictResponseData;  // 请求到的网络数据

@property (weak, nonatomic) IBOutlet UILabel *lbCashName;   // 收银员
@property (weak, nonatomic) IBOutlet UILabel *lbAllBillCount;  // 总单数
@property (weak, nonatomic) IBOutlet UILabel *lbAllSellMoney;   // 总销售额
@property (weak, nonatomic) IBOutlet UILabel *lbCurrMoney;      // 现金
@property (weak, nonatomic) IBOutlet UILabel *lbUnionCard;      // 银联卡
@property (weak, nonatomic) IBOutlet UILabel *lbSavCard;        // 储蓄卡
@property (weak, nonatomic) IBOutlet UILabel *lbMarketCash;     // 商场收银
@property (weak, nonatomic) IBOutlet UILabel *lbMebRechange;    // 会员充值
@property (weak, nonatomic) IBOutlet UILabel *lbFreeMoney;      // 赠送金
@property (weak, nonatomic) IBOutlet UISwitch *swPrint;     // 打印单据

- (IBAction)btnSureClick:(UIButton *)sender;


@end
