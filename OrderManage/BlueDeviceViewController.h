//
//  BlueDeviceViewController.h
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface BlueDeviceViewController : UIViewController

@property (strong, nonatomic) CBCentralManager *cbCenterMg;   // 设备管理者

@property (strong, nonatomic) CBPeripheral *cbperi;    // 外围设备

@property (strong, nonatomic) CBCharacteristic *cbChtic; // 特征

@property (strong, nonatomic) NSMutableArray *peripheralArray; // 管理设备

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) UISwitch *swbtnBluethState; // 蓝牙开关

@property (strong, nonatomic) UIActivityIndicatorView *atiview; // 加载运行中

@property (strong, nonatomic) NSTimer *timer;       // 设置定时器

@end
