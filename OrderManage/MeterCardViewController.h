//
//  MeterCardViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "QCheckBox.h"
#import "CustomIOS7AlertView.h"

#define VIEW_SEARCH_TAG 301             // 搜索界面
#define BTN_SAOYISAO_TAG 3011           // 扫一扫
#define BARSEARCH_TEXTFIELD_TAG 3012    // 搜索输入框
#define BTN_SEARCH_TAG 3013             // 查询
#define LB_METERCARDID_TAG 3014         // 计次卡号
#define LB_REMIANCOUNT_TAG 3015         // 剩余次数
#define LB_CREDITS_TAG 3016             // 积分
#define LB_NAME_TAG 3017                // 姓名
#define LB_PHONE_TAG 3018               // 手机
#define LB_BIRTHDAY_TAG 3019            // 生日
#define LB_REGISTEADDRESS_TAG 3020      // 注册地址

@interface MeterCardViewController : UIViewController 

@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *itemSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbSelectedCount;
@property (weak, nonatomic) IBOutlet UILabel *lbCustemCount;


@property (strong, nonatomic) CustomIOS7AlertView *alertShow;  // 对话窗口

// 设置搜索窗口属性
@property (strong, nonatomic) UIView *viewSearch;           // 搜索视图界面
@property (weak, nonatomic) UIButton *btnSaoyiSao;          // 扫一扫
@property (weak, nonatomic) UISearchBar *seaBarInput;       // 搜索输入框
@property (weak, nonatomic) UIButton *btnAlertSearch;       // 查询
@property (weak, nonatomic) UILabel *lbMeterCardID;         // 计次卡号
@property (weak, nonatomic) UILabel *lbRemainCount;         // 剩余次数
@property (weak, nonatomic) UILabel *lbCredits;             // 积分
@property (weak, nonatomic) UILabel *lbName;                // 姓名
@property (weak, nonatomic) UILabel *lbPhoneNum;            // 手机
@property (weak, nonatomic) UILabel *lbBirthday;            // 生日
@property (weak, nonatomic) UILabel *lbRegisteAddr;         // 注册地址

- (IBAction)itemBtnSearchClick:(UIBarButtonItem *)sender;

- (IBAction)btnPayBillClick:(UIButton *)sender;


@end
