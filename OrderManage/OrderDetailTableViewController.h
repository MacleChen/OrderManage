//
//  OrderDetailTableViewController.h
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "CustomIOS7AlertView.h"

#define CELL_HEIGHT 40

#define SECTION_ONE_VIEW 201    // 第一个section的view
#define SECTION_ONE_VIEW_LBcuName 2011
#define SECTION_ONE_VIEW_LBcuPhone 2012
#define SECTION_ONE_VIEW_LBcuAddress 2013

#define SECTION_TWO_VIEW 202    // 第二个section的view
#define SECTION_TWO_VIEW_LBTime 2021
#define SECTION_TWO_VIEW_LBMenuType 2022
#define SECTION_TWO_VIEW_LBStatus 2023
#define SECTION_TWO_VIEW_LBNumber 2024
#define SECTION_TWO_VIEW_LBOriginMoney 2025
#define SECTION_TWO_VIEW_LBPayMoney 2026
#define SECTION_TWO_VIEW_LBAlreadyPay 2027
#define SECTION_TWO_VIEW_LBDebtMoney 2028
#define SECTION_TWO_VIEW_LBPayType 2029
#define SECTION_TWO_VIEW_LBBussSaler 2030
#define SECTION_TWO_VIEW_LBUnionMenuId 2031

#define SECTION_TWO_VIEW_BTNModify 2032
#define SECTION_TWO_VIEW_BTNPintNote 2033
#define SECTION_TWO_VIEW_BTNSecondPay 2034
#define SECTION_TWO_VIEW_BTNMenuCancel 2035

#define SECTION_TWO_ModifyView_Tag 205  // 第二个section中修改弹出的view
#define SECTION_TWO_ModifyView_BussineMan1_Tag 2051
#define SECTION_TWO_ModifyView_BussMan1_Money_Tag 2052
#define SECTION_TWO_ModifyView_BussineMan2_Tag 2053
#define SECTION_TWO_ModifyView_bussMan2_Money_Tag 2054

#define SECTION_TWO_CheckNamePwdView_tag 206 // 第二个section中的弹出用户名，密码验证的view
#define SECTION_TWO_CheckNamePwdView_Title_Tag 2061
#define SECTION_TWO_CheckNamePwdView_TFName_Tag 2062
#define SECTION_TWO_CheckNamePwdView_TFPwd_Tag 2063

#define SECTION_TWO_CancelCheckNamePwdView 207

@interface OrderDetailTableViewController : UITableViewController <CustomIOS7AlertViewDelegate>

@property (strong, nonatomic) NSDictionary *dictData;  // 接收上一个界面传递的数据

@property (strong, nonatomic) NSDictionary *dictSaveOrderInfo;  // 存储获取到的订单信息

@property (strong, nonatomic) IBOutlet UITableView *tableview;


// 会员信息
@property (strong, nonatomic) UIView *viewcuInfo;
@property (strong, nonatomic) UILabel *lbcuName;          //  会员姓名
@property (strong, nonatomic) UILabel *lbcuPhone;         //  会员手机
@property (strong, nonatomic) UILabel *lbcuAddress;       //  会员地址

// 订单详情
@property (strong, nonatomic) UIView *viewMenuDetail;
@property (weak, nonatomic) UILabel *lbTime;            //  时间
@property (weak, nonatomic) UILabel *lbMenuType;        //  类型
@property (weak, nonatomic) UILabel *lbStatus;          //  状态
@property (weak, nonatomic) UILabel *lbNumber;          //  数量
@property (weak, nonatomic) UILabel *lbOriginMoney;     //  原价
@property (weak, nonatomic) UILabel *lbPayMoney;        //  应付
@property (weak, nonatomic) UILabel *lbAlreadyPay;      //  已付
@property (weak, nonatomic) UILabel *lbDebtMoney;       //  欠款
@property (weak, nonatomic) UILabel *lbPayType;         //  支付方式
@property (weak, nonatomic) UILabel *lbBussSaler;       //  业务员
@property (weak, nonatomic) UILabel *lbUnionMenuId;     //  银联订单号

@property (weak, nonatomic) UIButton *btnModify;        //  修改
@property (weak, nonatomic) UIButton *btnPintNote;      //  补打小票
@property (weak, nonatomic) UIButton *btnSecondPay;     //  补交款
@property (weak, nonatomic) UIButton *btnMenuCancel;    //  作废

// 修改弹出的view
@property (strong, nonatomic) UIView *ModifyView;
@property (weak, nonatomic) UITextField *tfMdViewBussMan1;          // 业务员1
@property (weak, nonatomic) UITextField *tfMdViewBussMan1Money;     // 业务员1处理金额
@property (weak, nonatomic) UITextField *tfMdViewBussMan2;          // 业务员2
@property (weak, nonatomic) UITextField *tfMdViewBussMan2Money;     // 业务员2处理金额

// 验证用户名，密码弹出的view
@property (strong, nonatomic) UIView *CheckNamePwdView;
@property (weak, nonatomic) UILabel *lbCKViewTitle;                 // 标题
@property (weak, nonatomic) UITextField *tfCKViewName;              // 用户名
@property (weak, nonatomic) UITextField *tfCKViewPassword;          // 密码


@property (strong, nonatomic) CustomIOS7AlertView *alertShow;               // 弹出小窗口

@property (weak, nonatomic) UIPickerView *pickerViewData;   //  数据滚轴
@property (strong, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图


@end
