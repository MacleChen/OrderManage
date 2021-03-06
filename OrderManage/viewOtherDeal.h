//
//  viewOtherDeal.h
//  OrderManage
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PHONENUMCOUNT 11

#define TOP_MENU_HEIGHT 20

#define MenuAddNotificationHeight 44+20

#define MenuBottomToolHeight 44

#define ITEM_IMAGE_CGSZE CGSizeMake(26, 26)

// 系统主色调
#define ColorMainSystem [UIColor colorWithRed:54/255.0 green:120/255.0 blue:64/255.0 alpha:1.0]

#define ColorTableCell [UIColor colorWithRed:204/255.0 green:255/255.0 blue:230/255.0 alpha:1.0]

@interface viewOtherDeal : UIView


+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
+ (void)showAlert:(NSString *)title Mess:(NSString *)mess TimeInterval:(float)timeValue;
+ (void)timerFireMethod:(NSTimer*)theTimer;
+ (BOOL)isValidateEmail:(NSString *)email;

+ (NSString *)NowInTextFiledText:(UITextField *)textField NowStrChar:(NSString *)string;

// 将字典或者数组转化为JSON串
+ (NSData *)toJSONData:(id)theData;

//通过对象返回一个NSDictionary，键是属性名称，值是属性值。
+ (NSDictionary*)getObjectData:(id)obj;

//将getObjectData方法返回的NSDictionary转化成JSON
+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;

//直接通过NSLog输出getObjectData方法返回的NSDictionary
+ (void)print:(id)obj;

@end
