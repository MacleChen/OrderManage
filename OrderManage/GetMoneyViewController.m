//
//  GetMoneyViewController.m
//  OrderManage
//
//  Created by mac on 15/6/4.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "GetMoneyViewController.h"
#import "UMSCashierPlugin.h"
#import "viewOtherDeal.h"
#import "MBProgressHUD+MJ.h"
#import "HttpRequest.h"

#define TF_Guide1Tag 30
#define TF_Guide2Tag 40

#define TF_CashpayTag 50
#define TF_UnionpayTag 60
#define TF_CouponsTag 70

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface GetMoneyViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
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
    
    
    // 解析数据 -- 获取业务员列表
    _arrayGuidesDetail = [NSArray array];
    _MuarrayGuides = [[NSMutableArray alloc] init];
    
    // 设置代理
    self.tfCashpay.delegate = self;
    self.tfUnionpay.delegate = self;
    self.tfCoupons.delegate = self;
    self.tfGuide1.delegate = self;
    self.tfGuide2.delegate = self;
    
    // 写初始化数据到界面中
    if(self.listDict != nil) {
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
    }
    
    
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
    
    // 设置键盘
    self.tfGuide1.inputView = self.visualEffectView;
    self.tfGuide2.inputView = self.visualEffectView;
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
    // 付款
    if([self.tfCashpay.text floatValue] != 0.0f)
        if([self funcCashPay] == GetMoneyViewPayStateError) {
            [MBProgressHUD show:@"现金支付失败" icon:nil view:nil];
            return;
        };
    
    if([self.tfUnionpay.text floatValue] != 0.0f)
        if([self funcCashPay] == GetMoneyViewPayStateError) {
            [MBProgressHUD show:@"银联支付失败" icon:nil view:nil];
            return;
        };
    
    if([self.tfCoupons.text floatValue] != 0.0f)
        if([self funcCashPay] == GetMoneyViewPayStateError) {
            [MBProgressHUD show:@"优惠券支付失败" icon:nil view:nil];
            return;
        };
    
    // 连接打印机打印
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
    self.pickerViewCardType.tag = textField.tag;
    
    if(textField.tag == TF_Guide1Tag || textField.tag == TF_Guide2Tag) [self GetBussMansList];
    
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
    if (row == 0) {
        return _MuarrayGuides[row];
    }
    
    return [_MuarrayGuides[row] objectForKey:@"empnickname"];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_MuarrayGuides.count > 0) {
        if (pickerView.tag == TF_Guide1Tag) {
            if(row == 0) self.tfGuide1.text = _MuarrayGuides[row];
            else{
                self.tfGuide1.text = [_MuarrayGuides[row] objectForKey:@"empnickname"];
                self.tfGuide1.accessibilityValue = [_MuarrayGuides[row] objectForKey:@"empid"];
            }
        }
        
        if (pickerView.tag == TF_Guide2Tag) {
            if(row == 0) self.tfGuide2.text = _MuarrayGuides[row];
            else {
                self.tfGuide2.accessibilityValue = [_MuarrayGuides[row] objectForKey:@"empid"];
                self.tfGuide2.text = [_MuarrayGuides[row] objectForKey:@"empnickname"];
            }
        }
    }
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

#pragma mark 现金支付方法
- (int)funcCashPay {
    // 现金付款
    return GetMoneyViewPayStateSuccess;
}

#pragma mark 银联支付方法
- (int)funcUnionPay {
    
    
    
    // 银联付款
    return GetMoneyViewPayStateSuccess;
}

#pragma mark 优惠券支付方法
- (int)funcCouponsPay {
    // 优惠劵
    return GetMoneyViewPayStateSuccess;
}

/**
 *  获取业务员列表
 */
- (void)GetBussMansList {
    // 获取业务员的列表
    // 获取网络数据
    // 网络请求
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBFindEmp];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"shopid=%@", [dictLogin objectForKey:@"shopid"]];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 获取数据失败
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                // 解析数据
                [_MuarrayGuides removeAllObjects];
                [_MuarrayGuides addObject:@"无"];
                [_MuarrayGuides addObjectsFromArray:[listData objectForKey:MESSAGE]];
                
                // 重新刷新数据
                [self.pickerViewCardType reloadAllComponents];
                
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
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
