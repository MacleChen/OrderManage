//
//  GetMoneyViewController.m
//  OrderManage
//
//  Created by mac on 15/6/4.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "GetMoneyViewController.h"

#define TF_Guide1Tag 30
#define TF_Guide2Tag 40

#define TF_CashpayTag 50
#define TF_UnionpayTag 60
#define TF_CouponsTag 70

@interface GetMoneyViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    BOOL _guide1Flg;
    
    NSString *_strPaymoney;   // 应付的总钱数
    
    NSMutableArray *_MuarrayGuides;   // 要显示的到导购名称
    NSArray *_arrayGuidesDetail;     // 获取所有导购的详细信息
}

@end

@implementation GetMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置view的手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleBackgroundTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    
    // 解析数据
    _arrayGuidesDetail = [NSArray array];
    _MuarrayGuides = [[NSMutableArray alloc] init];
    
    if(self.ReceDict != nil) {
        _arrayGuidesDetail = [self.ReceDict objectForKey:@"listemp"];
        for (NSDictionary *tempDict in _arrayGuidesDetail) {
            NSString *strGuideName = [tempDict objectForKey:@"empnickname"];
            [_MuarrayGuides addObject:strGuideName];
        }
    }
    
    // 设置代理
    self.tfCashpay.delegate = self;
    self.tfUnionpay.delegate = self;
    self.tfCoupons.delegate = self;
    self.tfGuide1.delegate = self;
    self.tfGuide2.delegate = self;
    
    // 写初始化数据到界面中
    _strPaymoney = [NSString stringWithString: [self.listDict objectForKey:@"selcardmoney"]];
    self.tfCashpay.text = _strPaymoney;
    self.tfUnionpay.text = @"0.00";
    self.tfCoupons.text = @"0.00";
    self.lbRecMoney.text = self.tfCashpay.text;
    self.lbPaidMoney.text = self.tfCashpay.text;
    self.lbGapMoney.text = @"0.00";
    self.lbOriginMoney.text = self.tfCashpay.text;
        // 设置导购一， 导购二
    self.tfGuide1.text = @"无";
    self.tfGuide2.text = @"无";
    self.lbName.text = [self.listDict objectForKey:@"cuname"];
    self.lbCard_discount.text = [self.listDict objectForKey:@"selcardtype"];
    self.lbRemain_Times.text = @"￥0";
    self.lbCredits.text = @"0";
    
    
    // 设置毛玻璃的背景
    UIVisualEffectView *visEffView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.visualEffectView = visEffView;
    self.visualEffectView.frame = CGRectMake(0, _mainScreenHeight, _mainScreenWidth, 220);
    self.visualEffectView.alpha = 1.0;
    
    // 设置pickerView
    UIPickerView *pickerCardType = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, _mainScreenWidth, 300)];
    self.pickerViewCardType = pickerCardType;
    self.pickerViewCardType.delegate = self;
    self.pickerViewCardType.dataSource = self;
    [self.visualEffectView addSubview:self.pickerViewCardType];
    
    // 设置按钮，点击后退出 datePicker 或 pickerView 选择
    UIButton *btnExitPicker = [[UIButton alloc] initWithFrame:CGRectMake(_mainScreenWidth - 60, 0, 50, 30)];
    btnExitPicker.backgroundColor = ColorMainSystem;
    [btnExitPicker setTitle:@"完成" forState:UIControlStateNormal];
    [btnExitPicker setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnExitPicker addTarget:self action:@selector(btnExitPickerClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.visualEffectView addSubview:btnExitPicker];
    
    // 设置窗口提示信息栏
    UILabel *lb_info = [[UILabel alloc] initWithFrame:CGRectMake(0, MenuAddNotificationHeight, _mainScreenWidth, 20)];
    self.lbInfo = lb_info;
    self.lbInfo.backgroundColor = ColorMainSystem;
    self.lbInfo.textAlignment = UITextAlignmentCenter;
    self.lbInfo.textColor = [UIColor whiteColor];
    self.lbInfo.font = [UIFont systemFontOfSize:12];
    self.lbInfo.hidden = YES;
    [self.view addSubview:self.lbInfo];
    
    [self.view addSubview:_visualEffectView];
    
    // 隐藏显示窗口
    [MBProgressHUD hideHUD];
}


- (IBAction)btnCashPay:(UIButton *)sender {
    self.lbPaidMoney.text = _strPaymoney;
    self.lbGapMoney.text = @"0.00";
    
    self.tfCashpay.text = self.lbPaidMoney.text;
    self.tfUnionpay.text = @"0.00";
    self.tfCoupons.text = @"0.00";
}

- (IBAction)btnUnionpay:(UIButton *)sender {
    self.lbPaidMoney.text = _strPaymoney;
    self.lbGapMoney.text = @"0.00";
    
    self.tfCashpay.text = @"0.00";
    self.tfCoupons.text = @"0.00";
    self.tfUnionpay.text = self.lbPaidMoney.text;
}

- (IBAction)btnCoupons:(UIButton *)sender {
    self.lbPaidMoney.text = _strPaymoney;
    self.lbGapMoney.text = @"0.00";
    
    self.tfCashpay.text = @"0.00";
    self.tfUnionpay.text = @"0.00";
    self.tfCoupons.text = self.lbPaidMoney.text;
}


- (IBAction)btnSureClick:(UIButton *)sender {
    // 连接打印机
    
}

#pragma  mark - textField的代理方法的实现
#pragma mark 正在编辑时调用的方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    float Paymoney = 0.0;
    NSString *strInputText;
    
    if (string.length == 0) {
        if(textField.text.length == 1) textField.text = @"0";
    }
    strInputText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if (textField.tag == TF_CashpayTag) {
        self.tfUnionpay.text =  [NSString stringWithFormat:@"%.2f", [_strPaymoney floatValue] - [strInputText floatValue] - [self.tfCoupons.text floatValue]];
        Paymoney = [self.tfUnionpay.text floatValue] + [strInputText floatValue] + [self.tfCoupons.text floatValue];
        
    }
    if (textField.tag == TF_UnionpayTag) {
        self.tfCashpay.text = [NSString stringWithFormat:@"%.2f", [_strPaymoney floatValue] - [strInputText floatValue] - [self.tfCoupons.text floatValue]];
        Paymoney = [self.tfCashpay.text floatValue] + [strInputText floatValue] + [self.tfCoupons.text floatValue];
    }
    if (textField.tag == TF_CouponsTag) {
        self.tfCashpay.text = [NSString stringWithFormat:@"%.2f", [_strPaymoney floatValue] - [strInputText floatValue] - [self.tfUnionpay.text floatValue]];
        Paymoney = [self.tfCashpay.text floatValue] + [self.tfUnionpay.text floatValue] + [strInputText floatValue];
    }
    
    self.lbPaidMoney.text = [NSString stringWithFormat:@"%.2f", Paymoney];
    self.lbGapMoney.text = [NSString stringWithFormat:@"%.2f", [_strPaymoney floatValue] - Paymoney];
    
    return YES;
}



#pragma mark 当textfield开始编辑时调用
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGRect datepicFrame = self.visualEffectView.frame;

    // 添加动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    if (textField.tag == TF_Guide1Tag || textField.tag == TF_Guide2Tag) {
        [self.view endEditing:YES];
        
        // 设置是否是 导购一点击的输入框
        if (textField.tag == TF_Guide1Tag) _guide1Flg = YES;
        else _guide1Flg = NO;
        
        datepicFrame.origin.y = _mainScreenHeight - datepicFrame.size.height;
    } else {
        datepicFrame.origin.y = _mainScreenHeight;
    }
    
    // 隐藏lbinfo提示窗口
    self.lbInfo.hidden = YES;
    
    self.visualEffectView.frame = datepicFrame;
    [UIView commitAnimations];
    
    if (textField.tag == TF_Guide1Tag || textField.tag == TF_Guide2Tag) return NO;
    return YES;
}



#pragma mark - pickerView代理方法的实现
#pragma mark 设置有多少个组件块
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark 设置每个组件中有多少个row
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _MuarrayGuides.count;
}

#pragma mark 设置每个组件中的row的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return _MuarrayGuides[row];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_guide1Flg) self.tfGuide1.text = _MuarrayGuides[row];
    else self.tfGuide2.text = _MuarrayGuides[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:13]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

#pragma mark 点击picker的完成按钮时调用该方法
- (void)btnExitPickerClick:(UIButton *)sender {
    [self textFieldShouldBeginEditing:self.tfCoupons];
}


#pragma mark 点击背景时，退出键盘
-(void)HandleBackgroundTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
