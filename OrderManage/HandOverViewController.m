//
//  HandOverViewController.m
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "HandOverViewController.h"
#import "viewOtherDeal.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface HandOverViewController ()

@end

@implementation HandOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 网路数据请求
    [self GetWebResponseData];
    
}


// 确认
- (IBAction)btnSureClick:(UIButton *)sender {
    [self SubmitWebResponseData];  // 提交数据
    
    if (self.swPrint.on) {
        // 打印单据
    } else {
        // 不打印单据
    }
    
    // 返回上一个界面
    [self.navigationController popViewControllerAnimated:YES];
    
}


// 获取网络数据
- (void)GetWebResponseData {
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBTurnOverTsaleAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"shopid=%@&empid=%@&emp=%@", [dictLogin objectForKey:@"shopid"], [dictLogin objectForKey:@"empid"], [dictLogin objectForKey:@"empname"]];
    
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
                self.dictResponseData = [listData objectForKey:MESSAGE];
                
                // 数据初始化
                NSDictionary *dictTsale = [self.dictResponseData objectForKey:@"tsale"];
                self.lbCashName.text = [dictLogin objectForKey:@"empnickname"];   // 收银员
                self.lbAllBillCount.text = [dictTsale objectForKey:@"recordcount"];  // 总单数
                self.lbAllSellMoney.text = [dictTsale objectForKey:@"total"];   // 总销售额
                self.lbCurrMoney.text = [dictTsale objectForKey:@"cash"];      // 现金
                self.lbUnionCard.text = [dictTsale objectForKey:@"unionpay"];      // 银联卡
                self.lbSavCard.text = [dictTsale objectForKey:@"cardsale"];        // 储蓄卡
                self.lbMarketCash.text = [dictTsale objectForKey:@"market"];     // 商场收银
                self.lbMebRechange.text = [dictTsale objectForKey:@"topup"];    // 会员充值
                self.lbFreeMoney.text = [dictTsale objectForKey:@"given"];      // 赠送金
                
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
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBTurnOVerAddAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"tov.groupid=%@&tov.shopid=%@&empid=%@&tov.recordcount=%@&tov.total=%@&tov.cash=%@&tov.market=%@&tov.cardsale=%@&tov.topup=%@&tov.given=%@&tov.unionpay=%@", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"shopid"], [dictLogin objectForKey:@"empid"], self.lbAllBillCount.text, self.lbAllSellMoney.text, self.lbCurrMoney.text, self.lbMarketCash.text, self.lbSavCard.text, self.lbMebRechange.text, self.lbFreeMoney.text, self.lbUnionCard.text];
    
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
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
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
