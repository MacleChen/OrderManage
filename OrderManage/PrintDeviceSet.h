//
//  PrintDeviceSet.h
//  OrderManage
//
//  Created by mac on 15/7/13.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TAG_FIXED_LENGTH_HEADER   1000  // socket 数据包的头的固定长度
#define TAG_RESPONSE_BODY       1024    // socket 数据包的数据体
#define TAG_FIXED_BYTE 1                // byte 一个字节的传递

@class GCDAsyncSocket;

@interface PrintDeviceSet : NSObject

/**
 *  打印机初始化
 */
+(void)PrintDeviceInitWithSocket:(GCDAsyncSocket *)socket;

/**
 *  打印完成后做的处理
 */
+ (void)PrintDeviceEndDealWithSocket:(GCDAsyncSocket *)socket;

@end
