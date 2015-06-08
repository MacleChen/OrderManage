//
//  MebManageViewController.m
//  OrderManage
//
//  Created by mac on 15/6/5.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "MebManageViewController.h"

@interface MebManageViewController ()

@end

@implementation MebManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)btnAddMember:(UIBarButtonItem *)sender {
}

- (IBAction)btnQRCode:(UIButton *)sender {
}

- (IBAction)btnRechange:(UIButton *)sender {
    
}

- (IBAction)btnModifyInfo:(UIButton *)sender {
}

- (IBAction)btnLoss:(UIButton *)sender {
}

- (IBAction)btnMakeupCard:(UIButton *)sender {
}

- (IBAction)btnAddCard:(UIButton *)sender {
}

- (IBAction)btnCancelCard:(UIButton *)sender {
}

- (IBAction)btnModifyPwdCard:(UIButton *)sender {
}

- (IBAction)btnUpgradeCard:(UIButton *)sender {
}

#pragma mark 点击背景时，退出键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
