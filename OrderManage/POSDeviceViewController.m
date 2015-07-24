//
//  POSDeviceViewController.m
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "POSDeviceViewController.h"
#import "Global.h"
#import "MBProgressHUD+MJ.h"
#import "viewOtherDeal.h"
#import "HttpRequest.h"

#define CHECK_BOX_PRODUCT 10
#define CHECK_BOX_TEST 11

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface POSDeviceViewController () <QCheckBoxDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSArray *_arrayType;
}

@end

@implementation POSDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化信息
    _arrayType = [NSArray arrayWithObjects:@"自动选择", @"纸质签购单", @"单子签购单",nil];
    self.tfPOSType.text = _arrayType[0];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + TOP_MENU_HEIGHT;
    
    // 设置Checkbox
    QCheckBox *_checkProduct = [[QCheckBox alloc] initWithDelegate:self];     // 计次卡会员消费
    _checkProduct.frame = CGRectMake(100, 196, 70, 30);
    [_checkProduct setTitle:@"生产" forState:UIControlStateNormal];
    [_checkProduct setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkProduct.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.ckProduct = _checkProduct;
    self.ckProduct.tag = CHECK_BOX_PRODUCT;
    [self.ckProduct setChecked:YES];
    [self.view addSubview:_checkProduct];
    
    QCheckBox *_checkTest = [[QCheckBox alloc] initWithDelegate:self];     // 快速消费
    _checkTest.frame = CGRectMake(170, 196, 70, 30);
    [_checkTest setTitle:@"测试" forState:UIControlStateNormal];
    [_checkTest setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkTest.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.cktest = _checkTest;
    self.cktest.tag = CHECK_BOX_TEST;
    [self.view addSubview:_checkTest];
    
    // 设置代理
    self.tfuserID.delegate = self;
    self.tfuserTerminalID.delegate = self;
    self.tfPOSType.delegate = self;
    
    // 设置毛玻璃的背景
    UIVisualEffectView *visEffView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.visualEffectView = visEffView;
    self.visualEffectView.frame = CGRectMake(0, _mainScreenHeight, _mainScreenWidth, INPUTVIEW_HEIGHT);
    self.visualEffectView.alpha = 1.0;
    
    // 设置pickerView
    UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, _mainScreenWidth, INPUTVIEW_HEIGHT)];
    self.pickerView = picker;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.visualEffectView addSubview:self.pickerView];
    
    // 设置键盘类型
    self.tfuserID.keyboardType = UIKeyboardTypeNamePhonePad;
    self.tfuserTerminalID.keyboardType = UIKeyboardTypeNamePhonePad;
    self.tfPOSType.inputView = self.visualEffectView;
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

/**
 *  同步获取到服务器的数据
 */
- (IBAction)barBtnSyncClick:(UIBarButtonItem *)sender {
    
    // 网络请求
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBEmpDetailsAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"emp.empid=%@", [dictLogin objectForKey:@"empid"]];
    
    [MBProgressHUD showMessage:@""];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 获取数据失败
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                // 解析数据
                NSDictionary *dictTemp = [listData objectForKey:MESSAGE];
                
                // 重新刷新数据
                self.tfuserID.text = [dictTemp objectForKey:@"mernum"];
                self.tfuserTerminalID.text = [dictTemp objectForKey:@"ternum"];
                int posTypeRow = [(NSString *)[dictTemp objectForKey:@"posid"] intValue];
                self.tfPOSType.text = _arrayType[posTypeRow];
                
                [MBProgressHUD show:@"同步成功" icon:nil view:nil];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
    
}

- (IBAction)btnSetInfoClick:(UIButton *)sender {  // 保存到本地
    if ([self.tfuserID.text isEqual:@""] || [self.tfuserTerminalID.text isEqual:@""] || [self.tfPOSType.text isEqual:@""]) {
        [MBProgressHUD show:@"输入不能为空" icon:nil view:nil];
        return;
    }
    
    if (!self.ckProduct.checked && !self.cktest.checked) {
        [MBProgressHUD show:@"请选择环境类型" icon:nil view:nil];
        return;
    }
    
    [self saveNSUserDefaults];  // 保存数据到本地
    
    [MBProgressHUD show:@"保存成功！" icon:nil view:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 保存数据到NSUserDefaults
 */
-(void)saveNSUserDefaults
{
    NSString *PosTypeTemp;
    // 将登录数据保存到nsuserDefaults中
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    // 类型转化
    for(int i = 0; i < _arrayType.count; i++) {
        if ([self.tfPOSType.text isEqual:_arrayType[i]]) {
            PosTypeTemp = [NSString stringWithFormat:@"%i", i];
            break;
        }
    }
    
    // 存入数据
    [userDef setObject:self.tfuserID.text forKey:@"POS_userID"];
    [userDef setObject:self.tfuserTerminalID.text forKey:@"POS_userTerminalID"];
    [userDef setObject:PosTypeTemp forKey:@"POS_POSType"];
    [userDef setBool:self.ckProduct.checked forKey:@"POS_Product"];
    
    // 建议同步存储到磁盘中
    [userDef synchronize];
}


#pragma mark - pickerView代理方法的实现
#pragma mark 设置有多少个组件块
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark 设置每个组件中有多少个row
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _arrayType.count;
}

#pragma mark 设置每个组件中的row的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _arrayType[row];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.tfPOSType.text = _arrayType[row];
}


#pragma mark 对pickerview中的控件进行修改
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
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
