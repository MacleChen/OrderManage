//
//  MBProgressHUD+MJ.h
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (MJ)
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;  // 按时间显示窗口
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;      // 弹出成功显示窗口
+ (void)showError:(NSString *)error toView:(UIView *)view;          // 弹出错误显示窗口

+ (MBProgressHUD *)showMessage:(NSString *)mess toView:(UIView *)view; // 弹出加载和显示信息窗口


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)mess;

+ (void)hideHUDForView:(UIView *)view;  // 隐藏窗口
+ (void)hideHUD;

@end
