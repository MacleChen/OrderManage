//
//  viewOtherDeal.h
//  OrderManage
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PHONENUMCOUNT 11

#define MenuAddNotificationHeight 44+20

// 系统主色调
#define ColorMainSystem [UIColor colorWithRed:54/255.0 green:120/255.0 blue:64/255.0 alpha:1.0]

@interface viewOtherDeal : UIView


+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
+ (void)showAlert:(NSString *)title Mess:(NSString *) message TimeInterval:(float)timeValue;
+ (void)timerFireMethod:(NSTimer*)theTimer;
+ (BOOL)isValidateEmail:(NSString *)email;

@end
