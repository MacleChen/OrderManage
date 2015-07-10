//
//  MebManageViewController.h
//  OrderManage
//
//  Created by mac on 15/6/5.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Global.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"
#import "CustomIOS7AlertView.h"
#import "GetMoneyViewController.h"
#import "QRCodeViewController.h"

// 储值卡
#define TF_CARDID_TAG 50

// 充值
#define RECHANGE_VIEW_TAG 101
#define RECHANGE_VIEW_Type_TAG 1011
#define RECHANGE_VIEW_Money_TAG 1012
#define RECHANGE_VIEW_GiveMoney_TAG 1013
// 挂失
#define LOSS_VIEW_TAG 102
#define LOSS_VIEW_Content_TAG 1021

// 新增卡
#define ADDCARD_VIEW_TAG 103
#define ADDCARD_VIEW_Type_TAG 1031
#define ADDCARD_VIEW_CardID_TAG 1032
#define ADDCARD_VIEW_CardMoney_TAG 1033

// 修改密码
#define MODIFYPWDCARD_VIEW_TAG 104
#define MODIFYPWDCARD_VIEW_Old_TAG 1041
#define MODIFYPWDCARD_VIEW_New_TAG 1042
#define MODIFYPWDCARD_VIEW_Sure_TAG 1043

// 修改资料
#define MODIFYINFO_VIEW_TAG 105
#define MODIFYINFO_VIEW_Name_TAG 1051
#define MODIFYINFO_VIEW_Email_TAG 1052
#define MODIFYINFO_VIEW_Phone_TAG 1053
#define MODIFYINFO_VIEW_Address_TAG 1054
#define MODIFYINFO_VIEW_birday_TAG 1055

// 补卡
#define MAKEUPCARD_VIEW_TAG 106

// 退卡
#define CANCELCARD_VIEW_TAG 107
#define CANCELCARD_VIEW_CardID_TAG 1071
#define CANCELCARD_VIEW_ReMoney_TAG 1072

// 卡升级
#define UPGRADECARD_VIEW_TAG 108
#define UPGRADECARD_VIEW_OldCID_TAG 1081
#define UPGRADECARD_VIEW_Type_TAG 1082
#define UPGRADECARD_VIEW_NewCID_TAG 1083
#define UPGRADECARD_VIEW_Money_TAG 1084

@interface MebManageViewController : UIViewController <CustomIOS7AlertViewDelegate, UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UISearchBar *tfSearch;
@property (strong, nonatomic) NSDictionary *ReceDict; // 接收其它界面的传递数据

@property (strong, nonatomic) NSDictionary *dictSearchMebInfo;  // 查询到的会员信息


@property (weak, nonatomic) IBOutlet UITextField *tfCardID;         // 显示选择卡
@property (weak, nonatomic) IBOutlet UILabel *lbCardID;             // 储值卡号
@property (weak, nonatomic) IBOutlet UILabel *lbName;               // 会员姓名
@property (weak, nonatomic) IBOutlet UILabel *lbCard_discount;      // 卡类/折扣
@property (weak, nonatomic) IBOutlet UILabel *lbRemain_Times;       // 余额/余次
@property (weak, nonatomic) IBOutlet UILabel *lbCredits;            // 积分
@property (weak, nonatomic) IBOutlet UILabel *lbphoneNUM;           // 手机
@property (weak, nonatomic) IBOutlet UILabel *lbBirday;             // 生日
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;            // 地址

@property (weak, nonatomic) IBOutlet UIButton *makeup;


@property (weak, nonatomic) UIDatePicker *datePicker;           //  时间滚轴
@property (weak, nonatomic) UIPickerView *pickerViewCardType;   //  数据滚轴
@property (weak, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图

@property (strong, nonatomic) CustomIOS7AlertView *alertShow;
@property (strong, nonatomic) UIView *viewInAlert;    // 显示在alertview中的view

// alertView 中对应的属性
// 充值
@property (weak, nonatomic) UITextField *tfReChange_Type;
@property (weak, nonatomic) UITextField *tfReChange_Money;
@property (weak, nonatomic) UITextField *tfReChange_GiveMoney;

// 挂失
@property (weak, nonatomic) UILabel *lbLoss_Content;

// 新增卡
@property (weak, nonatomic) UITextField *tfAddCard_Type;
@property (weak, nonatomic) UITextField *tfAddCard_CardID;
@property (weak, nonatomic) UITextField *tfAddCard_Money;

// 修改密码
@property (weak, nonatomic) UITextField *tfModifyPwd_OldPwd;
@property (weak, nonatomic) UITextField *tfModifyPwd_NewPwd;
@property (weak, nonatomic) UITextField *tfModifyPwd_SurePwd;

// 修改资料
@property (weak, nonatomic) UITextField *tfModifyInfo_Name;
@property (weak, nonatomic) UITextField *tfModifyInfo_Email;
@property (weak, nonatomic) UITextField *tfModifyInfo_Phone;
@property (weak, nonatomic) UITextField *tfModifyInfo_Address;
@property (weak, nonatomic) UITextField *tfModifyInfo_Birday;

// 补卡

// 退卡
@property (weak, nonatomic) UILabel *lbCancelCard_CardID;
@property (weak, nonatomic) UILabel *lbCancelCard_ReMoney;

// 卡升级
@property (weak, nonatomic) UITextField *tfUpdateCard_OldCID;
@property (weak, nonatomic) UITextField *tfUpdateCard_Type;
@property (weak, nonatomic) UITextField *tfUpdateCard_NewCID;
@property (weak, nonatomic) UITextField *tfUpdateCard_Money;


- (IBAction)btnAddMember:(UIBarButtonItem *)sender;
- (IBAction)btnQRCode:(UIButton *)sender;
- (IBAction)btnSearchInfo:(UIButton *)sender;
- (IBAction)btnRechange:(UIButton *)sender;
- (IBAction)btnModifyInfo:(UIButton *)sender;
- (IBAction)btnLoss:(UIButton *)sender;
- (IBAction)btnMakeupCard:(UIButton *)sender;
- (IBAction)btnAddCard:(UIButton *)sender;
- (IBAction)btnCancelCard:(UIButton *)sender;
- (IBAction)btnModifyPwdCard:(UIButton *)sender;
- (IBAction)btnUpgradeCard:(UIButton *)sender;

@end
