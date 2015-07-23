//
//  PayBillViewController.h
//  OrderManage
//
//  Created by mac on 15/6/21.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"
#import "QCheckBox.h"
#import "GCDAsyncSocket.h"

@interface PayBillViewController : UIViewController <CustomIOS7AlertViewDelegate>

@property (strong, nonatomic) NSArray *arrayRecData;   // 接收上一个界面传递的数据
@property (strong, nonatomic) NSDictionary *dictSelectMeterCard; // 所选的计次卡
@property (strong, nonatomic) NSDictionary *dictSearchMebInfo;  // 查询到的会员信息

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lbCustomCount;

@property (strong, nonatomic) CustomIOS7AlertView *alertShow;  // 对话窗口
@property (strong, nonatomic) UIView *paySuccessViewInAlert;   // 支付成功后是否打印单据
@property (weak, nonatomic) QCheckBox *ckPrintList;         // 打印单据

@property (weak, nonatomic) UIPickerView *pickerViewData;   //  数据滚轴
@property (strong, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图

// 结算扣次弹出界面
@property (strong, nonatomic) UIView *viewPayCalculate;             // 结算扣次界面
@property (weak, nonatomic) UITextField *tfPayCalPwd;               // 交易密码
@property (weak, nonatomic) UITextField *tfPayCalPrivilegeCount;    // 优惠次数
@property (weak, nonatomic) UITextField *tfPayCalBussMan;           // 业务员

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;   // 网络连接打印机

- (IBAction)itemBtnClearClick:(UIBarButtonItem *)sender;
- (IBAction)btnSurePayBillClick:(UIButton *)sender;

@end
