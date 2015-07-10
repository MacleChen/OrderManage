//
//  CreditsMgViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Global.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"

@interface CreditsMgViewController : UIViewController  <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *tfSearch;
@property (strong, nonatomic) NSDictionary *ReceDict; // 接收其它界面的传递数据

@property (strong, nonatomic) NSDictionary *dictSearchMebInfo;  // 查询到的会员信息


@property (weak, nonatomic) IBOutlet UITextField *tfInputCredits;   // 输入积分
@property (weak, nonatomic) IBOutlet UITextField *tfSelectCredits;  // 选择积分
@property (weak, nonatomic) IBOutlet UILabel *lbCardID;             // 储值卡号
@property (weak, nonatomic) IBOutlet UILabel *lbName;               // 会员姓名
@property (weak, nonatomic) IBOutlet UILabel *lbCard_discount;      // 卡类/折扣
@property (weak, nonatomic) IBOutlet UILabel *lbRemain_Times;       // 余额/余次
@property (weak, nonatomic) IBOutlet UILabel *lbCredits;            // 积分
@property (weak, nonatomic) IBOutlet UILabel *lbphoneNUM;           // 手机
@property (weak, nonatomic) IBOutlet UILabel *lbBirday;             // 生日


@property (nonatomic,strong) AVCaptureSession *captureSession;    //输入设备捕获数据流
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;  //展示被捕获的数据流

@property (weak, nonatomic) UIPickerView *pickerViewCardType;   //  数据滚轴
@property (strong, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图


- (IBAction)btnQRCode:(UIButton *)sender; // 扫一扫
- (IBAction)btnSearchInfo:(UIButton *)sender; // 查询
- (IBAction)btnAddCreidtsClick:(UIButton *)sender;  // 增加积分
- (IBAction)btnDeductClick:(UIButton *)sender; // 扣除积分



@end
