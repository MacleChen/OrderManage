//
//  QuickComViewController.m
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "QuickComViewController.h"
#import "viewOtherDeal.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"
#import "QRCodeViewController.h"

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface QuickComViewController () <UISearchBarDelegate, QRCodeViewDelegate, UIAlertViewDelegate> {
    NSDictionary *_dictRecordData;
}

@end

@implementation QuickComViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    _dictRecordData = [NSDictionary dictionary];
    
    // 设置背景图片
    [self.btnSaoyisao setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"saoyisao6.png"] size:CGSizeMake(30, 25)] forState:UIControlStateNormal];
    [self.btnSearch setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"searchBtnImg2.png"] size:CGSizeMake(45, 30)] forState:UIControlStateNormal];
    
    // 设置代理
    self.tfSearchbar.delegate = self;
    
    // 设置键盘类型
    self.tfCardcon.keyboardType = UIKeyboardTypeNumberPad;
    self.tfCashcon.keyboardType = UIKeyboardTypeNumberPad;
    self.tfCashcon.keyboardType = UIKeyboardTypeNumberPad;
    
    // 设置alertview
    self.alertInputPwdView = [[UIAlertView alloc] initWithTitle:@"请输入密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.alertInputPwdView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
}

#pragma mark 扫一扫
- (IBAction)btnQRCode:(UIButton *)sender {
    //切换到下一个界面  --- push
    QRCodeViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeview"];
    viewControl.delegate = self;
    [self.navigationController pushViewController:viewControl animated:YES];
}

- (IBAction)btnSearch:(UIButton *)sender {
    [self searchBarSearchButtonClicked:nil];
}

- (IBAction)btnSureClick:(UIButton *)sender {
    // 判断输入查询
    if ([self.tfSearchbar.text isEqual:@""] || [self.lbCardid.text isEqual:@""]) {
        [MBProgressHUD show:@"请查询会员信息" icon:nil view:nil];
        return;
    }
    
    // 判断输入金额是否为空
    if ([self.tfCardcon.text floatValue] == 0 && [self.tfUnioncon.text floatValue] == 0 &&[self.tfCashcon.text floatValue] == 0 ) {
        [MBProgressHUD show:@"请输入消费金额" icon:nil view:nil];
        return;
    }
    MyPrint(@"%.2f, %.2f", [self.lbRemain_time.text floatValue] , [self.tfCardcon.text floatValue]);
    if ([self.lbRemain_time.text floatValue] < [self.tfCardcon.text floatValue]) {
        [MBProgressHUD show:@"会员卡余额不足" icon:nil view:nil];
        return;
    }
    
    // 输入管理密码
    [self.alertInputPwdView show];
}


#pragma mark - UISearchBarDelegate 的代理方法的实现
#pragma mark - 当点击键盘上的搜索按钮时调用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 判断输入不能为空
    if ([self.tfSearchbar.text isEqual:@""]) {
        [MBProgressHUD show:@"请输入查询内容" icon:nil view:nil];
        return;
    }
    [MBProgressHUD showMessage:@""];
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerGetAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&keyword=%@", [dictLogin objectForKey:@"groupid"], self.tfSearchbar.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 获取数据失败
            if(strStatus == nil){
                [MBProgressHUD show:@"手机号或会员卡号不存在" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
                //_dictRecordData = [dictTempData objectForKey:@""];
                // copy 查询到的会员信息
                dictTempData = [dictTempData objectForKey:@"cus"];
                self.dictResponseData = dictTempData;
                
                // 表示该该卡已被退卡
                if([[dictTempData objectForKey:@"cucardid"] isEqual:@"无"]) {
                    [MBProgressHUD show:@"该手机号未绑定会员卡" icon:nil view:nil];
                    // 清空显示信息
                    self.lbCardid.text = @"";
                    self.lbRemain_time.text = @"";
                    self.lbCredits.text = @"";
                    self.lbCdType_discount.text = @"";
                    self.lbName.text = @"";
                    self.lbphoneNum.text = @"";
                    self.lbbirday.text = @"";
                    self.lbAddress.text = @"";
                    return;
                }
                
                // 设置显示信息
                self.lbCardid.text = [dictTempData objectForKey:@"cucardid"];
                self.lbRemain_time.text = [dictTempData objectForKey:@"cumoney"];
                self.lbCredits.text = [dictTempData objectForKey:@"cuinter"];
                self.lbCdType_discount.text = [NSString stringWithFormat:@"%@/%@", [dictTempData objectForKey:@"cardname"], [dictTempData objectForKey:@"cdpec"]];
                self.lbName.text = [dictTempData objectForKey:@"cuname"];
                self.lbphoneNum.text = [dictTempData objectForKey:@"cumb"];
                self.lbbirday.text = [dictTempData objectForKey:@"cubdate_str"];
                self.lbAddress.text = [dictTempData objectForKey:@"cuaddress"];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
    
    
}

#pragma mark - alertView 的代理方法的实现
#pragma mark 点击按钮时调用
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // 取消
        MyPrint(@"取消");
        return;
    }
    
    MyPrint(@"确认");
    // 判断输入密码是否正确
    UITextField *tfInputPwdTemp = [self.alertInputPwdView textFieldAtIndex:0];
    [self CheckPasswordIsValid:tfInputPwdTemp.text];
}

#pragma mark 判断输入密码是否正确
- (void)CheckPasswordIsValid:(NSString *)strPwd {
    // 网络请求
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerCheckPwd];
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&cus.cupwd=%@", [self.dictResponseData objectForKey:@"cuid"], strPwd];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                //[MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
                // 输入密码正确
                // 数据提交并支付
                [self SubmitWebResponseData];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

// 点击确认后，并且输入密码正确后，调用网络数据请求 并进行支付功能
- (void)SubmitWebResponseData {
    // 支付 --  会员卡支付， 银联支付，  现金支付
    if ([self.tfCardcon.text floatValue] > 0.0 || [self.tfUnioncon.text floatValue] > 0.0 || [self.tfCashcon.text floatValue] > 0.0) {
       NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBSaleFastSale];
       NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&password=%@&unionpayno=%@&emp.empid=%@&cardsale=%@&moneysale=%@&banksale=%@", [self.dictResponseData objectForKey:@"cuid"], (UITextField *)[self.alertInputPwdView textFieldAtIndex:0].text, @"", [dictLogin objectForKey:@"empid"], self.tfCardcon.text, self.tfCashcon.text, self.tfUnioncon.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
                [self btnSearch:nil];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
    }
}

#pragma mark QRCodeviewdelegate
- (void)QRCodeViewBackString:(NSString *)QRCodeSanString {
    self.tfSearchbar.text = QRCodeSanString;
    [self searchBarSearchButtonClicked:nil];
}

#pragma mark 点击背景退出键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
