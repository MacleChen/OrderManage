//
//  UMSCashierPlugin.h
//  UMSCashierPlugin
//
//  Created by Ning Gang on 14-4-28.
//  Copyright (c) 2014年 UMS. All rights reserved.
//

/*!
 @header   UMSCashierPlugin
 @author   sasha
 @version  1.2.0  2015/01/09
 */

#import <Foundation/Foundation.h>

typedef enum{
    PayStatus_PAYSUCCESS,              //交易成功
    PayStatus_PAYFAIL,                 //交易失败
    PayStatus_PAYTIMEOUT,              //交易超时
    PayStatus_PAYCANCEL,               //交易取消
    
    PayStatus_VOIDSUCCESS,              //撤销成功
    PayStatus_VOIDFAIL,                 //撤销失败
    PayStatus_VOIDTIMEOUT,              //撤销超时
    PayStatus_VOIDCANCEL                //撤销取消
    
}PayStatus;

typedef enum{
    
    PayType_EPOS,           //刷卡支付
    PayType_MOBILE          //POS通支付
    
}PayType;

typedef enum{
    
    SalesSlipType_AUTO,               //根据设备型号决定签购单类型
    SalesSlipType_PAPER,              //纸质签购单
    SalesSlipType_ELECTRONIC          //电子签购单
    
}SalesSlipType;

typedef enum{
    
    PrintStatus_PRINTSUCCESS,             //打印成功
    PrintStatus_PRINTFAIL,                //打印失败
    PrintStatus_NOPAPER                   //打印机无纸
    
}PrintStatus;

typedef enum
{
    PaperResult_OK,     //小票打印成功
    PaperResult_NO_PAPER,  //缺纸
    PaperResult_FAIL     //小票打印失败
}PaperResult;

typedef enum {
    InquiryStatus_SUCCESS,  //余额查询成功
    InquiryStatus_FAIL,     //余额查询失败
    InquiryStatus_CANCEL,   //余额查询取消
    InquiryStatus_TIMEOUT   //余额查询超时
}InquiryStatus;

typedef enum {
    RealNameAuthStatus_SUCCESS, //实名认证成功
    RealNameAuthStatus_FAIL,    //实名认证失败
    RealNameAuthStatus_CANCEL,  //实名认证取消
    RealNameAuthStatus_TIMEOUT  //实名认证超时
}RealNameAuthStatus;

@protocol UMSCashierPluginDelegate <NSObject>

@optional

/*
 orderId    订单号;
 orderTime  订单时间;
 resultStatus  返回状态;
 resultInfo   错误信息;
 memo         备注
 */
//下单结果回调
-(void)onUMSBookOrderResult:(NSDictionary *)dict;

/*
 // 支付成功返回
 acqNo  收单机构号;
 amount 金额;
 batchNo    出账机构批次号;
 billsMID   出账商户号;
 billsMercName 出账商户名;
 billsTID   出账终端号;
 resultStatus    返回状态;
 resultInfo    错误信息;
 expireDate  信用卡有效期;
 issNo  发卡机构号;
 merchantId 受卡方标识码;
 operator 操作员;
 orderId 订单号;
 pAccount 银行卡号;
 refId 索引参考号;
 termId 受卡方终端标识码;
 dealDate 交易日期;
 dealTime 交易时间;
 txnType 交易类型;
 voucherNo 授权码;
 // 支付失败返回
 resultStatus    返回状态;
 resultInfo    错误信息;
 // 支付超时返回
 resultStatus    错误码;
 resultInfo    错误信息;
 // 支付取消不返回结果
 */
//支付结果回调 退货也用此回调
-(void)onPayResult:(PayStatus) payStatus PrintStatus:(PrintStatus) printStatus withInfo:(NSDictionary *)dict;

/*
 orderId    订单号;
 orderState  订单状态;
 payState   支付状态
 amount   订单金额;
 serverTime    服务器时间
 bankCardId    银行卡号
 bankName      银行卡名称
 boxId         盒子号
 resultStatus    返回状态;
 resultInfo    错误信息;
 memo          备注
 */

//订单查询回调
-(void)onUMSQueryOrder:(NSDictionary *)dict;

/*
 printStatus  补发签购单状态
 msg          错误信息
 */

//补发签购单回调
-(void)onUMSSignOrder:(PrintStatus) printStatus message:(NSString *)msg;


/*
 resultStatus  返回状态
 resultInfo    错误信息
 deviceId      设备号
 */
//设备设置，激活回调
-(void)onUMSSetupDevice:(BOOL) resultStatus resultInfo:(NSString *)resultInfo withDeviceId:(NSString *)deviceId;

//打印小票回调
-(void)onUMSPrint:(PaperResult) status;

/*
 resultStatus  返回状态
 resultInfo    错误信息
 csn           CSN号
 */
//获取CSN回调
-(void)onUMSGetCSN:(BOOL)resultStatus withCSN:(NSString *)csn;


@end

/*=================================================================================================================================*/

@interface UMSCashierPlugin : NSObject

//下单
/*
 *  amount 金额，单位为分
 *  merorderId 商户订单号
 *  merOrderDesc 商户订单描述
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  operatorID 操作员号
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void)bookOrder:(NSString*)amount MerorderId:(NSString *)merorderId MerOrderDesc:(NSString *)merOrderDesc BillsMID:(NSString *)billsMID BillsTID:(NSString *) billsTID operator:(NSString *)operatorID Delegate:(id<UMSCashierPluginDelegate>)delegate ProductModel:(BOOL)isProd;

//订单支付
/*
 *  orderId 下单后返回的订单号
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  controller 调用接口的UIViewController
 *  delegate 回调
 *  salesSlipType 签购单类型
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void)payOrder:(NSString *)orderId BillsMID:(NSString *)billsMID BillsTID:(NSString *) billsTID
WithViewController:(UIViewController *)controller Delegate:(id<UMSCashierPluginDelegate>)delegate SalesSlipType:(SalesSlipType) salesSlipType PayType:(PayType)payType ProductModel:(BOOL)isProd;

//订单查询
/*
 *  orderId 下单后返回的订单号
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  delegate 回调
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void)queryOrder:(NSString *)orderId BillsMID:(NSString *)billsMID BillsTID:(NSString *) billsTID Delegate:(id<UMSCashierPluginDelegate>)delegate ProductModel:(BOOL)isProd;


//交易撤销
/*
 *  orderId 下单后返回的订单号
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  controller 调用接口的UIViewController
 *  delegate 回调
 *  salesSlipType 签购单类型
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void)voidPayOrder:(NSString *)orderId BillsMID:(NSString *)billsMID BillsTID:(NSString *) billsTID
 WithViewController:(UIViewController *)controller Delegate:(id<UMSCashierPluginDelegate>)delegate SalesSlipType:(SalesSlipType) salesSlipType ProductModel:(BOOL)isProd;

//设备设置，激活
/*
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  controller 调用接口的UIViewController
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void)setupDevice:(NSString *)billsMID BillsTID:(NSString *) billsTID WithViewController:(UIViewController *)controller Delegate:(id<UMSCashierPluginDelegate>)delegate ProductModel:(BOOL)isProd;


//补发签购单
/*
 *  orderId 下单后返回的订单号
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  controller 调用接口的UIViewController
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void)signOrder:(NSString *)orderId BillsMID:(NSString *)billsMID BillsTID:(NSString *) billsTID WithViewController:(UIViewController *)controller Delegate:(id<UMSCashierPluginDelegate>)delegate SalesSlipType:(SalesSlipType) salesSlipType ProductModel:(BOOL)isProd;


//打印小票
/*
 *  message 打印信息
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void) print:(NSString *)message BillsMID:(NSString *)billsMID BillsTID:(NSString *) billsTID WithViewController:(UIViewController *)controller Delegate:(id<UMSCashierPluginDelegate>)delegate ProductModel:(BOOL)isProd;


//获取CSN
/*
 *  billsMID 出账商户号
 *  billsTID 出账商户终端号
 *  controller 调用接口的UIViewController
 *  delegate 回调
 *  isProd  YES:生产环境 NO:测试环境
 */
+(void) getCSN:(NSString *)billsMID BillsTID:(NSString *)billsTID WithViewController:(UIViewController *)controller Delegate:(id<UMSCashierPluginDelegate>)delegate ProductModel:(BOOL)isProd;




@end
