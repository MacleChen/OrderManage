//
//  POSDeviceViewController.h
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCheckBox.h"
#import "UMSCashierPlugin.h"

@interface POSDeviceViewController : UIViewController <UMSCashierPluginDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfuserID;                 // 商户号
@property (weak, nonatomic) IBOutlet UITextField *tfuserTerminalID;         // 商户终端号
@property (weak, nonatomic) IBOutlet UITextField *tfPOSType;                // POS类型

@property (weak, nonatomic) QCheckBox *ckProduct;                           // 生产
@property (weak, nonatomic) QCheckBox *cktest;                              // 测试

@property (weak, nonatomic) UIPickerView *pickerView;   //  数据滚轴
@property (strong, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图

- (IBAction)barBtnSyncClick:(UIBarButtonItem *)sender;      // 同步获取到服务器的数据
- (IBAction)btnSetInfoClick:(UIButton *)sender;             // 保存到本地

@end
