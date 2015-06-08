//
//  MebManageViewController.h
//  OrderManage
//
//  Created by mac on 15/6/5.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MebManageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISearchBar *tfSearch;

@property (weak, nonatomic) IBOutlet UILabel *lbCardID;
@property (weak, nonatomic) IBOutlet UILabel *lbName;               // 会员姓名
@property (weak, nonatomic) IBOutlet UILabel *lbCard_discount;      // 卡类/折扣
@property (weak, nonatomic) IBOutlet UILabel *lbRemain_Times;       // 余额/余次
@property (weak, nonatomic) IBOutlet UILabel *lbCredits;            // 积分
@property (weak, nonatomic) IBOutlet UILabel *lbphoneNUM;
@property (weak, nonatomic) IBOutlet UILabel *lbBirday;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;


- (IBAction)btnAddMember:(UIBarButtonItem *)sender;
- (IBAction)btnQRCode:(UIButton *)sender;
- (IBAction)btnRechange:(UIButton *)sender;
- (IBAction)btnModifyInfo:(UIButton *)sender;
- (IBAction)btnLoss:(UIButton *)sender;
- (IBAction)btnMakeupCard:(UIButton *)sender;
- (IBAction)btnAddCard:(UIButton *)sender;
- (IBAction)btnCancelCard:(UIButton *)sender;
- (IBAction)btnModifyPwdCard:(UIButton *)sender;
- (IBAction)btnUpgradeCard:(UIButton *)sender;

@end
