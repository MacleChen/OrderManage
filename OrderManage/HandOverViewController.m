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
#import "Global.h"
#import "PrintDeviceSet.h"

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface HandOverViewController () <GCDAsyncSocketDelegate> {
    NSString *_stringPrintInfo;   // 需要打印的信息
}

@end

@implementation HandOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 网路数据请求
    [self GetWebResponseData];
    
}


// 确认
- (IBAction)btnSureClick:(UIButton *)sender {
   [self SubmitWebResponseData];  // 提交数据
    
    // 判断打印机是否可用
    if (self.swPrint.on) {
        // 设置需要打印的数据
        _stringPrintInfo = [NSString stringWithFormat:@"\
                  收银员交接班\n\
        收银员:                %@\n\
        总单数:                %@\n\
        总销售额:              %@\n\
        现金:                  %@\n\
        银联卡:                %@\n\
        储值卡:                %@\n\
        商场收银:              %@\n\
        会员充值:              %@\n\
        赠送金:                %@\n", self.lbCashName.text, self.lbAllBillCount.text, self.lbAllSellMoney.text, self.lbCurrMoney.text, self.lbUnionCard.text, self.lbSavCard.text, self.lbMarketCash.text, self.lbMebRechange.text, self.lbFreeMoney.text];
        
        // 打印单据
        [self PrintInfoWithString:_stringPrintInfo];
    } else {
        // 不打印单据
        [MBProgressHUD show:@"未打印信息" icon:nil view:nil];
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

/**
 *  打印机打印数据
 */
- (void)PrintInfoWithString:(NSString *)stringInfo {
    NSError *error;
    // 连接对应的IP和端口
    if (![self.asyncSocket connectToHost:WEBPRINT_IP onPort:WEBPRINT_PORT error:&error]) {
        MyPrint(@"error:%@", error);
    }
}


#pragma mark - GCDAsyncSocketDelegate 代理方法的实现
#pragma mark 已连接上网络设备之后调用的方法
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    MyPrint(@"已连接： host:%@, port:%i", host, port);
    
    // 打印机初始化
    [PrintDeviceSet PrintDeviceInitWithSocket:self.asyncSocket];
    
    // 写数据  -- 中文编码 GBK
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *writeData = [_stringPrintInfo dataUsingEncoding:encoding];
    
    [self.asyncSocket writeData:writeData withTimeout:5 tag:TAG_FIXED_LENGTH_HEADER];
    
    // 打印机结束处理
    [PrintDeviceSet PrintDeviceEndDealWithSocket:self.asyncSocket];
    
    [self.asyncSocket disconnect]; // 断开连接
}

#pragma mark 发送TCP/IP数据包
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    MyPrint(@"thread(%@),onSocket:%p didWriteDataWithTag:%ld",[[NSThread currentThread] name], self.asyncSocket, tag);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    MyPrint(@"连接失败：%@", err);
    [self.asyncSocket disconnect]; // 断开连接
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
