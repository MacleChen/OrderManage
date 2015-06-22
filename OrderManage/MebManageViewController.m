//
//  MebManageViewController.m
//  OrderManage
//
//  Created by mac on 15/6/5.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "MebManageViewController.h"
#import "RegisteViewController.h"
#import "viewOtherDeal.h"

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface MebManageViewController () <AVCaptureMetadataOutputObjectsDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSMutableArray *_MuarrayType; // 要显示到pcikerview中卡类型字符串
    NSArray *_arrayTypeData;   // 接收到的所有类型数据
}

@end

@implementation MebManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    self.dictSearchMebInfo = [[NSDictionary alloc] init];
    _MuarrayType = [[NSMutableArray alloc] init];
    _arrayTypeData = [[NSArray alloc] init];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    self.tfSearch.delegate = self;
    self.viewInAlert = [[UIView alloc] init];
    self.alertShow = [[CustomIOS7AlertView alloc] init];
    [self.alertShow setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
    self.alertShow.useMotionEffects = YES;
    // 设置代理
    self.alertShow.delegate = self;
    
    // 设置datePicker
    UIDatePicker *datePic = [[UIDatePicker alloc] init];
    datePic.frame = CGRectMake(0, 0, _mainScreenWidth, 300);
    datePic.datePickerMode = UIDatePickerModeDate;  // 设置显示日期模式
    self.datePicker = datePic;
    //self.datePicker.backgroundColor = [UIColor whiteColor];
    //[self.datePicker setAlpha:1];
    [self.datePicker setMaximumDate:[NSDate date]];  // 设置最大时间为当前时间
    [self.datePicker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged];
    
    // 设置毛玻璃的背景
    UIVisualEffectView *visEffView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.visualEffectView = visEffView;
    self.visualEffectView.frame = CGRectMake(0, _mainScreenHeight, _mainScreenWidth, 260);
    self.visualEffectView.alpha = 1.0;
    //    self.visualEffectView.layer.borderColor = [[UIColor grayColor] CGColor];
    //    self.visualEffectView.layer.borderWidth = 0.5; // 设置border
    [self.visualEffectView addSubview:_datePicker];
    
    // 设置pickerView
    UIPickerView *pickerCardType = [[UIPickerView alloc]initWithFrame:datePic.frame];
    self.pickerViewCardType = pickerCardType;
    self.pickerViewCardType.delegate = self;
    self.pickerViewCardType.dataSource = self;
    [self.visualEffectView addSubview:self.pickerViewCardType];
    
    // 将view添加到键盘上面
    UIWindow *wind = [[[UIApplication sharedApplication] windows] lastObject];
    [wind addSubview:self.visualEffectView];
    
    // 设置初始值
    if([self.tfSearch.text isEqual:@""])
        self.tfSearch.text = [self.ReceDict objectForKey:@"cumb"];
    if([self.tfSearch.text isEqual:@""])
        self.tfSearch.text = [self.ReceDict objectForKey:@"cucardid"];
    if([self.tfSearch.text isEqual:@""])
        self.tfSearch.text = [self.ReceDict objectForKey:@"cuname"];
    if(![self.tfSearch.text isEqual:@""])   [self btnSearchInfo:nil];
}



/**
 *  添加会员
 */
- (IBAction)btnAddMember:(UIBarButtonItem *)sender {
    //     返回到主界面 -- 回退根控制器界面
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //切换到下一个界面  --- push
    RegisteViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewCell_0_1"];
    [self.navigationController pushViewController:viewControl animated:YES];
    
    // 返回到前一个控制器
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 二维码的扫描
- (IBAction)btnQRCode:(UIButton *)sender {
    NSError *error = [[NSError alloc] init];
    // 判断当前设备是否有捕获数据流的设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        
        NSLog(@"%@", [error localizedDescription]);
        
        return;
        
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    //对应输出
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    [_captureSession addOutput:captureMetadataOutput];
    
    //创建一个队列
    dispatch_queue_t dispatchQueue;
    
    dispatchQueue = dispatch_queue_create("myQueue",NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //降捕获的数据流展现出来
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    
    //开始捕获
    [_captureSession startRunning];
    
}

#pragma mark 查询按钮点击
- (IBAction)btnSearchInfo:(UIButton *)sender {
    [self searchBarSearchButtonClicked:nil];
}

/**
 * 充值
 */
- (IBAction)btnRechange:(UIButton *)sender {
    [self showAlertViewWith:RECHANGE_VIEW_TAG];
    
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = RECHANGE_VIEW_TAG;
    
    // 获取viewInAlert 中的Tag值
    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UITextField *tftemp in arrayViews) {
        if(tftemp.tag == RECHANGE_VIEW_Type_TAG) self.tfReChange_Type = tftemp;
        if(tftemp.tag == RECHANGE_VIEW_Money_TAG) self.tfReChange_Money= tftemp;
        if(tftemp.tag == RECHANGE_VIEW_GiveMoney_TAG) self.tfReChange_GiveMoney = tftemp;
    }
    
    // 设置代理
    self.tfReChange_Type.delegate = self;
    self.tfReChange_Money.delegate = self;
    self.tfReChange_GiveMoney.delegate = self;
    
    // 初始化内容  获取网络数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBTopupActiveAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&shopid=%@", [self.dictSearchMebInfo objectForKey:@"groupid"], [self.dictSearchMebInfo objectForKey:@"shopid"]];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            if ([strStatus intValue] == 200) { // 获取正确的数据
                [_MuarrayType removeAllObjects]; // 清空陈旧的数据
                [_MuarrayType addObject:@"不选择活动"]; // 初始化一条数据
                self.tfReChange_Type.text = _MuarrayType[0]; // 默认为 不选择活动
                _arrayTypeData = [listData objectForKey:MESSAGE];
                // 存入获取到的数据
                for(NSDictionary *dictTemp in _arrayTypeData) {
                    NSString *string = [NSString stringWithFormat:@"充值活动：充%@ 送%@，%@", [dictTemp objectForKey:@"realmoney"], [dictTemp objectForKey:@"freemoney"], [dictTemp objectForKey:@"time"]];
                    [_MuarrayType addObject:string];
                }
                NSLog(@"%@", _MuarrayType);
                // 刷新数据
                [self.pickerViewCardType reloadComponent:0];
                
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }

    }];
}

/**
 * 修改资料
 */
- (IBAction)btnModifyInfo:(UIButton *)sender {
    [self showAlertViewWith:MODIFYINFO_VIEW_TAG];
    
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = MODIFYINFO_VIEW_TAG;
    
    // 获取viewInAlert 中的Tag值
    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UITextField *tftemp in arrayViews) {
        if(tftemp.tag == MODIFYINFO_VIEW_Name_TAG) self.tfModifyInfo_Name = tftemp;
        if(tftemp.tag == MODIFYINFO_VIEW_Email_TAG) self.tfModifyInfo_Email = tftemp;
        if(tftemp.tag == MODIFYINFO_VIEW_Phone_TAG) self.tfModifyInfo_Phone = tftemp;
        if(tftemp.tag == MODIFYINFO_VIEW_Address_TAG) self.tfModifyInfo_Address = tftemp;
        if(tftemp.tag == MODIFYINFO_VIEW_birday_TAG) self.tfModifyInfo_Birday = tftemp;
    }
    // 设置代理
    self.tfModifyInfo_Name.delegate = self;
    self.tfModifyInfo_Email.delegate = self;
    self.tfModifyInfo_Phone.delegate = self;
    self.tfModifyInfo_Address.delegate = self;
    self.tfModifyInfo_Birday.delegate = self;
    
    // 初始化内容
    self.tfModifyInfo_Name.text = self.lbName.text;
    self.tfModifyInfo_Email.text = [self.dictSearchMebInfo objectForKey:@"cuemail"];
    self.tfModifyInfo_Phone.text = self.lbphoneNUM.text;
    self.tfModifyInfo_Address.text = self.lbAddress.text;
    self.tfModifyInfo_Birday.text = self.lbBirday.text;
}

/**
 * 挂失卡
 */
- (IBAction)btnLoss:(UIButton *)sender {
    [self showAlertViewWith:LOSS_VIEW_TAG];
    
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = LOSS_VIEW_TAG;
    
    // 获取viewInAlert 中的Tag值
    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UILabel *temp in arrayViews) {
        if(temp.tag == LOSS_VIEW_Content_TAG) self.lbLoss_Content = temp;
    }
    
    // 初始化内容
    self.lbLoss_Content.text = [NSString stringWithFormat:@"确定挂失？\n卡号：%@", self.lbCardID.text];
}

/**
 * 补卡
 */
- (IBAction)btnMakeupCard:(UIButton *)sender {
    [self showAlertViewWith:MAKEUPCARD_VIEW_TAG];
    
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = MAKEUPCARD_VIEW_TAG;
//    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
//    NSArray *arrayViews = [viewTempInAlert subviews];
//    for (UILabel *temp in arrayViews) {
//        if(temp.tag == LOSS_VIEW_Content_TAG) self.lbLoss_Content = temp;
//    }
    
    // 初始化内容
}

/**
 * 新增卡
 */
- (IBAction)btnAddCard:(UIButton *)sender {
    [self showAlertViewWith:ADDCARD_VIEW_TAG];
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = ADDCARD_VIEW_TAG;
    
    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UITextField *temp in arrayViews) {
        if(temp.tag == ADDCARD_VIEW_Type_TAG) self.tfAddCard_Type = temp;
        if(temp.tag == ADDCARD_VIEW_CardID_TAG) self.tfAddCard_CardID = temp;
        if(temp.tag == ADDCARD_VIEW_CardMoney_TAG) self.tfAddCard_Money = temp;
    }
    // 设置代理
    self.tfAddCard_Type.delegate = self;
    self.tfAddCard_CardID.delegate = self;
    self.tfAddCard_Money.delegate = self;
    
    // 初始化内容
        // 获取卡的网络类型数据
    [self GetCardTypeAllData];
    // 获取会员卡号
    [self GetCardNumString];
}

/**
 *  退卡
 */
- (IBAction)btnCancelCard:(UIButton *)sender {
    [self showAlertViewWith:CANCELCARD_VIEW_TAG];
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = CANCELCARD_VIEW_TAG;
    
    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UILabel *temp in arrayViews) {
        if(temp.tag == CANCELCARD_VIEW_CardID_TAG) self.lbCancelCard_CardID = temp;
        if(temp.tag == CANCELCARD_VIEW_ReMoney_TAG) self.lbCancelCard_ReMoney = temp;
    }
    
    // 初始化内容
    self.lbCancelCard_CardID.text = self.lbCardID.text;
    self.lbCancelCard_ReMoney.text = self.lbRemain_Times.text;
}

/**
 *  修改卡的密码
 */
- (IBAction)btnModifyPwdCard:(UIButton *)sender {
    [self showAlertViewWith:MODIFYPWDCARD_VIEW_TAG];
    
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = MODIFYPWDCARD_VIEW_TAG;
    
    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UITextField *temp in arrayViews) {
        if(temp.tag == MODIFYPWDCARD_VIEW_Old_TAG) self.tfModifyPwd_OldPwd = temp;
        if(temp.tag == MODIFYPWDCARD_VIEW_New_TAG) self.tfModifyPwd_NewPwd = temp;
        if(temp.tag == MODIFYPWDCARD_VIEW_Sure_TAG) self.tfModifyPwd_SurePwd = temp;
    }
    // 设置代理
    self.tfModifyPwd_OldPwd.delegate = self;
    self.tfModifyPwd_NewPwd.delegate = self;
    self.tfModifyPwd_SurePwd.delegate = self;
    
    // 初始化内容
}

/**
 *  卡升级
 */
- (IBAction)btnUpgradeCard:(UIButton *)sender {
    [self showAlertViewWith:UPGRADECARD_VIEW_TAG];
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = UPGRADECARD_VIEW_TAG;
    
    UIView *viewTempInAlert = [self.alertShow containerView];
    
    // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UITextField *temp in arrayViews) {
        if(temp.tag == UPGRADECARD_VIEW_OldCID_TAG) self.tfUpdateCard_OldCID = temp;
        if(temp.tag == UPGRADECARD_VIEW_Type_TAG) self.tfUpdateCard_Type = temp;
        if(temp.tag == UPGRADECARD_VIEW_NewCID_TAG) self.tfUpdateCard_NewCID = temp;
        if(temp.tag == UPGRADECARD_VIEW_Money_TAG) self.tfUpdateCard_Money = temp;
    }
    // 设置代理
    self.tfUpdateCard_OldCID.delegate = self;
    self.tfUpdateCard_Type.delegate = self;
    self.tfUpdateCard_NewCID.delegate = self;
    self.tfUpdateCard_Money.delegate = self;
    
    // 初始化内容
}

#pragma mark -  CustomIOS7AlertViewDelegate 的代理方法实现
/**
 *  customIOS7dialogButtonTouchUpInside 方法
 */
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 获取那个按钮点击
    if(buttonIndex == 0) {
        [self.alertShow close] ;
        [self textFieldShouldBeginEditing:nil]; // 退出picker
        return;
    } // 点击取消返回
    
    CustomIOS7AlertView *alert = (CustomIOS7AlertView *)alertView;
    UIView *viewInAlert = [alert containerView];
    
    // 判断哪个业务，并处理业务
    switch (viewInAlert.tag) {
        case RECHANGE_VIEW_TAG:  // 确认充值
            // 充值处理方法
            [self RechangeDeal];
            break;
        case LOSS_VIEW_TAG:  // 确认挂失
            // 挂失处理方法
            [self LossCardDeal];
            break;
        case ADDCARD_VIEW_TAG:  // 确认新增卡
            // 新增卡处理方法
            [self AddCardDeal];
            break;
        case MODIFYPWDCARD_VIEW_TAG:  // 确认修密码
            // 修改密码处理方法
            [self ModifyPwdDeal];
            break;
        case MODIFYINFO_VIEW_TAG:  // 确认修改资料
            // 修改资料处理方法
            [self ModifyInformationDeal];
            break;
        case MAKEUPCARD_VIEW_TAG:  // 确认补卡
            // 补卡处理方法
            [self MakeupCardDeal];
            break;
        case CANCELCARD_VIEW_TAG:  // 确认退卡
            // 退卡处理方法
            [self CancelCardDeal];
            break;
        case UPGRADECARD_VIEW_TAG:  // 确认卡升级
            // 卡升级处理方法
            [self UpgradeCardDeal];
            break;
        default:
            break;
    }
    
}

#pragma mark - 实现AVCaptureMetadataOutputObjectsDelegate 的代理方法
#pragma mark  获得的数据在AVCaptureMetadataOutputObjectsDelegate 唯一定义的方法中
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            //获得扫描的数据，并结束扫描
            [self performSelectorOnMainThread:@selector(stopReading:) withObject:metadataObj.stringValue waitUntilDone:NO];
        }
        
    }
}

-(void)stopReading:(NSString *)strQrcode {
    NSLog(@"%@", strQrcode);
}

#pragma mark - UISearchBarDelegate 的代理方法的实现
#pragma mark - 当点击键盘上的搜索按钮时调用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 判断输入不能为空
    if ([self.tfSearch.text isEqual:@""]) {
        [MBProgressHUD show:@"请输入查询内容" icon:nil view:nil];
        return;
    }
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerGetAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&keyword=%@", [dictLogin objectForKey:@"groupid"], self.tfSearch.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 获取数据失败
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
                dictTempData = [dictTempData objectForKey:@"cus"];
                // copy 查询到的会员信息
                self.dictSearchMebInfo = dictTempData;
                
                // 表示该该卡已被退卡
                if([[dictTempData objectForKey:@"cucardid"] isEqual:@"无"]) {
                    [MBProgressHUD show:@"该手机号未绑定会员卡" icon:nil view:nil];
                    // 清空显示信息
                    self.lbCardID.text = @"";
                    self.lbRemain_Times.text = @"";
                    self.lbCredits.text = @"";
                    self.lbCard_discount.text = @"";
                    self.lbName.text = @"";
                    self.lbphoneNUM.text = @"";
                    self.lbBirday.text = @"";
                    self.lbAddress.text = @"";
                    return;
                }
                // 设置显示信息
                self.lbCardID.text = [dictTempData objectForKey:@"cucardid"];
                self.lbRemain_Times.text = [dictTempData objectForKey:@"lostmoney"];
                self.lbCredits.text = [dictTempData objectForKey:@"cuinter"];
                self.lbCard_discount.text = [NSString stringWithFormat:@"%@/%@", [dictTempData objectForKey:@"cardname"], [dictTempData objectForKey:@"cdpec"]];
                self.lbName.text = [dictTempData objectForKey:@"cuname"];
                self.lbphoneNUM.text = [dictTempData objectForKey:@"cumb"];
                self.lbBirday.text = [dictTempData objectForKey:@"cubdate_str"];
                self.lbAddress.text = [dictTempData objectForKey:@"cuaddress"];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }

    }];

    
}


/**
 *  先是自定义的alertview
 */
- (void)showAlertViewWith:(int)ViewTag {
    // 先查询
    if(self.lbCardID.text.length == 0) {
        [MBProgressHUD show:@"请先查询会员信息" icon:nil view:nil];
        return;
    }
    
    
    // 从xib中获取views
    NSArray *viewsMemberMg = [[NSBundle mainBundle] loadNibNamed:@"MebManageShowView" owner:nil options:nil];
    
    // 寻找view -- 获取对应的view
    for (UIView *viewSearch in viewsMemberMg) {
        if (viewSearch.tag == ViewTag) {
            self.viewInAlert = viewSearch;
            break;
        }
    }
    
    // 将view显示在alertview中
    [self.alertShow setContainerView:self.viewInAlert];
    [self.alertShow show];
}


#pragma mark - textField的代理方法的实现
#pragma mark 正在编辑时，实时调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 判断是谁在编辑 -- 充值
    if (textField.tag == RECHANGE_VIEW_Money_TAG && ![self.tfReChange_Type.text isEqual:_MuarrayType[0]]) {
        // 计算赠送金额
        NSString *strNow = [viewOtherDeal NowInTextFiledText:textField NowStrChar:string];
        NSInteger selectedRow = [self.pickerViewCardType selectedRowInComponent:0];
        
        NSDictionary *dictActive = _arrayTypeData[selectedRow];
        NSString *strRealmoney = [dictActive objectForKey:@"realmoney"];
        NSString *strFreemoney = [dictActive objectForKey:@"freemoney"];
        if ([strNow intValue] % [strRealmoney intValue] == 0) {  // 判断整除于活动金额
            int freemoney = [strFreemoney intValue] * ([strNow intValue] / [strRealmoney intValue]);
            self.tfReChange_GiveMoney.text = [NSString stringWithFormat:@"%i", freemoney];
        }
    }
    
    
    
    return YES;
}

#pragma mark 当完成编辑时调用该方法
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark 当textfield开始编辑时调用
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGRect datepicFrame = self.visualEffectView.frame;
    
    // 添加对应的picker
    if (textField.tag == MODIFYINFO_VIEW_birday_TAG) {  // 显示 datePicker
        self.datePicker.hidden = NO;
        self.pickerViewCardType.hidden = YES;
    }
    if (textField.tag == RECHANGE_VIEW_Type_TAG || textField.tag == ADDCARD_VIEW_Type_TAG) {   // 显示数据 picker
        self.datePicker.hidden = YES;
        self.pickerViewCardType.hidden = NO;
    }
    // 添加动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    if (textField.tag == RECHANGE_VIEW_Type_TAG || textField.tag == MODIFYINFO_VIEW_birday_TAG || textField.tag == ADDCARD_VIEW_Type_TAG) {  // 开始编辑 会员生日
        [self.view endEditing:YES];
        // 显示placeholder
        if(textField.tag == RECHANGE_VIEW_Type_TAG) self.tfReChange_Type.text = @"";
        if(textField.tag == MODIFYINFO_VIEW_birday_TAG)  self.tfModifyInfo_Birday.text = @"";
        if(textField.tag == ADDCARD_VIEW_Type_TAG)  self.tfAddCard_Type.text = @"";
        
        datepicFrame.origin.y = _mainScreenHeight - datepicFrame.size.height;
        
    } else {
        datepicFrame.origin.y = _mainScreenHeight;
    }
    
    self.visualEffectView.frame = datepicFrame;
    [UIView commitAnimations];
    
//    if (textField.tag == RECHANGE_VIEW_Type_TAG || textField.tag == MODIFYINFO_VIEW_birday_TAG || textField.tag == ADDCARD_VIEW_Type_TAG) return NO;
    
    return YES;
}

#pragma mark - pickerView代理方法的实现
#pragma mark 设置有多少个组件块
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark 设置每个组件中有多少个row
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _MuarrayType.count;
}

#pragma mark 设置每个组件中的row的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return _MuarrayType[row];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case RECHANGE_VIEW_TAG:
            self.tfReChange_Type.text = _MuarrayType[row];
            break;
        case ADDCARD_VIEW_TAG:
            self.tfAddCard_Type.text = _MuarrayType[row];
            break;
        default:
            break;
    }
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
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:13]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


#pragma mark 滚动datePicker调用的方法
- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;     // 获取datePicker的时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyyMMdd";  // 设置时间格式
    
    self.tfModifyInfo_Birday.text = [dateFormat stringFromDate:selectedDate]; // 将时间转化为NSString
}


#pragma mark - 业务处理方法
#pragma mark 充值处理
- (void)RechangeDeal {
    // 判断是否有空
    if ([self.tfReChange_Type.text isEqual:@""] || [self.tfReChange_Money.text isEqual:@""]) {
        [MBProgressHUD show:EmptyINPUTERROR icon:nil view:nil];
        return;
    }
    
    [self.alertShow close] ;
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    
    NSDictionary *sendDict = @{@"cuaddress": [self.dictSearchMebInfo objectForKey:@"cuaddress"],
                               @"cubdate" : [self.dictSearchMebInfo objectForKey:@"cubdate_str"],
                               @"cucardid":  [self.dictSearchMebInfo objectForKey:@"cucardid"],
                               @"cucardno": [self.dictSearchMebInfo objectForKey:@"cucardno"],
                               @"cuemail" : [self.dictSearchMebInfo objectForKey:@"cuemail"],
                               @"cuname" : [self.dictSearchMebInfo objectForKey:@"cuname"],
                               @"cuphone":  [self.dictSearchMebInfo objectForKey:@"cumb"],
                               @"cupwd": [self.dictSearchMebInfo objectForKey:@"cupwd"],
                               @"selcardmoney": [NSString stringWithFormat:@"%.2f", [self.tfReChange_Money.text floatValue] + [self.tfReChange_GiveMoney.text floatValue]],
                               @"selcardtype": [NSString stringWithFormat:@"%@%@", [self.dictSearchMebInfo objectForKey:@"cardname"], [self.dictSearchMebInfo objectForKey:@"cdpec"]]};
    
    // 跳转到付款页面
    //切换到下一个界面  --- push
    GetMoneyViewController *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"GetMoney"];
    viewControl.listDict = sendDict;
    viewControl.ReceDict = nil;
    [self.navigationController pushViewController:viewControl animated:YES];
    
    
}

#pragma mark 挂失处理
- (void)LossCardDeal {
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerLockCardAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&keyword=%@&keyword1=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], self.lbCard_discount.text, self.lbCardID.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                [MBProgressHUD show:@"挂失成功" icon:nil view:nil];
                //NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];

}

#pragma mark 新增卡处理
- (void)AddCardDeal {
    // 判断是否有空
    if ([self.tfAddCard_Type.text isEqual:@""] || [self.tfAddCard_CardID.text isEqual:@""] || [self.tfAddCard_Money.text isEqual:@""]) {
        [MBProgressHUD show:EmptyINPUTERROR icon:nil view:nil];
        return;
    }
    
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 获取选择卡的类型
    NSInteger selectRow = [self.pickerViewCardType selectedRowInComponent:0];
    NSDictionary *dictSelectedCardType =  _arrayTypeData[selectRow];
    
    NSDictionary *sendDict = @{@"cuaddress": [self.dictSearchMebInfo objectForKey:@"cuaddress"],
                               @"cubdate" : [self.dictSearchMebInfo objectForKey:@"cubdate_str"],
                               @"cucardid":  [self.dictSearchMebInfo objectForKey:@"cucardid"],
                               @"cucardno": [self.dictSearchMebInfo objectForKey:@"cucardno"],
                               @"cuemail" : [self.dictSearchMebInfo objectForKey:@"cuemail"],
                               @"cuname" : [self.dictSearchMebInfo objectForKey:@"cuname"],
                               @"cuphone":  [self.dictSearchMebInfo objectForKey:@"cumb"],
                               @"cupwd": [self.dictSearchMebInfo objectForKey:@"cupwd"],
                               @"selcardmoney": [NSString stringWithFormat:@"%.2f", [self.tfAddCard_Money.text floatValue]],
                               @"selcardtype": [NSString stringWithFormat:@"%@%@", [dictSelectedCardType  objectForKey:@"typename"], [dictSelectedCardType objectForKey:@"cdpec"]]};
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBNewCardUpCardAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&emp.empid=%@&keyword=%@&keyword1=%@&totalmoney=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], [dictLogin objectForKey:@"empid"], self.tfAddCard_CardID, [dictSelectedCardType objectForKey:@"cdid"], self.tfAddCard_Money.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                //NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
                // 跳转到付款页面
                //切换到下一个界面  --- push
                GetMoneyViewController *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"GetMoney"];
                viewControl.listDict = sendDict;
                viewControl.ReceDict = nil;
                [self.navigationController pushViewController:viewControl animated:YES];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
    
}

#pragma mark 修改密码处理
- (void)ModifyPwdDeal {
    // 判断是否有空
    if ([self.tfModifyPwd_OldPwd.text isEqual:@""] || [self.tfModifyPwd_NewPwd.text isEqual:@""] || [self.tfModifyPwd_SurePwd.text isEqual:@""]) {
        [MBProgressHUD show:EmptyINPUTERROR icon:nil view:nil];
        return;
    }
    
    // 判断新密码与确认密码是否相等
    if(![self.tfModifyPwd_NewPwd.text isEqual:self.tfModifyPwd_SurePwd.text]){
        [MBProgressHUD show:@"密码不相等" icon:nil view:nil];
        return;
    }
    
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerChangePwdAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&keyword=%@&keyword1=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], self.tfModifyPwd_OldPwd.text, self.tfModifyPwd_NewPwd.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                [MBProgressHUD show:[listData objectForKey: MESSAGE] icon:nil view:nil];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 修改资料处理
- (void)ModifyInformationDeal {
    // 判断是否有空
    if ([self.tfModifyInfo_Name.text isEqual:@""] || [self.tfModifyInfo_Address.text isEqual:@""] || [self.tfModifyInfo_Birday.text isEqual:@""] || [self.tfModifyInfo_Email.text isEqual:@""] || [self.tfModifyInfo_Phone.text isEqual:@""]) {
        [MBProgressHUD show:EmptyINPUTERROR icon:nil view:nil];
        return;
    }
    
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerUpdateAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&cus.cuname=%@&cus.cuemail=%@&cus.cumb=%@&cus.cuaddress=%@&cus.cubdate_str=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], self.tfModifyInfo_Name.text, self.tfModifyInfo_Email.text, self.tfModifyInfo_Phone.text, self.tfModifyInfo_Address.text, self.tfModifyInfo_Birday.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                // 刷新查询数据
                [self btnSearchInfo:nil];
                [MBProgressHUD show:[listData objectForKey: MESSAGE] icon:nil view:nil];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 补卡处理
- (void)MakeupCardDeal {
    
}

#pragma mark 退卡处理
- (void)CancelCardDeal {
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 获取卡的类型对应-----   -1：储值卡   1：计次卡
    NSString *StrcardtypeId = [self.dictSearchMebInfo objectForKey:@"cardtypeid"];
    NSString *strFlag = [StrcardtypeId intValue] > 0 ? @"-1" : @"1";
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBNewCardReturnAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"keyword=%@&keyword1=%@&keyword2=%@&emp.empid=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], strFlag, self.lbRemain_Times.text, [dictLogin objectForKey:@"empid"]];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                // 刷新查询数据
                [self btnSearchInfo:nil];
                [MBProgressHUD show:[listData objectForKey: MESSAGE] icon:nil view:nil];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 卡升级处理
- (void)UpgradeCardDeal {

}


// 根据网络获取卡类型的数据
- (void)GetCardTypeAllData {
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBFindCardAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&shopid=%@&keyword=discount", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"shopid"]];
    
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                _arrayTypeData = [NSArray arrayWithObject:[listData objectForKey:MESSAGE]];
                _arrayTypeData = _arrayTypeData[0];
                
                // 清空picker中的数据，重新导入数据
                [_MuarrayType removeAllObjects];
                for (int i = 0; i < _arrayTypeData.count; i++) {
                    NSDictionary *dictTemp = _arrayTypeData[i];
                    NSString *strcardType = [NSString stringWithFormat:@"%@ | %@ | 价格：%@ | 次数：%@ ", [dictTemp objectForKey:@"typename"], [dictTemp objectForKey:@"cdname"], [dictTemp objectForKey:@"cdmoney"], [dictTemp objectForKey:@"cdcount"]];
                    [_MuarrayType addObject:strcardType];
                }
                [self.pickerViewCardType reloadAllComponents];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
    }];
}

// 获取新增卡号的网路请求
- (void)GetCardNumString {
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBNewCardNumAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"shopid=%@", [dictLogin objectForKey:@"shopid"]];
    
    // 网络数据请求
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:ConnectDataError icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                self.tfAddCard_CardID.text = [listData objectForKey: MESSAGE];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
    }];
}

#pragma mark 点击背景时，退出键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self textFieldShouldBeginEditing:nil];
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
