//
//  LoginViewController.h
//  OrderManage
//
//  Created by mac on 15/5/29.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"

#define loginSuccess @"登录成功"
#define loginInfoErr @"用户名或密码不正确"

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *lbInfo;
@property (strong, nonatomic) IBOutlet UITextField *edtName;
@property (strong, nonatomic) IBOutlet UITextField *edtPwd;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;

@property (strong, nonatomic) IBOutlet UIView *viewLogin;

@property (weak, nonatomic) IBOutlet UISwitch *savePwd;

- (IBAction)SwSavePwd:(UISwitch *)sender;


- (IBAction)btnClick:(UIButton *)sender;

- (void)setAnimatForViewFordur:(float)DurTime position:(CGRect)viewFrame;

@end
