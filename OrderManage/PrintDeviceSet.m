//
//  PrintDeviceSet.m
//  OrderManage
//
//  Created by mac on 15/7/13.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "PrintDeviceSet.h"
#import "GCDAsyncSocket.h"


@implementation PrintDeviceSet

/**
 *  打印机初始化
 */
+(void)PrintDeviceInitWithSocket:(GCDAsyncSocket *)socket {
    int byteData = 0;
    
    // 初始化打印机
    Byte PRINT_CODE[9];
    PRINT_CODE[0] = 0x1d;
    PRINT_CODE[1] = 0x68;
    PRINT_CODE[2] = 120;
    PRINT_CODE[3] = 0x1d;
    PRINT_CODE[4] = 0x48;
    PRINT_CODE[5] = 0x10;
    PRINT_CODE[6] = 0x1d;
    PRINT_CODE[7] = 0x6B;
    PRINT_CODE[8] = 0x02;
    
    // 清除字体放大指令
    Byte FD_FONT[3];
    FD_FONT[0] = 0x1c;
    FD_FONT[1] = 0x21;
    FD_FONT[2] = 4;
    // 字体加粗指令
    Byte FONT_B[3];
    FONT_B[0] = 27;
    FONT_B[1] = 33;
    FONT_B[2] = 8;
    // 字体纵向放大一倍
    Byte CLEAR_FONT[3];
    CLEAR_FONT[0] = 0x1c;
    CLEAR_FONT[1] = 0x21;
    CLEAR_FONT[2] = 0;

    // 初始化打印机
    byteData = 27;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 64;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 27;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 103;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 29;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 33;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 2;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    // 字体加粗
    [socket writeData:[NSData dataWithBytes:FONT_B length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 10;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
}

/**
 *  打印完成后做的处理
 */
+ (void)PrintDeviceEndDealWithSocket:(GCDAsyncSocket *)socket {
    int byteData = 0;
    
    // 下面指令为打印完成后自动走纸
    byteData = 27;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 100;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
   
    
    byteData = 4;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    byteData = 10;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    // 切纸初始化
    byteData = 27;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
    // 切纸指令
    byteData = 105;
    [socket writeData:[NSData dataWithBytes:&byteData length:sizeof(Byte)] withTimeout:3 tag:TAG_FIXED_BYTE];
}

@end
