//
//  POSDeviceViewController.m
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "POSDeviceViewController.h"

#define CHECK_BOX_PRODUCT 10
#define CHECK_BOX_TEST 11

@interface POSDeviceViewController () <QCheckBoxDelegate>

@end

@implementation POSDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置Checkbox
    QCheckBox *_checkProduct = [[QCheckBox alloc] initWithDelegate:self];     // 计次卡会员消费
    _checkProduct.frame = CGRectMake(100, 196, 70, 30);
    [_checkProduct setTitle:@"生产" forState:UIControlStateNormal];
    [_checkProduct setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkProduct.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.ckProduct = _checkProduct;
    self.ckProduct.tag = CHECK_BOX_PRODUCT;
    [self.view addSubview:_checkProduct];
    
    QCheckBox *_checkTest = [[QCheckBox alloc] initWithDelegate:self];     // 快速消费
    _checkTest.frame = CGRectMake(170, 196, 70, 30);
    [_checkTest setTitle:@"测试" forState:UIControlStateNormal];
    [_checkTest setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkTest.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.cktest = _checkTest;
    self.cktest.tag = CHECK_BOX_TEST;
    [self.cktest setChecked:YES];
    [self.view addSubview:_checkTest];
    
}


#pragma mark - QCheckBoxDelegate
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    
    if (self.ckProduct.tag == checkbox.tag) {
        self.cktest.checked = NO;
    }
    if (self.cktest.tag == checkbox.tag) {
        self.ckProduct.checked = NO;
    }
    
    if (checked) {
        checkbox.checked = YES;
    }
    
}


- (IBAction)barBtnSyncClick:(UIBarButtonItem *)sender {
}

- (IBAction)btnSetInfoClick:(UIButton *)sender {
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
