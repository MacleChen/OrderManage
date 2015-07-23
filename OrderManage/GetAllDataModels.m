//
//  GetAllDataModels.m
//  OrderManage
//
//  Created by mac on 15/7/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "GetAllDataModels.h"

@implementation GetAllDataModels

@end


/*
 * 获取到付款页面的model
 */
@implementation GetMoneyReceDataModel

/**
 * 初始化解数组数据包
 */
- (instancetype)initWithArrayPackBag:(NSArray *)arrayData {
    GetMoneyReceDataModel *getmoney = [[GetMoneyReceDataModel alloc] init];
    
    
    return getmoney;
}

/**
 * 初始化解字典数据包
 */
- (instancetype)initWithDictionaryPackBag:(NSDictionary *)dictData {
    GetMoneyReceDataModel *getmoney = [[GetMoneyReceDataModel alloc] init];
    
    dictData = [dictData objectForKey:@"cus"];
    
    getmoney.strName = [dictData objectForKey:@"cuname"];
    getmoney.strEmail = [dictData objectForKey:@"cuemail"];
    getmoney.strpassWord = [dictData objectForKey:@"cupwd"];
    getmoney.strPhone = [dictData objectForKey:@"cumb"];
    getmoney.strAddress = [dictData objectForKey:@"cuaddress"];
    getmoney.strCardno = [dictData objectForKey:@"cucardid"];
    getmoney.strcubDate = [dictData objectForKey:@"cucdate_str"];
    getmoney.strCardTypeID = [dictData objectForKey:@"cardtypeid"];

    return getmoney;
}

/**
 *  打包数据
 */
- (NSDictionary *)getDictionaryPackBag {
    NSDictionary *dict = @{@"cuname": self.strName,
                           @"cuemail": self.strEmail,
                           @"cupwd": self.strpassWord,
                           @"cuphone": self.strPhone,
                           @"cuaddress": self.strAddress,
                           @"cucardid": self.strCardid,
                           @"cucardno": self.strCardno,
                           @"cubdate": self.strcubDate,
                           @"selcardmoney": self.strSelcardMoney,
                           @"selcardtype": self.strSelcardType};
    return dict;
}

@end



/*
 * 获取到付款页面的model
 */
@implementation GetPayBillViewModel

/**
 * 初始化解数组数据包
 */
- (instancetype)initWithArrayPackBag:(NSArray *)arrayData {
    GetPayBillViewModel *getpay = [[GetPayBillViewModel alloc] init];
    
    
    return getpay;
}

/**
 * 初始化解字典数据包
 */
- (instancetype)initWithDictionaryPackBag:(NSDictionary *)dictData {
    GetPayBillViewModel *getpay = [[GetPayBillViewModel alloc] init];
    
    
    return getpay;
}

/**
 *  打包数据
 */
- (NSDictionary *)getDictionaryPackBag {
    NSDictionary *dict = [[NSDictionary alloc] init];
    
    return dict;
}

@end
