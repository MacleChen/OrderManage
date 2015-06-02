//
//  viewOtherDeal.m
//  OrderManage
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "viewOtherDeal.h"

@implementation viewOtherDeal

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark 将图片按指定的大小进行缩放
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
// 创建一个bitmap的context
// 并把它设置成为当前正在使用的context
UIGraphicsBeginImageContext(size);
// 绘制改变大小的图片
[img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end
