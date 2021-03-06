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

@interface MebManageViewController () <AVCaptureMetadataOutputObjectsDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, QRCodeViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSMutableArray *_MuarrayType; // 要显示到pcikerview中卡类型字符串
    NSArray *_arrayTypeData;   // 接收到的所有类型数据
    
    NSMutableArray *_MUarrayAllCards;  // 每个会员所对应的所有卡的详细
    int CardTypeFlag;    // 卡的类型状态
    int CardCKLOSS_STATUS;  // 卡的挂失状态
    NSString *_StrDiscount; // 折扣
    NSString *_SelectCuCardID;  // 选中的cucardid
    NSDictionary *_SelectCuCardType;  // 所选中卡的类型数据
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
    _MUarrayAllCards = [[NSMutableArray alloc] init];
    _SelectCuCardType = [NSDictionary dictionary];
    
    // 设置背景图片
    [self.btnSaoyisao setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"saoyisao6.png"] size:CGSizeMake(30, 25)] forState:UIControlStateNormal];
    //[self.btnSaoyisao setImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"saoyisao6.png"] size:CGSizeMake(30, 25)] forState:UIControlStateNormal];
    [self.btnSearch setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"searchBtnImg2.png"] size:CGSizeMake(45, 30)] forState:UIControlStateNormal];
    
    
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
    self.tfCardID.delegate = self;
    
    // 设置储值卡的选择
    self.tfCardID.tag = TF_CARDID_TAG;
    
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
    self.visualEffectView.frame = CGRectMake(0, _mainScreenHeight, _mainScreenWidth, 220);
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
//    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
//    [window addSubview:self.visualEffectView];
    
    //[self.tfCardID setInputAccessoryView:self.visualEffectView];
    [self.tfCardID setInputView:self.visualEffectView];
    
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
    //切换到下一个界面  --- push
    QRCodeViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeview"];
    viewControl.delegate = self;
    [self.navigationController pushViewController:viewControl animated:YES];
}

#pragma mark 查询按钮点击
- (IBAction)btnSearchInfo:(UIButton *)sender {
    [self searchBarSearchButtonClicked:nil];
}

/**
 * 充值
 */
- (IBAction)btnRechange:(UIButton *)sender {
    if ([self.lbCardID.text isEqual:@"无"]) {
        [MBProgressHUD show:@"没有会员卡，请新增会员卡" icon:nil view:nil];
        return;
    }
    
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
    
    // 设置调出键盘类型
    [self.tfReChange_Type setInputView:self.visualEffectView];
    
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
                MyPrint(@"%@", _MuarrayType);
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
    
    // 设置键盘类型
    [self.tfModifyInfo_Birday setInputView:self.visualEffectView];
    
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
    if ([self.lbCardID.text isEqual:@"无"]) {
        [MBProgressHUD show:@"没有会员卡，请新增会员卡" icon:nil view:nil];
        return;
    }
    
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
    if(CardCKLOSS_STATUS == LOSSCARD_UNLOSS_STATUS) {
        self.lbLoss_Content.text = [NSString stringWithFormat:@"确定挂失？\n卡号：%@", self.lbCardID.text];
    } else {
        self.lbLoss_Content.text = [NSString stringWithFormat:@"确定解除挂失？\n卡号：%@", self.lbCardID.text];
    }
    
}

/**
 * 补卡
 */
- (IBAction)btnMakeupCard:(UIButton *)sender {
    // 判断会员卡是否已挂失
    if ( CardCKLOSS_STATUS == LOSSCARD_UNLOSS_STATUS) { // 挂失
        [MBProgressHUD show:@"该会员未挂失，请先挂失" icon:nil view:nil];
        return;
    }
    
    [self showAlertViewWith:MAKEUPCARD_VIEW_TAG];
    
    // 设置pickerview 对应的业务TAG
    self.pickerViewCardType.tag = MAKEUPCARD_VIEW_TAG;
    UIView *viewTempInAlert = [self.alertShow containerView];
    
     // 获取内部view中的控件
    NSArray *arrayViews = [viewTempInAlert subviews];
    for (UITextField *temp in arrayViews) {
        if(temp.tag == MAKEUPCARD_VIEW_CardID_TAG) self.tfMakeupCard_CardId = temp;
        if(temp.tag == MAKEUPCARD_VIEW_CardMoney_TAG) self.tfMakeupCard_CardMoney = temp;
    }
    
    // 设置代理
    
    // 设置键盘类型
    self.tfMakeupCard_CardId.keyboardType = UIKeyboardTypeNamePhonePad;
    self.tfMakeupCard_CardId.keyboardType = UIKeyboardTypeNumberPad;
    
    // 初始化内容
    
    
    // 获取最新会员卡号
    [self GetCardNumString];
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
    
    // 设置键盘类型
    [self.tfAddCard_Type setInputView:self.visualEffectView];
    
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
    if ([self.lbCardID.text isEqual:@"无"]) {
        [MBProgressHUD show:@"没有会员卡，请新增会员卡" icon:nil view:nil];
        return;
    }
    
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
    
    // 设置输入框为不可输入
    self.tfUpdateCard_Money.enabled = NO;
    self.tfUpdateCard_OldCID.enabled = NO;
    
    // 设置键盘类型
    self.tfUpdateCard_Type.inputView = self.visualEffectView;
    
    // 初始化内容
    self.tfUpdateCard_OldCID.text = [NSString stringWithFormat:@"%@(%@%@)", self.lbCardID.text, self.lbRemainTitle.text, self.lbRemain_Times.text];
    
    // 初始化内容
    // 获取卡的网络类型数据
    [self GetCardTypeAllData];
    // 获取会员卡号
    [self GetCardNumString];
    
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


#pragma mark - UISearchBarDelegate 的代理方法的实现
#pragma mark - 当点击键盘上的搜索按钮时调用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 判断输入不能为空
    if ([self.tfSearch.text isEqual:@""]) {
        [MBProgressHUD show:@"请输入查询内容" icon:nil view:nil];
        return;
    }
    [MBProgressHUD showMessage:@""];
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerGetAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&keyword=%@", [dictLogin objectForKey:@"groupid"], self.tfSearch.text];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 获取数据失败
            if(strStatus == nil){
                [MBProgressHUD show:@"该手机号或会员卡号不存在" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
                NSArray *ArrayTempListCounts = [dictTempData objectForKey:@"listcount"];
                dictTempData = [dictTempData objectForKey:@"cus"];
                // copy 查询到的会员信息
                self.dictSearchMebInfo = dictTempData;
                _StrDiscount = [dictTempData objectForKey:@"cdpec"];  // 获取折扣
                
                // 表示该卡已被退卡,然后显示计次卡
                if([[dictTempData objectForKey:@"cucardid"] isEqual:@"无"]) {
                    if (ArrayTempListCounts.count == 0) {
                        [MBProgressHUD show:@"该手机号未绑定会员卡" icon:nil view:nil];
                        self.lbCardID.text = [dictTempData objectForKey:@"cucardid"];
                        self.lbRemain_Times.text = [NSString stringWithFormat:@"%@", [dictTempData objectForKey:@"cumoney"]];
                        self.lbCredits.text = [dictTempData objectForKey:@"cuinter"];
                        self.lbCard_discount.text = [NSString stringWithFormat:@"%@/%@", [dictTempData objectForKey:@"cardname"], _StrDiscount];
                    } else {  // 计次卡
                        // 修改字段前面的标题
                        self.lbCardIDTitle.text = @"计次卡号：";
                        self.lbRemainTitle.text = @"余次：";
                        
                        NSDictionary *dictList = ArrayTempListCounts[0];
                        // 清空显示信息
                        _SelectCuCardID = [dictList objectForKey:@"cucardid"];
                        self.lbCardID.text = [dictList objectForKey:@"cardnum"];
                        self.lbRemain_Times.text = [NSString stringWithFormat:@"%@", [dictList objectForKey:@"cardcount"]];
                        self.lbCredits.text = @"0";
                        self.lbCard_discount.text = [NSString stringWithFormat:@"%@/%@", [dictList objectForKey:@"cdname"], _StrDiscount];
                        CardCKLOSS_STATUS = [(NSString *)[dictList objectForKey:@"st"] intValue];
                    }
                } else {  // 储值卡
                    // 修改字段前面的标题
                    self.lbCardIDTitle.text = @"储值卡号：";
                    self.lbRemainTitle.text = @"余额：";
                    
                    // 设置显示信息
                    _SelectCuCardID = @"-1";
                    self.lbCardID.text = [dictTempData objectForKey:@"cucardid"];
                    self.lbRemain_Times.text = [NSString stringWithFormat:@"%@", [dictTempData objectForKey:@"cumoney"]];
                    self.lbCredits.text = [dictTempData objectForKey:@"cuinter"];
                    self.lbCard_discount.text = [NSString stringWithFormat:@"%@/%@", [dictTempData objectForKey:@"cardname"], _StrDiscount];
                    CardCKLOSS_STATUS = [(NSString *)[dictTempData objectForKey:@"st"] intValue];
                }
                self.lbName.text = [dictTempData objectForKey:@"cuname"];
                self.lbphoneNUM.text = [dictTempData objectForKey:@"cumb"];
                self.lbBirday.text = [dictTempData objectForKey:@"cubdate_str"];
                self.lbAddress.text = [dictTempData objectForKey:@"cuaddress"];
                
                if ( CardCKLOSS_STATUS == LOSSCARD_LOSS_STATUS) { // 挂失
                    [self.btnCardLoss_pro setTitle:@"解除挂失" forState:UIControlStateNormal];
                } else {        // 未挂失
                    [self.btnCardLoss_pro setTitle:@"挂失" forState:UIControlStateNormal];
                }
                if([(NSString *)[dictTempData objectForKey:@"cardtypeid"] intValue] > 0)
                    CardTypeFlag = CARD_TYPE_NORMAL_FLAG; // 普通卡
                else
                    CardTypeFlag = CARD_TYPE_METER_FLAG;  // 计次卡
                
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
    if (textField.tag == RECHANGE_VIEW_Type_TAG || textField.tag == MODIFYINFO_VIEW_birday_TAG || textField.tag == ADDCARD_VIEW_Type_TAG || textField.tag == TF_CARDID_TAG || textField.tag == UPGRADECARD_VIEW_Type_TAG) {
        //
        // 添加对应的picker
        if (textField.tag == MODIFYINFO_VIEW_birday_TAG) {  // 显示 datePicker
            self.datePicker.hidden = NO;
            self.pickerViewCardType.hidden = YES;
        }
        
        if (textField.tag == RECHANGE_VIEW_Type_TAG || textField.tag == ADDCARD_VIEW_Type_TAG || textField.tag == TF_CARDID_TAG || textField.tag == UPGRADECARD_VIEW_Type_TAG) {   // 显示数据 picker
            
            self.datePicker.hidden = YES;
            self.pickerViewCardType.hidden = NO;
        }
    }
    
    // 判断点击储值卡时，为空
    if (textField.tag == TF_CARDID_TAG) {
        if ([self.lbCardID.text isEqual:@""]) {
            [MBProgressHUD show:@"请查询会员信息" icon:nil view:nil];
            return NO;
        } else {
            
            if ([self.tfSearch.text isEqual:@""]) {
                [MBProgressHUD show:@"请查询会员信息" icon:nil view:nil];
                return NO;
            }
            
            self.pickerViewCardType.tag = TF_CARDID_TAG; // 设置tag标识
            // 初始化内容  获取网络数据
            NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerGetAction];
            NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&keyword=%@", [self.dictSearchMebInfo objectForKey:@"groupid"], self.tfSearch.text];
            [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
                if (data) { // 请求成功
                    NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    NSString *strStatus = [listData objectForKey:statusCdoe];
                    if ([strStatus intValue] == 200) { // 获取正确的数据
                        listData = [listData objectForKey:MESSAGE];
                        [_MuarrayType removeAllObjects]; // 清空陈旧的数据
                        [_MUarrayAllCards removeAllObjects];
                        
                        _arrayTypeData = [listData objectForKey:@"listcount"];
                        listData = [listData objectForKey:@"cus"];
                        [_MUarrayAllCards addObject:listData];
                        [_MuarrayType addObject:[listData objectForKey:@"cucardid"]]; // 初始化一条数据
                        //self.tfReChange_Type.text = _MuarrayType[0]; // 默认
                        
                        if (_arrayTypeData.count > 0) {  // 有数据
                            // 存入获取到的数据
                            for(NSDictionary *dictTemp in _arrayTypeData) {
                                [_MuarrayType addObject:[dictTemp objectForKey:@"cardnum"]];
                                [_MUarrayAllCards addObject:dictTemp];
                            }
                        }
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
    }
    
    if(textField.tag == ADDCARD_VIEW_CardMoney_TAG) return NO;
    
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
    
    if (_MuarrayType.count == 0 || _MuarrayType == nil) return;
    
    switch (pickerView.tag) {
        case RECHANGE_VIEW_TAG: {  // 充值
            self.tfReChange_Type.text = _MuarrayType[row];
            if(row == 0){
                self.tfReChange_Money.text = @"";
                self.tfReChange_GiveMoney.text = @"";
                break;
            }
            NSDictionary *dictTemp = _arrayTypeData[row - 1];
            self.tfReChange_Money.text = [dictTemp objectForKey:@"realmoney"];
            self.tfReChange_GiveMoney.text = [dictTemp objectForKey:@"freemoney"];
        }
            break;
        case ADDCARD_VIEW_TAG: {   // 新增卡
            self.tfAddCard_Type.text = _MuarrayType[row];
            self.tfAddCard_Money.text = [_arrayTypeData[row] objectForKey:@"cdmoney"];
        }
            break;
        case TF_CARDID_TAG:{     // 选择卡
            NSDictionary *dictTempData = _MUarrayAllCards[row];
            if (row == 0) {  // 储值卡
                // 修改字段前面的标题
                self.lbCardIDTitle.text = @"储值卡号：";
                self.lbRemainTitle.text = @"余额：";
                
                // 设置显示信息
                _SelectCuCardID = @"-1";
                self.lbCardID.text = [dictTempData objectForKey:@"cucardid"];
                self.lbRemain_Times.text = [NSString stringWithFormat:@"%@", [dictTempData objectForKey:@"cumoney"]];
                self.lbCredits.text = [dictTempData objectForKey:@"cuinter"];
                self.lbCard_discount.text = [NSString stringWithFormat:@"%@/%@", [dictTempData objectForKey:@"cardname"], _StrDiscount];
                
                if([(NSString *)[dictTempData objectForKey:@"cardtypeid"] intValue] > 0)
                    CardTypeFlag = CARD_TYPE_NORMAL_FLAG; // 普通卡
                else
                    CardTypeFlag = CARD_TYPE_METER_FLAG;  // 计次卡
            }
            if (_arrayTypeData.count > 0 && row > 0) {  // 计次卡
                // 修改字段前面的标题
                self.lbCardIDTitle.text = @"计次卡号：";
                self.lbRemainTitle.text = @"余次：";
                
                _SelectCuCardID = [dictTempData objectForKey:@"cucardid"];
                self.lbCardID.text = [dictTempData objectForKey:@"cardnum"];
                self.lbRemain_Times.text = [NSString stringWithFormat:@"%@", [dictTempData objectForKey:@"cardcount"]];
                //self.lbCredits.text = [dictTempData objectForKey:@""];
                self.lbCard_discount.text = [NSString stringWithFormat:@"%@/%@", [dictTempData objectForKey:@"cdname"], _StrDiscount];
                CardTypeFlag = CARD_TYPE_METER_FLAG;  // 计次卡
            }
            CardCKLOSS_STATUS = [(NSString *)[dictTempData objectForKey:@"st"] intValue];
            if ([(NSString *)[dictTempData objectForKey:@"st"] intValue] == LOSSCARD_LOSS_STATUS) { // 挂失
                [self.btnCardLoss_pro setTitle:@"解除挂失" forState:UIControlStateNormal];
            } else {        // 未挂失
                [self.btnCardLoss_pro setTitle:@"挂失" forState:UIControlStateNormal];
            }
        }
            break;
        case UPGRADECARD_VIEW_TAG: { // 卡升级
            self.tfUpdateCard_Type.text = _MuarrayType[row];
            _SelectCuCardType = _arrayTypeData[row];
            if (CardTypeFlag == CARD_TYPE_NORMAL_FLAG) { // 普通卡
                self.tfUpdateCard_Money.text = [_arrayTypeData[row] objectForKey:@"cdmoney"];
            } else {    // 计次卡
                self.tfUpdateCard_Money.text = [NSString stringWithFormat:@"%@(次数: %@)", [_arrayTypeData[row] objectForKey:@"cdmoney"], [_arrayTypeData[row] objectForKey:@"cdcount"]];
            }
            
        }
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
    
     float totalMoney = [self.tfReChange_Money.text floatValue] + [self.tfReChange_GiveMoney.text floatValue];
    // 网络请求
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBTopupPaymentAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&emp.empid=%@&totalmoney=%@&paymoney=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], [dictLogin objectForKey:@"empid"], [NSString stringWithFormat:@"%.2f", totalMoney], self.tfReChange_Money.text];
    
    [MBProgressHUD showMessage:@""];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 获取数据失败
            if(strStatus == nil){
                [MBProgressHUD show:@"充值失败" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                // 解析数据
                NSDictionary *dictTemp = [listData objectForKey:MESSAGE];
                
                // 跳转到付款页面
                //切换到下一个界面  --- push
                GetMoneyViewController *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"GetMoney"];
                viewControl.listDict = sendDict;
                viewControl.ReceDict = dictTemp;
                [self.navigationController pushViewController:viewControl animated:YES];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 挂失处理 / 解挂处理
- (void)LossCardDeal {
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 网络请求   --   获取查询数据
    NSString *strURL = @"";
    
    if (CardCKLOSS_STATUS == LOSSCARD_UNLOSS_STATUS) {
        strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerLockCardAction];
    } else {
        strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerFreeCardAction];
    }
    
    
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&keyword=%@&keyword1=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], [NSString stringWithFormat:@"%i", CardTypeFlag], self.lbCardID.text];
    [MBProgressHUD showMessage:@""];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:@"挂失或解除挂失失败" icon:nil view:nil];
                return;
            }
            [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            if ([strStatus intValue] == WebDataIsRight) {
                [self searchBarSearchButtonClicked:nil];
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
    
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&emp.empid=%@&keyword=%@&keyword1=%@&totalmoney=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], [dictLogin objectForKey:@"empid"], self.tfAddCard_CardID.text, [dictSelectedCardType objectForKey:@"cdid"], self.tfAddCard_Money.text];
    
    [MBProgressHUD showMessage:@""];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:@"新赠卡失败" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == WebDataIsRight) { // 获取正确的数据
                NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
                [MBProgressHUD show:@"新增卡成功！" icon:nil view:nil];
                
                // 跳转到付款页面
                //切换到下一个界面  --- push
                GetMoneyViewController *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"GetMoney"];
                viewControl.listDict = sendDict;
                viewControl.ReceDict = dictTempData;
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
                [MBProgressHUD show:@"修改密码失败" icon:nil view:nil];
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
                [MBProgressHUD show:@"修改资料失败" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                // 刷新查询数据
                [MBProgressHUD show:[listData objectForKey: MESSAGE] icon:nil view:nil];
                [self btnSearchInfo:nil];
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
    if([self.tfMakeupCard_CardId.text isEqual:@""] || [self.tfMakeupCard_CardMoney.text isEqual:@""]) {
        [MBProgressHUD show:EmptyINPUTERROR icon:nil view:nil];
        return;
    }
    
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerUpCardActin];
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&keyword=%@&keyword1=%@&emp.empid=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], self.tfMakeupCard_CardId.text, self.tfMakeupCard_CardMoney.text, [dictLogin objectForKey:@"empid"]];
    
    [MBProgressHUD showMessage:@""];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:@"补卡失败，可能输入不正确" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                [MBProgressHUD show:[listData objectForKey: MESSAGE] icon:nil view:nil];
                // 刷新查询数据
                [self btnSearchInfo:nil];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 退卡处理
- (void)CancelCardDeal {
    [self.view endEditing:YES];
    [self textFieldShouldBeginEditing:nil]; // 退出picker
    [self.alertShow close];
    
    // 获取卡的类型对应-----   -1：储值卡   1：计次卡
    //NSString *StrcardtypeId = [self.dictSearchMebInfo objectForKey:@"cardtypeid"];
    //NSString *strFlag = [StrcardtypeId intValue] > 0 ? @"-1" : @"1";
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBNewCardReturnAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"keyword=%@&keyword1=%@&keyword2=%@&emp.empid=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], _SelectCuCardID, self.lbCancelCard_ReMoney.text, [dictLogin objectForKey:@"empid"]];
    
    [MBProgressHUD showMessage:@""];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:@"退卡失败" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                [MBProgressHUD show:[listData objectForKey: MESSAGE] icon:nil view:nil];
                // 刷新查询数据
                [self btnSearchInfo:nil];
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
    if([self.tfUpdateCard_Type.text isEqual:@""] || [self.tfUpdateCard_NewCID.text isEqual:@""]) {
        [MBProgressHUD show:EmptyINPUTERROR icon:nil view:nil];
        return;
    }
    
    [self.view endEditing:YES];
    [self.alertShow close];
    
    NSDictionary *sendDict = @{@"cuaddress": [self.dictSearchMebInfo objectForKey:@"cuaddress"],
                               @"cubdate" : [self.dictSearchMebInfo objectForKey:@"cubdate_str"],
                               @"cucardid":  [self.dictSearchMebInfo objectForKey:@"cucardid"],
                               @"cucardno": [self.dictSearchMebInfo objectForKey:@"cucardno"],
                               @"cuemail" : [self.dictSearchMebInfo objectForKey:@"cuemail"],
                               @"cuname" : [self.dictSearchMebInfo objectForKey:@"cuname"],
                               @"cuphone":  [self.dictSearchMebInfo objectForKey:@"cumb"],
                               @"cupwd": [self.dictSearchMebInfo objectForKey:@"cupwd"],
                               @"selcardmoney": [NSString stringWithFormat:@"%.2f", [self.tfUpdateCard_Money.text floatValue]],
                               @"selcardtype": [NSString stringWithFormat:@"%@%@", [_SelectCuCardType  objectForKey:@"typename"], [_SelectCuCardType objectForKey:@"cdpec"]]};
    
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBNewCardUpGradeAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&emp.empid=%@&keyword=%@&&keyword1=%@&&keyword2=%@&&keyword3=%@&totalmoney=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], [dictLogin objectForKey:@"empid"], self.tfUpdateCard_NewCID.text, [_SelectCuCardType objectForKey:@"cdid"], _SelectCuCardID, [_SelectCuCardType objectForKey:@"cdcount"], [_SelectCuCardType objectForKey:@"cdmoney"]];
    
    [MBProgressHUD showMessage:@""];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:@"退卡失败" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == WebDataIsRight) { // 获取正确的数据
                NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
                [MBProgressHUD show:@"卡升级成功！" icon:nil view:nil];
                
                // 跳转到付款页面
                //切换到下一个界面  --- push
                GetMoneyViewController *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"GetMoney"];
                viewControl.listDict = sendDict;
                viewControl.ReceDict = dictTempData;
                [self.navigationController pushViewController:viewControl animated:YES];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
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
                [MBProgressHUD show:@"获取卡类型数据失败" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                _arrayTypeData = [NSArray arrayWithObject:[listData objectForKey:MESSAGE]];
                _arrayTypeData = _arrayTypeData[0];
                
                
                if (self.pickerViewCardType.tag == UPGRADECARD_VIEW_TAG) { // 卡升级
                    // 判断是否是卡升级
                    _arrayTypeData = [self CardTypeForArrayCardTypeData:_arrayTypeData];
                }
                
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
                [MBProgressHUD show:@"获取新卡号失败" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                self.tfAddCard_CardID.text = [listData objectForKey: MESSAGE];
                self.tfMakeupCard_CardId.text = [listData objectForKey:MESSAGE];
                self.tfUpdateCard_NewCID.text = [listData objectForKey:MESSAGE];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
    }];
}


#pragma mark 精简卡的类型数据（for update Card）
- (NSArray *)CardTypeForArrayCardTypeData:(NSArray *)arrayData {
    NSString *strCardTypeName = @"";
    if(CardTypeFlag == CARD_TYPE_NORMAL_FLAG) { // 打折卡
        strCardTypeName = @"打折卡";
    } else {    // 计次卡
        strCardTypeName = @"计次卡";
    }
    NSMutableArray *muArrayTemp = [NSMutableArray array];
    for (NSDictionary *dict in arrayData) {
        if ([(NSString *)[dict objectForKey:@"typename"] isEqual:strCardTypeName]) {
            [muArrayTemp addObject:dict];
        }
    }
    arrayData = [muArrayTemp mutableCopy];
    
    return arrayData;
}

#pragma mark QRCodeviewdelegate
- (void)QRCodeViewBackString:(NSString *)QRCodeSanString {
    self.tfSearch.text = QRCodeSanString;
    [self searchBarSearchButtonClicked:nil];
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
