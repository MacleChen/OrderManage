//
//  ComDetailTableViewController.h
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "QCheckBox.h"
#import "CustomIOS7AlertView.h"

#define TFBEGIN_TAG 10  // 开始时间输入框的tag
#define TFEND_TAG 11    // 结束输入框的tag

@interface ComDetailTableViewController : UITableViewController <CustomIOS7AlertViewDelegate>

@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *itemSearch;  // 搜索

@property (weak, nonatomic) UIDatePicker *datePicker;           //  时间滚轴
@property (strong, nonatomic) UIVisualEffectView * visualEffectView;   // 毛玻璃色视图

// 设置搜索窗口属性
@property (strong, nonatomic) UIView *viewSearch;           // 搜索视图界面
@property (strong, nonatomic) UITextField *TF_BeginDate;      // 开始时间
@property (weak, nonatomic) UITextField *TF_EndDate;        // 结束时间
@property (weak, nonatomic) UITextField *TF_SearchKeywd;    // 搜索关键词
@property (weak, nonatomic) QCheckBox *CK_DoCard;           // 办卡
@property (weak, nonatomic) QCheckBox *CK_Rechange;         // 充值
@property (weak, nonatomic) QCheckBox *CK_Petcd;            // 储值会员消费
@property (weak, nonatomic) QCheckBox *CK_TimeCd;           // 计次卡会员消费
@property (weak, nonatomic) QCheckBox *CK_QuickCom;         // 快速消费

@property (strong, nonatomic) CustomIOS7AlertView *alertShow;


- (IBAction)BarBtnDetailSearch:(UIBarButtonItem *)sender;

@end
