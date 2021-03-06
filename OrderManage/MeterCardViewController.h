//
//  MeterCardViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
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
#define TF_METERCARDID_SELECTS_TAG 3021 // 选在计次卡号

@interface MeterCardViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

@property (strong, nonatomic) NSDictionary *dictSearchMebInfo;  // 查询到的会员信息

@property (weak, nonatomic) IBOutlet UIBarButtonItem *itemSearch;   // 搜索按钮属性
@property (weak, nonatomic) IBOutlet UILabel *lbSelectedCount;      // 已选商品个数
@property (weak, nonatomic) IBOutlet UILabel *lbCustemCount;        // 消费次数

@property (weak, nonatomic) IBOutlet UIImageView *imgViewCardIcon;  // 计次卡图标
@property (weak, nonatomic) IBOutlet UILabel *lbCardUserName;       // 计次卡所属用户名
@property (weak, nonatomic) IBOutlet UILabel *lbSelectedRemainCount;// 计次卡剩余次数



@property (strong, nonatomic) CustomIOS7AlertView *alertShow;  // 对话窗口

// 设置搜索窗口属性
@property (strong, nonatomic) UIView *viewSearch;           // 搜索视图界面
@property (weak, nonatomic) UIButton *btnSaoyiSao;          // 扫一扫
@property (weak, nonatomic) UISearchBar *seaBarInput;       // 搜索输入框
@property (strong, nonatomic) UIButton *btnAlertSearch;       // 查询
@property (weak, nonatomic) UILabel *lbMeterCardID;         // 计次卡号
@property (weak, nonatomic) UILabel *lbRemainCount;         // 剩余次数
@property (weak, nonatomic) UILabel *lbCredits;             // 积分
@property (weak, nonatomic) UILabel *lbName;                // 姓名
@property (weak, nonatomic) UILabel *lbPhoneNum;            // 手机
@property (weak, nonatomic) UILabel *lbBirthday;            // 生日
@property (weak, nonatomic) UILabel *lbRegisteAddr;         // 注册地址
@property (weak, nonatomic) UITextField *tfMeterCardIDSelects; // 选择计次卡号

@property (weak, nonatomic) UIPickerView *pickerViewData;   //  数据滚轴
@property (strong, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图



- (IBAction)itemBtnSearchClick:(UIBarButtonItem *)sender;

- (IBAction)btnPayBillClick:(UIButton *)sender;


@end
