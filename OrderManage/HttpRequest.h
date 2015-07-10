//
//  HttpRequest.h
//  OrderManage
//
//  Created by mac on 15/5/29.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"

#define WEBBASEURL @"http://180.97.81.151/cshop/"
#define WEBBASEURLTest @"http://180.97.69.100/cshop_jspay/"

#define WEBLoginAction @"emp!login.action?"
#define WEBFindCardAction @"newcard!findcard.action?"
#define WEBNewCardNumAction @"newcard!cardnum.action?"
#define WEBCustomerAddAction @"customer!add.action?"
#define WEBCustomerGetAction @"customer!get.action?"
#define WEBTopupActiveAction @"topup!active.action?"
#define WEBCustomerLockCardAction @"customer!lockcard.action?"
#define WEBNewCardUpCardAction @"newcard!upcard.action?"
#define WEBCustomerChangePwdAction @"customer!changepwd.action?"
#define WEBCustomerUpdateAction @"customer!update.action?"

#define WEBNewCardReturnAction @"newcard!returncard.action?"

// 会员列表--网络请求
#define WEBCustomerListAction @"customer!list.action?"

#define WEBTurnOverTsaleAction @"turnover!tsale.action?"    // 结算交班 -- 请求数据
#define WEBTurnOVerAddAction @"turnover!add.action?"         // 结算交班 -- 提交数据

// 消费明细
#define WEBRecordListAction @"record!list.action?"      // 消费明细 -- 获取数据列表
#define WEBRecordDetailAction @"record!detail.action?"  // 消费明细》订单明细
#define WEBFindEmp @"emp!findemp.action?"               // 订单明细 》 修改 》获取业务员列表
#define WEBUpRecord @"record!uprecord.action?"          // 订单明细 》 确认修改

// 快速消费
#define WEBCustomerCheckPwd @"customer!checkpwd.action?"  // 检查输入密码
#define WEBSaleFastSale @"sale!fastsale.action?"          // 确认支付

// 积分管理
#define WEBCustomerGetGifList @"customer!getGiftList.action?" // 获取礼品list
#define WEBCustomerAddCredits @"customer!addinteg.action?"    // 增加积分
#define WEBCustomerSubCredits @"customer!subinteg.action?"    // 扣除积分

#define statusCdoe @"statusCode"
#define MESSAGE    @"message"
#define ConnectDataError @"获取失败！"
#define ConnectException @"网络繁忙，请稍后重试！"
#define EmptyINPUTERROR @"输入不能为空"

#define HttpPOST @"POST"
#define HttpGET  @"GET"

typedef void (^Donetask)(NSURLResponse *response, NSData *data, NSError *error);  

@interface HttpRequest : NSObject

+ (NSData *)HttpsyncRequestPostWithURL:(NSString *)stURL;
+ (NSData *)HttpAFNetworkingRequestWithURL:(NSString *)stURL;
+ (id)HttpAFNetworkingRequestWithURL_Two:(NSString *)strURL parameters:(id)param;

+ (void)HttpAFNetworkingRequestBlockWithURL:(NSString *)strURL strHttpBody:(NSString *)body Retype:(NSString *)type willDone:(Donetask)done;

@end
