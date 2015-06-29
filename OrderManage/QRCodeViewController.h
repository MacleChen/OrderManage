//
//  QRCodeViewController.h
//  OrderManage
//
//  Created by mac on 15/6/27.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QCheckBox.h"

// 设置代理
@protocol QRCodeViewDelegate <NSObject>

@optional
- (void)QRCodeViewBackString:(NSString *)QRCodeSanString;

@end

@interface QRCodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, QCheckBoxDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;    //输入设备捕获数据流
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;  //展示被捕获的数据流
@property (weak, nonatomic) IBOutlet UIView *viewPreview;  // 拍照view
@property (strong, nonatomic) UIView *boxView;  // 扫描框
@property (strong, nonatomic) CALayer *scanLayer;  // 扫描线
@property (nonatomic) BOOL isReading;  // 判断是否正在读

@property (weak, nonatomic) id<QRCodeViewDelegate> delegate;   // 代理

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;    // 底部菜单栏
@property (weak, nonatomic) QCheckBox *ckLight; // 灯


- (IBAction)itemBtnCancelClick:(UIBarButtonItem *)sender;


@end
