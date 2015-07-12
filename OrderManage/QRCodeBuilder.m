//
//  QRCodeBuilder.m
//  tabedApplication
//
//  Created by mac on 15/7/11.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "QRCodeBuilder.h"
#import "QRCodeGenerator.h"
#import "qrencode.h"

#define qrMargin 5

@implementation QRCodeBuilder

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
    unsigned char *data = 0;
    int width;
    data = code->data;
    width = code->width;
    float zoom = (double)size / (code->width + 2.0 * qrMargin);
    CGRect rectDraw =CGRectMake(0, 0, zoom, zoom);
    
    CGContextSetFillColor(ctx,CGColorGetComponents([UIColor blackColor].CGColor));
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin =CGPointMake((j + qrMargin) * zoom,(i +qrMargin) * zoom);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size {
    if (![string length]) {
        return nil;
    }
    
    QRcode *code =QRcode_encodeString([string UTF8String], 0,QR_ECLEVEL_L, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    
    // create context
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx =CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace,kCGImageAlphaPremultipliedLast);
    
    CGAffineTransform translateTransform =CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransform =CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(ctx,CGAffineTransformConcat(translateTransform, scaleTransform));
    
    // draw QR on this context
    [QRCodeGenerator drawQRCode:code context:ctx size:size];
    
    // get image
    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
    UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
    
    QRcode_free(code);
    
    return qrImage;
}


+ (UIImage *) twoDimensionCodeImage:(UIImage *)twoDimensionCode withAvatarImage:(UIImage *)avatarImage{
    // two-dimension code 二维码
    CGSize size = twoDimensionCode.size;
    CGSize size2 =CGSizeMake(1.0 / 5.5 * size.width, 1.0 / 5.5 * size.height);
    
    UIGraphicsBeginImageContext(size);
    
    [twoDimensionCode drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [[self avatarImage:avatarImage] drawInRect:CGRectMake((size.width - size2.width) / 2.0, (size.height - size2.height) / 2.0, size2.width, size2.height)];
    
    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (UIImage *) avatarImage:(UIImage *)avatarImage{
    UIImage * avatarBackgroudImage = [UIImage imageNamed:@"psb.png"];
    CGSize size = avatarBackgroudImage.size;
    UIGraphicsBeginImageContext(size);
    
    [avatarBackgroudImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [avatarImage drawInRect:CGRectMake(10, 10, size.width - 20, size.height - 20)];
    
    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end
