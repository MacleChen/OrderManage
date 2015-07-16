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
#import "Global.h"

#define TF_Guide1Tag 30
#define TF_Guide2Tag 40

#define TF_CashpayTag 50
#define TF_UnionpayTag 60
#define TF_CouponsTag 70

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface GetMoneyViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UMSCashierPluginDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSString *_strPaymoney;   // 应付的总钱数
    
    NSMutableArray *_MuarrayGuides;   // 要显示的到导购名称
    NSArray *_arrayGuidesDetail;     // 获取所有导购的详细信息
    
    // POS设备信息
    NSString *_userID;          // 商户ID
    NSString *_userTerminalID;  // 商户终端ID
    NSString *_POSType;         // POS机类型
    BOOL _ckProduct;            // 环境：（是否生产）
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
    if([self.tfCashpay.text floatValue] > 0.0) { // 现金付款
        if([self funcCashPay] != GetMoneyViewPayStateSuccess) {
            [MBProgressHUD show:@"现金支付失败" icon:nil view:nil];
            return;
        };
    }
    
    if([self.tfUnionpay.text floatValue] > 0.0) { // 银联付款
        // 获取易POS设备信息
        if (![self readNSUserDefaults]) {
            [MBProgressHUD show:@"请先设置易POS设备信息" icon:nil view:nil];
            return;
        }
    
        // 判断支付情况
        if([self funcUnionPay] != GetMoneyViewPayStateSuccess) {
            [MBProgressHUD show:@"银联支付失败" icon:nil view:nil];
            return;
        };
    }
    
    if([self.tfCoupons.text floatValue] != 0.0) { // 优惠券支付
        if([self funcCouponsPay] != GetMoneyViewPayStateSuccess) {
            [MBProgressHUD show:@"优惠券支付失败" icon:nil view:nil];
            return;
        };
    }
    
    // 确认支付数据提交到服务器 -- 现金支付 或 优惠券支付
    if([self.tfCashpay.text floatValue] > 0.0 || [self.tfCoupons.text floatValue] != 0.0) {
        [self PostPayMentData];
    }
    
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
    // 获取详细订单信息
    NSDictionary *dictTemp = [self.ReceDict objectForKey:@"record"];
    
   // 1. 下单
    NSString *strPrice = [NSString stringWithFormat:@"%li", (long)[self.tfUnionpay.text integerValue]];
    [UMSCashierPlugin bookOrder:strPrice MerorderId:[dictTemp objectForKey:@"rccode"] MerOrderDesc:@"新增卡" BillsMID:_userID BillsTID:_userTerminalID operator:[dictLogin objectForKey:@"empid"] Delegate:self ProductModel:_ckProduct];
    
    // 2. 下单结果回调 --onUMSBookOrderResult 代理方法
    
    
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


/**
 *  从NSUserDefaults中读取数据
 */
-(BOOL)readNSUserDefaults
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    // 读取数据到登录界面
    _userID = [userDef objectForKey:@"POS_userID"];
    _userTerminalID = [userDef objectForKey:@"POS_userTerminalID"];
    _POSType = [userDef objectForKey:@"POS_POSType"];
    _ckProduct = [userDef boolForKey:@"POS_Product"];
    
    // 判断获取的是否有数据
    if (_userID == nil || _userTerminalID == nil || _POSType == nil) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UMSCashierPluginDelegate的代理方法的实现
#pragma mark 下单结果回调的方法
- (void)onUMSBookOrderResult:(NSDictionary *)dict {
    NSString *orderID = [dict objectForKey:@"orderId"]; // 获取订单ID
    
    if (orderID == nil) {
        [MBProgressHUD show:[dict objectForKey:@"resultInfo"] icon:nil view:nil];
        return;
    }
    
    MyPrint(@"下单成功");
    
    // 3. 订单支付
    [UMSCashierPlugin payOrder:[dict objectForKey:@"orderId"] BillsMID:_userID BillsTID:_userTerminalID WithViewController:self Delegate:self SalesSlipType:[_POSType intValue] PayType:PayType_EPOS ProductModel:_ckProduct];
    
    // 4. 设备激活
    [UMSCashierPlugin setupDevice:_userID BillsTID:_userTerminalID WithViewController:self Delegate:self ProductModel:_ckProduct];
    
    // 5. 设备激活回调 代理方法中： onUMSSetupDevice
}

#pragma mark 设备激活回调
- (void)onUMSSetupDevice:(BOOL)resultStatus resultInfo:(NSString *)resultInfo withDeviceId:(NSString *)deviceId {
    if (resultStatus) {
        MyPrint(@"设备绑定成功");
    } else {
        MyPrint(@"设备绑定失败");
    }
}

#pragma mark 订单支付结果回调
- (void)onPayResult:(PayStatus)payStatus PrintStatus:(PrintStatus)printStatus withInfo:(NSDictionary *)dict {
    NSString *result=@"";
    MyPrint(@"%@", [NSThread currentThread]);
    if (payStatus == PayStatus_PAYSUCCESS) { // 银联支付成功
        MyPrint(@"银联支付成功处理");
        // 清空其它支付方式
        self.tfCashpay.text = @"0.0";
        self.tfCoupons.text = @"0.0";
        
        [self PostPayMentData];
    }
    
    switch (payStatus) {
        case PayStatus_PAYSUCCESS:
            result = @"交易成功";
            break;
        case PayStatus_PAYFAIL:
            result = @"交易失败";
            break;
        case PayStatus_PAYCANCEL:
            result = @"交易取消";
            break;
        case PayStatus_PAYTIMEOUT:
            result = @"交易超时";
        default:
        break; }
    switch (printStatus) {
        case PrintStatus_PRINTSUCCESS:
            [result stringByAppendingString:@"\n打印成功"];
            break;
        case PrintStatus_PRINTFAIL:
            [result stringByAppendingString:@"\n打印失败"];
            break;
        default:
            [result stringByAppendingString:@"\n打印机无纸"];
        break; }
    for(NSString * key in dict)
    {
        result=[result stringByAppendingFormat:@"\n%@", [dict objectForKey:key]];
    }
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"支付结果" message:result delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];

}

#pragma mark 订单查询回调
- (void)onUMSQueryOrder:(NSDictionary *)dict {
    NSString *result = [NSString stringWithFormat:@"订单号:%@\n\
                        订单状态:%@\n\
                        金额:%@\n\
                        银行卡号:%@\n\
                        银行卡名称:%@\n\
                        返回状态:%@\n", [dict objectForKey:@"orderId"], [dict objectForKey:@"payState"], [dict objectForKey:@"amount"], [dict objectForKey:@"bankCardId"], [dict objectForKey:@"bankName"], [dict objectForKey:@"resultStatus"]];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"支付结果" message:result delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark  补发签购单回调
-(void)onUMSSignOrder:(PrintStatus) printStatus message:(NSString *)msg {
    NSString *stringStatus = [[NSString alloc] init];

    switch (printStatus) {
        case PrintStatus_PRINTSUCCESS:
                stringStatus = @"打印成功";
            break;
        case PrintStatus_PRINTFAIL:
            stringStatus = @"打印失败";
            break;
        case PrintStatus_NOPAPER:
            stringStatus = @"打印机无纸";
            break;
        default:
            break;
    }
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"补发签购单" message:stringStatus delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark  打印小票回调
-(void)onUMSPrint:(PaperResult) status {
    NSString *stringStatus = [[NSString alloc] init];
    
    switch (status) {
        case PaperResult_OK:
            stringStatus = @"小票打印成功";
            break;
        case PaperResult_NO_PAPER:
            stringStatus = @"缺纸";
            break;
        case PaperResult_FAIL:
            stringStatus = @"小票打印失败";
            break;
        default:
            break;
    }
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"打印小票" message:stringStatus delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark  获取CSN回调
-(void)onUMSGetCSN:(BOOL)resultStatus withCSN:(NSString *)csn {
    if (resultStatus) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"获取CSN" message:csn delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark 提交支付订单
- (void)PostPayMentData {
    // 获取支付额
    float payMoney = [self.tfCashpay.text floatValue] + [self.tfUnionpay.text floatValue] + [self.tfCoupons.text floatValue];
    
    // 获取详细订单信息
    NSDictionary *dictTemp = [self.ReceDict objectForKey:@"record"];
    
    NSString *strGuide1Empid = @"", *strGuide1Money = @"", *strGuide2Empid = @"", *strGuide2Money = @"";
    // 判断业务员
    if (![self.tfGuide1.text isEqual:@"无"]) {
        strGuide1Empid = self.tfGuide1.accessibilityValue;
        strGuide1Money = [NSString stringWithFormat:@"%.2f", payMoney];
        if (![self.tfGuide2.text isEqual:@"无"]) {
            strGuide2Empid = self.tfGuide2.accessibilityValue;
            strGuide1Money = [NSString stringWithFormat:@"%.2f", payMoney/2];
            strGuide2Money = [NSString stringWithFormat:@"%.2f", payMoney/2];
        }
    } else {
        if (![self.tfGuide2.text isEqual:@"无"]) {
            strGuide2Empid = self.tfGuide2.accessibilityValue;
            strGuide2Money = [NSString stringWithFormat:@"%.2f", payMoney];
        }
    }
    
    
    // 获取网络数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBPayMentAction];

    NSString *strHttpBody = [NSString stringWithFormat:@"empid=%@&rcid=%@&cash=%@&cardsale=%@&freemoney=%@&banksale=%@&marketsale=%@&empids1=%@&empmoneys1=%@&empids2=%@&empmoneys2=%@", [dictLogin objectForKey:@"empid"], [dictTemp objectForKey:@"rcid"], self.tfCashpay.text, @"", self.tfCoupons.text, self.tfUnionpay.text, @"", strGuide1Empid, strGuide1Money, strGuide2Empid, strGuide2Money];
    
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
                [MBProgressHUD show:@"支付成功" icon:nil view:nil];
                // 返回到主界面
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 当视图出现时，调用
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    NSDictionary *titleTextDic;
    titleTextDic = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:FONTSIZE_IPHONE], NSForegroundColorAttributeName:[UIColor blackColor]};
    //self.navigationController.navigationBar.translucent=YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.titleTextAttributes = titleTextDic;
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = ColorMainSystem;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
