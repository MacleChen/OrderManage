//
//  OrderDetailTableViewController.h
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@interface OrderDetailTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *dictData; 

@property (strong, nonatomic) IBOutlet UITableView *tableview;


// 会员信息
@property (strong, nonatomic) UIView *viewcuInfo;
@property (weak, nonatomic) UILabel *lbcuName;          //  会员姓名
@property (weak, nonatomic) UILabel *lbcuPhone;         //  会员手机
@property (weak, nonatomic) UILabel *lbcuAddress;       //  会员地址

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

@end
