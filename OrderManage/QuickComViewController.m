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

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface QuickComViewController () <UISearchBarDelegate>

@end

@implementation QuickComViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置代理
    self.tfSearchbar.delegate = self;
}


- (IBAction)btnQRCode:(UIButton *)sender {
}

- (IBAction)btnSearch:(UIButton *)sender {
    [self searchBarSearchButtonClicked:nil];
}

- (IBAction)btnSureClick:(UIButton *)sender {
    [self SubmitWebResponseData]; // 发送网络数据
}


#pragma mark - UISearchBarDelegate 的代理方法的实现
#pragma mark - 当点击键盘上的搜索按钮时调用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 判断输入不能为空
    if ([self.tfSearchbar.text isEqual:@""]) {
        [MBProgressHUD show:@"请输入查询内容" icon:nil view:nil];
        return;
    }
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerGetAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&keyword=%@", [dictLogin objectForKey:@"groupid"], self.tfSearchbar.text];
    
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
                NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
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
                self.lbRemain_time.text = [dictTempData objectForKey:@"lostmoney"];
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


// 发送网络请求数据
- (void)SubmitWebResponseData {
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBSaleFastSaleAction];
//    NSString *strHttpBody = [NSString stringWithFormat:@"tov.groupid=%@&tov.shopid=%@&empid=%@&tov.recordcount=%@&tov.total=%@&tov.cash=%@&tov.market=%@&tov.cardsale=%@&tov.topup=%@&tov.given=%@&tov.unionpay=%@", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"shopid"], [dictLogin objectForKey:@"empid"], self.lbAllBillCount.text, self.lbAllSellMoney.text, self.lbCurrMoney.text, self.lbMarketCash.text, self.lbSavCard.text, self.lbMebRechange.text, self.lbFreeMoney.text, self.lbUnionCard.text];
//    
//    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
//        if (data) { // 请求成功
//            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//            NSString *strStatus = [listData objectForKey:statusCdoe];
//            // 数据异常
//            if(strStatus == nil){
//                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
//                return;
//            }
//            if ([strStatus intValue] == 200) { // 获取正确的数据
//                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
//            } else { // 数据有问题
//                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
//            }
//        } else { // 请求失败
//            [MBProgressHUD show:ConnectException icon:nil view:nil];
//        }
//        
//    }];
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
