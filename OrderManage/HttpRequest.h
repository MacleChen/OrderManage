//
//  HttpRequest.h
//  OrderManage
//
//  Created by mac on 15/5/29.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIImageView+WebCache.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"

#define WEBBASEURL @"http://180.97.81.151/cshop/"           // 测试url
//#define WEBBASEURL @"http://180.97.69.100/cshop_jspay/" //外网测试服务




// 登录
#define WEBLoginAction @"emp!login.action?"                 // 验证登录信息

// 会员注册
#define WEBFindCardAction @"newcard!findcard.action?"       // 查找卡的类型
#define WEBNewCardNumAction @"newcard!cardnum.action?"      // 获取最新的卡号
#define WEBCustomerAddAction @"customer!add.action?"        // 增加用户信息

// 会员管理
#define WEBCustomerGetAction @"customer!get.action?"                // 获取用户信息
#define WEBTopupActiveAction @"topup!active.action?"                // 会员卡的充值
#define WEBCustomerLockCardAction @"customer!lockcard.action?"      // 会员卡的挂失处理
#define WEBNewCardUpCardAction @"newcard!upcard.action?"            // 新赠卡
#define WEBCustomerChangePwdAction @"customer!changepwd.action?"    // 修改密码
#define WEBCustomerUpdateAction @"customer!update.action?"          // 修改资料
#define WEBNewCardReturnAction @"newcard!returncard.action?"        // 退卡

// 会员列表--网络请求
#define WEBCustomerListAction @"customer!list.action?"              // 获取会员列表信息

#define WEBTurnOverTsaleAction @"turnover!tsale.action?"            // 结算交班 -- 请求数据
#define WEBTurnOVerAddAction @"turnover!add.action?"                // 结算交班 -- 提交数据

// 消费明细
#define WEBRecordListAction @"record!list.action?"      // 消费明细 -- 获取数据列表
#define WEBRecordDetailAction @"record!detail.action?"  // 消费明细》订单明细
#define WEBFindEmp @"emp!findemp.action?"               // 订单明细 》 修改 》获取业务员列表
#define WEBUpRecord @"record!uprecord.action?"          // 订单明细 》 确认修改
#define WEBRecordDestroyAction @"record!destroy.action?"  // 订单明细 》作废

// 快速消费
#define WEBCustomerCheckPwd @"customer!checkpwd.action?"  // 检查输入密码
#define WEBSaleFastSale @"sale!fastsale.action?"          // 确认支付

// 积分管理
#define WEBCustomerGetGifList @"customer!getGiftList.action?" // 获取礼品list
#define WEBCustomerAddCredits @"customer!addinteg.action?"    // 增加积分
#define WEBCustomerSubCredits @"customer!subinteg.action?"    // 扣除积分

// 计次卡
#define WEBCountSalePrdListAction @"countsale!prdlist.action?"  // 计次卡对应的商品列表

#define statusCdoe @"statusCode"     // 数据包的标志
#define MESSAGE    @"message"       // 数据包的数据

// 系统提示
#define ConnectDataError @"获取失败！"
#define ConnectException @"网络繁忙，请稍后重试！"
#define EmptyINPUTERROR @"输入不能为空"

// 网络数据请求类型
#define HttpPOST @"POST"
#define HttpGET  @"GET"

// 网络数据到的数据判断
#define WebDataIsRight 200  // 获取数据正确
#define WebDataIsError 300 // 获取数据错误

typedef void (^Donetask)(NSURLResponse *response, NSData *data, NSError *error);  

@interface HttpRequest : NSObject

+ (NSData *)HttpsyncRequestPostWithURL:(NSString *)stURL;
+ (NSData *)HttpAFNetworkingRequestWithURL:(NSString *)stURL;
+ (id)HttpAFNetworkingRequestWithURL_Two:(NSString *)strURL parameters:(id)param;

+ (void)HttpAFNetworkingRequestBlockWithURL:(NSString *)strURL strHttpBody:(NSString *)body Retype:(NSString *)type willDone:(Donetask)done;


@end
