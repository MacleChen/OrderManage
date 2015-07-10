//
//  RegisteViewController.h
//  OrderManage
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Global.h"
#import "viewOtherDeal.h"

@interface RegisteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;


@property (weak, nonatomic) UITextField *tfPhoneNUM;    //  手机号
@property (weak, nonatomic) UITextField *tfEmail;       //  邮箱
@property (weak, nonatomic) UITextField *tfbirthday;    //  会员生日
@property (weak, nonatomic) UITextField *tfcardID;      //  会员卡号
@property (weak, nonatomic) UITextField *tfName;        //  会员姓名
@property (weak, nonatomic) UITextField *tfaddress;     //  会员地址
@property (weak, nonatomic) UITextField *tfpassword;    //  密码
@property (weak, nonatomic) UITextField *tfsurePass;    //  确认密码
@property (weak, nonatomic) UITextField *tfcardType;    //  会员卡类型

@property (weak, nonatomic) UILabel *lbInfo;   // 窗口提示信息

@property (weak, nonatomic) UIDatePicker *datePicker;           //  时间滚轴
@property (weak, nonatomic) UIPickerView *pickerViewCardType;   //  数据滚轴
@property (weak, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图


- (IBAction)btnregisteClick:(UIButton *)sender;

@end
