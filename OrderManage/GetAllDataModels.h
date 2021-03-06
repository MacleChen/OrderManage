//
//  GetAllDataModels.h
//  OrderManage
//
//  Created by mac on 15/7/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetAllDataModels : NSObject

@end


/*
 * 获取到付款页面的model
 */
@interface GetMoneyReceDataModel : NSObject

@property (weak, nonatomic) NSString *strName;          // 姓名
@property (weak, nonatomic) NSString *strEmail;         // 邮箱
@property (weak, nonatomic) NSString *strpassWord;      // 密码
@property (weak, nonatomic) NSString *strPhone;         // 电话
@property (weak, nonatomic) NSString *strAddress;       // 地址
@property (weak, nonatomic) NSString *strCardid;        // 卡的id
@property (weak, nonatomic) NSString *strCardno;        // 卡的号码
@property (weak, nonatomic) NSString *strcubDate;       // 生日
@property (weak, nonatomic) NSString *strSelcardMoney;  // 所选卡的金额
@property (weak, nonatomic) NSString *strSelcardType;   // 所选卡的类型
@property (weak, nonatomic) NSString *strCardTypeID;    // 卡的类型id

/**
 * 初始化解数组数据包
 */
- (instancetype)initWithArrayPackBag:(NSArray *)arrayData;

/**
 * 初始化解字典数据包
 */
- (instancetype)initWithDictionaryPackBag:(NSDictionary *)dictData;

/**
 *  打包数据
 */
- (NSDictionary *)getDictionaryPackBag;

@end


/*
 * 获取到付款页面的model
 */
@interface GetPayBillViewModel : NSObject

@property(nonatomic, assign) int prodid;
@property (weak, nonatomic) NSString *prodname;
@property(nonatomic, assign) int prodcount;
@property(nonatomic, assign) int prodispec;
@property(nonatomic, assign) double prodprice;
@property(nonatomic, assign) int prodpec;
@property(nonatomic, assign) double prodmoney;
@property(nonatomic, assign) int point;
@property(nonatomic, assign) int prodcid;

/**组织商品id*/
@property(nonatomic, assign) int prdid;
@property(nonatomic, assign) double realprice;
@property (weak, nonatomic) NSString *temp;

/**
 * @return the cdid
 */


/**总价*/
@property (weak, nonatomic) NSString *zonge;
/**外卖，预约订单子表id*/
@property (weak, nonatomic) NSString *orderdtid;

/**外卖，预约订单主表id*/
@property (weak, nonatomic) NSString *orderid;
/**外卖，预约，1：外卖，2：预约*/
@property (weak, nonatomic) NSString *ordertype;
/**外卖，预约，订单支付状态，1：已支付，2：未支付*/
@property (weak, nonatomic) NSString *orderstate;


/**
 * 初始化解数组数据包
 */
- (instancetype)initWithArrayPackBag:(NSArray *)arrayData;

/**
 * 初始化解字典数据包
 */
- (instancetype)initWithDictionaryPackBag:(NSDictionary *)dictData;

/**
 *  打包数据
 */
- (NSDictionary *)getDictionaryPackBag;

@end
