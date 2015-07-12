//
//  QRCodeBuilder.h
//  tabedApplication
//
//  Created by mac on 15/7/11.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QRCodeBuilder : NSObject

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size;
+ (UIImage *) twoDimensionCodeImage:(UIImage *)twoDimensionCode withAvatarImage:(UIImage *)avatarImage;

@end
