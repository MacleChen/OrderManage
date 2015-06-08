//
//  RegisteViewController.m
//  OrderManage
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "RegisteViewController.h"
#import "HttpRequest.h"
#import "GetMoneyViewController.h"
#import "MBProgressHUD+MJ.h"

#define TF_BirthdayTag 10
#define TF_CardTypeTag 20

extern NSDictionary *dictLogin;   // 引用全局登录数据
extern NSDictionary *dictSendLogin;  // 引用发送登录数据

@interface RegisteViewController () <UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSMutableArray *_MuarrayCardType; // 要显示到pcikerview中卡类型字符串
    NSArray *_arrayCardTypeData;   // 接收到的所有类型数据
}

@end

@implementation RegisteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 没有输入注册信息，设置注册按钮为空
    self.btnRegister.enabled = NO;
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    float imgwidth = 20.0, imgheight = 20.0, imgX = 70.0, imgY = 75.0;
    float tfwidth = 180.0, tfheight = 30.0, tfX = 100.0, tfY = 70.0;
    float viewLinewidth = 220.0, viewLineheight = 0.5;
    float viewLineX = ([UIScreen mainScreen].applicationFrame.size.width - viewLinewidth) / 2.0, viewLineY = 103;
    int gap = 50; // 间距
    // 设置代理
    self.scrollView.delegate = self;
    
    // 手机号
    UIImageView *imgViewPhoneNUM = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgPhoneNUM.png"]];
    imgViewPhoneNUM.frame = CGRectMake(imgX, imgY, imgwidth, imgheight);
    UITextField *TF_PhoneNum = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY, tfwidth, tfheight)];
    TF_PhoneNum.placeholder = @"手机号(必填)";
    self.tfPhoneNUM = TF_PhoneNum;
    self.tfPhoneNUM.delegate = self;
    self.tfPhoneNUM.keyboardType = UIKeyboardTypePhonePad;  // 设置键盘类型
    self.tfPhoneNUM.clearButtonMode = UITextFieldViewModeAlways;
    UIView *viewLinePhoneNum = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY, viewLinewidth, viewLineheight)];
    viewLinePhoneNum.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewPhoneNUM];
    [self.scrollView addSubview:TF_PhoneNum];
    [self.scrollView addSubview:viewLinePhoneNum];
    
    // 邮箱
    UIImageView *imgViewEmail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgEmail.png"]];
    imgViewEmail.frame = CGRectMake(imgX, imgY + gap, imgwidth, imgheight);
    UITextField *TF_Email = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap, tfwidth, tfheight)];
    TF_Email.placeholder = @"邮箱(必填)";
    self.tfEmail = TF_Email;
    self.tfEmail.delegate = self;
    self.tfEmail.clearButtonMode = UITextFieldViewModeAlways;
    self.tfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    UIView *viewLineEmail = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap, viewLinewidth, viewLineheight)];
    viewLineEmail.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewEmail];
    [self.scrollView addSubview:TF_Email];
    [self.scrollView addSubview:viewLineEmail];
    
    // 会员生日
    UIImageView *imgViewbirthday = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgbirthday.png"]];
    imgViewbirthday.frame = CGRectMake(imgX, imgY + gap * 2, imgwidth, imgheight);
    UITextField *TF_birthday = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap * 2, tfwidth, tfheight)];
    TF_birthday.placeholder = @"会员生日(必填)";
    self.tfbirthday = TF_birthday;
    self.tfbirthday.delegate = self;
    //self.tfbirthday.text = @"1999-01-01";
    self.tfbirthday.tag = TF_BirthdayTag;
    UIView *viewLinebirthday = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap * 2, viewLinewidth, viewLineheight)];
    viewLinebirthday.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewbirthday];
    [self.scrollView addSubview:TF_birthday];
    [self.scrollView addSubview:viewLinebirthday];
    
    // 会员卡号
    UIImageView *imgViewcardID = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgcardID.png"]];
    imgViewcardID.frame = CGRectMake(imgX, imgY + gap * 3, imgwidth, imgheight);
    UITextField *TF_cardID = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap * 3, tfwidth, tfheight)];
    TF_cardID.placeholder = @"会员卡号(必填)";
    self.tfcardID = TF_cardID;
    self.tfcardID.delegate = self;
    self.tfcardID.keyboardType = UIKeyboardTypeNamePhonePad;  // 设置键盘类型
    self.tfcardID.clearButtonMode = UITextFieldViewModeAlways;
    UIView *viewLinecardID = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap * 3, viewLinewidth, viewLineheight)];
    viewLinecardID.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewcardID];
    [self.scrollView addSubview:TF_cardID];
    [self.scrollView addSubview:viewLinecardID];
    
    // 会员姓名
    UIImageView *imgViewName = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgName.png"]];
    imgViewName.frame = CGRectMake(imgX, imgY + gap * 4, imgwidth, imgheight);
    UITextField *TF_Name = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap * 4, tfwidth, tfheight)];
    TF_Name.placeholder = @"会员姓名(必填)";
    self.tfName = TF_Name;
    self.tfName.delegate = self;
    self.tfName.clearButtonMode = UITextFieldViewModeAlways;
    UIView *viewLineName = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap * 4, viewLinewidth, viewLineheight)];
    viewLineName.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewName];
    [self.scrollView addSubview:TF_Name];
    [self.scrollView addSubview:viewLineName];
    
    // 会员地址
    UIImageView *imgViewaddress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgaddress.png"]];
    imgViewaddress.frame = CGRectMake(imgX, imgY + gap * 5, imgwidth, imgheight);
    UITextField *TF_address = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap * 5, tfwidth, tfheight)];
    TF_address.placeholder = @"会员地址";
    self.tfaddress = TF_address;
    self.tfaddress.delegate = self;
    self.tfaddress.clearButtonMode = UITextFieldViewModeAlways;
    UIView *viewLineaddress = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap * 5, viewLinewidth, viewLineheight)];
    viewLineaddress.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewaddress];
    [self.scrollView addSubview:TF_address];
    [self.scrollView addSubview:viewLineaddress];
    
    // 密码
    UIImageView *imgViewpassword = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgpassword.png"]];
    imgViewpassword.frame = CGRectMake(imgX, imgY + gap * 6, imgwidth, imgheight);
    UITextField *TF_password = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap * 6, tfwidth, tfheight)];
    TF_password.placeholder = @"密码(必填)";
    self.tfpassword = TF_password;
    self.tfpassword.delegate = self;
    self.tfpassword.keyboardType = UIKeyboardTypeNamePhonePad;  // 设置键盘类型
    self.tfpassword.clearButtonMode = UITextFieldViewModeAlways;
    self.tfpassword.secureTextEntry = YES;
    UIView *viewLinepassword = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap * 6, viewLinewidth, viewLineheight)];
    viewLinepassword.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewpassword];
    [self.scrollView addSubview:TF_password];
    [self.scrollView addSubview:viewLinepassword];
    
    // 确认密码
    UIImageView *imgViewsurePass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgsurePass.png"]];
    imgViewsurePass.frame = CGRectMake(imgX, imgY + gap * 7, imgwidth, imgheight);
    UITextField *TF_surePass = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap * 7, tfwidth, tfheight)];
    TF_surePass.placeholder = @"确认密码(必填)";
    self.tfsurePass = TF_surePass;
    self.tfsurePass.delegate = self;
    self.tfsurePass.keyboardType = UIKeyboardTypeNamePhonePad;  // 设置键盘类型
    self.tfsurePass.clearButtonMode = UITextFieldViewModeAlways;
    self.tfsurePass.secureTextEntry = YES;
    UIView *viewLinesurePass = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap * 7, viewLinewidth, viewLineheight)];
    viewLinesurePass.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewsurePass];
    [self.scrollView addSubview:TF_surePass];
    [self.scrollView addSubview:viewLinesurePass];
    
    // 会员卡类型
    UIImageView *imgViewcardType = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgcardType.png"]];
    imgViewcardType.frame = CGRectMake(imgX, imgY + gap * 8, imgwidth, imgheight);
    UITextField *TF_cardType = [[UITextField alloc] initWithFrame:CGRectMake(tfX, tfY + gap * 8, tfwidth, tfheight)];
    TF_cardType.placeholder = @"会员卡类型(必填)";
    self.tfcardType = TF_cardType;
    self.tfcardType.delegate = self;
    self.tfcardType.tag = TF_CardTypeTag;
    UIView *viewLinecardType = [[UIView alloc] initWithFrame:CGRectMake(viewLineX, viewLineY + gap * 8, viewLinewidth, viewLineheight)];
    viewLinecardType.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:imgViewcardType];
    [self.scrollView addSubview:TF_cardType];
    [self.scrollView addSubview:viewLinecardType];
    
    // 设置scrollview
    self.scrollView.contentSize = CGSizeMake(_mainScreenWidth, viewLineY + gap * 12);
    
    // 设置view的手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleBackgroundTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
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
    
    // 设置按钮，点击后退出 datePicker 或 pickerView 选择
    UIButton *btnExitPicker = [[UIButton alloc] initWithFrame:CGRectMake(_mainScreenWidth - 60, 0, 50, 30)];
    btnExitPicker.backgroundColor = ColorMainSystem;
    [btnExitPicker setTitle:@"完成" forState:UIControlStateNormal];
    [btnExitPicker setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnExitPicker addTarget:self action:@selector(btnExitPickerClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.visualEffectView addSubview:btnExitPicker];
    
    // 设置窗口提示信息栏
    UILabel *lb_info = [[UILabel alloc] initWithFrame:CGRectMake(0, MenuAddNotificationHeight, _mainScreenWidth, 20)];
    self.lbInfo = lb_info;
    self.lbInfo.backgroundColor = ColorMainSystem;
    self.lbInfo.textAlignment = UITextAlignmentCenter;
    self.lbInfo.textColor = [UIColor whiteColor];
    self.lbInfo.font = [UIFont systemFontOfSize:12];
    self.lbInfo.hidden = YES;
    [self.view addSubview:self.lbInfo];
    
    // cardType网络数据请求
    [self RegisteCardTypeRequest];
    
    [self.view addSubview:_visualEffectView];
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

#pragma mark - 设置scrollview的代理方法
#pragma mark 当scrollview开始拖拽时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


#pragma mark - textField的代理方法的实现
#pragma mark 正在编辑时，实时调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        if (([string isEqual:@""] && textField.text.length <= 1) || [self.tfPhoneNUM.text isEqual:@""] || [self.tfEmail.text isEqual:@""] || [self.tfbirthday.text isEqual:@""] || [self.tfcardID.text isEqual:@""] || [self.tfName.text isEqual:@""] || [self.tfpassword.text isEqual:@""] || [self.tfsurePass.text isEqual:@""]) {
            self.btnRegister.enabled = NO;
        } else {
            self.btnRegister.enabled = YES;
            NSLog(@"empty, %i, %@", [self.tfEmail isEqual:@""], self.tfEmail);
            
        }
    
    // 限制手机号的位数
    if (self.tfPhoneNUM.text.length > PHONENUMCOUNT)  return NO;
    
        return YES;
}

#pragma mark 当完成编辑时调用该方法
- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 手机号格式验证
    if ((self.tfPhoneNUM.text.length < PHONENUMCOUNT) && ![self.tfPhoneNUM.text isEqual:@""]) {    // 验证手机号码的号数
        self.lbInfo.hidden = NO;
        self.lbInfo.text = @"手机号输入不正确";
    }
    
    // 验证邮箱格式
    if (![viewOtherDeal isValidateEmail:self.tfEmail.text] && ![self.tfEmail.text isEqual:@""]) {
        self.lbInfo.hidden = NO;
        self.lbInfo.text = @"邮箱格式不正确";
    }
}

#pragma mark 当textfield开始编辑时调用
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGRect datepicFrame = self.visualEffectView.frame;
    
    // 添加对应的picker
    if (textField.tag == TF_BirthdayTag) {
        self.datePicker.hidden = NO;
        self.pickerViewCardType.hidden = YES;
    }
    if (textField.tag == TF_CardTypeTag) {
        self.datePicker.hidden = YES;
        self.pickerViewCardType.hidden = NO;
    }
    // 添加动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    if (textField.tag == TF_BirthdayTag || textField.tag == TF_CardTypeTag) {  // 开始编辑 会员生日
        [self.view endEditing:YES];
        // 显示placeholder
       if(textField.tag == TF_BirthdayTag) self.tfbirthday.text = @"";
       else self.tfcardType.text = @"";
        
        datepicFrame.origin.y = _mainScreenHeight - datepicFrame.size.height;
        
    } else {
        datepicFrame.origin.y = _mainScreenHeight;
    }
    
    // 隐藏lbinfo提示窗口
    self.lbInfo.hidden = YES;
    NSLog(@"开始编辑");
    
    self.visualEffectView.frame = datepicFrame;
    [UIView commitAnimations];
    
    if (textField.tag == TF_BirthdayTag || textField.tag == TF_CardTypeTag) return NO;
    return YES;
}

#pragma mark 点击背景时，退出键盘
-(void)HandleBackgroundTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark 滚动datePicker调用的方法
- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;     // 获取datePicker的时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyyMMdd";  // 设置时间格式
    
    self.tfbirthday.text = [dateFormat stringFromDate:selectedDate]; // 将时间转化为NSString
}

#pragma mark - 检测键盘的调出，退出
#pragma mark 检测键盘的调出
- (void)keyboardDidShow:(NSNotification *)aNotfication {
    
    
    
}

#pragma mark 检测键盘的退出
- (void)keyboardDidHide {

}

#pragma mark - pickerView代理方法的实现
#pragma mark 设置有多少个组件块
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark 设置每个组件中有多少个row
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _MuarrayCardType.count;
}

#pragma mark 设置每个组件中的row的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return _MuarrayCardType[row];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.tfcardType.text = _MuarrayCardType[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = UITextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:13]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

#pragma mark 点击picker的完成按钮时调用该方法
- (void)btnExitPickerClick:(UIButton *)sender {
    [self textFieldShouldBeginEditing:self.tfpassword];
}

#pragma mark 点击注册按钮时调用
- (IBAction)btnregisteClick:(UIButton *)sender {
    // 判断两次输入密码是否相等
    if (![self.tfpassword.text isEqual:self.tfsurePass.text]) {
        self.lbInfo.hidden = NO;
        self.lbInfo.text = @"密码不相等";
        
        return;
    }
    
    // 显示进度框
    [MBProgressHUD showMessage:@""];
    
    NSInteger selectedCardTypeRow = [self.pickerViewCardType selectedRowInComponent:0];
    NSDictionary *dictCardType = _arrayCardTypeData[selectedCardTypeRow];
    // 会员卡类型打包
    NSString *strcdType = [NSString stringWithFormat:@"%@/%@", [dictCardType objectForKey:@"cdname"], [dictCardType objectForKey:@"cdpec"]];
    // 打包注册数据
    NSDictionary *dictRegisteData =@{@"cuname": self.tfName.text,
                                     @"cuemail": self.tfEmail.text,
                                     @"cupwd": self.tfpassword.text,
                                     @"cuphone": self.tfPhoneNUM.text,
                                     @"cuaddress": self.tfaddress.text,
                                     @"cucardid": [dictCardType objectForKey:@"cdid"],
                                     @"cucardno": self.tfcardID.text,
                                     @"cubdate": self.tfbirthday.text,
                                     @"selcardmoney": [dictCardType objectForKey:@"cdmoney"],
                                     @"selcardtype": strcdType};
    
    
    // 网络数据请求 --- 请求导购数据
    NSString *strMyURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerAddAction];
    
    //test
    NSString *strURLBody = [NSString stringWithFormat:@"cuname=%@&cuemail=%@&cupwd=%@&cuphone=%@&cuaddress=%@&cucardid=%@&cucardno=%@&cubdate=%@&emp.empid=%@", self.tfName.text, self.tfEmail.text, self.tfpassword.text, self.tfPhoneNUM.text, self.tfaddress.text, [dictCardType objectForKey:@"cdid"], self.tfcardID.text, self.tfbirthday.text, [dictSendLogin objectForKey:@"userPwd"]];    //[dictSendLogin objectForKey:@"userPwd"]       //[dictLogin objectForKey:@"emppwd"]
    // POST请求:请求体
    
    // 2.1.设置请求路径
    NSURL *url = [NSURL URLWithString:strMyURL];
    
    // 2.2.创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; // 默认就是GET请求
    request.timeoutInterval = 5; // 设置请求超时
    request.HTTPMethod = @"POST"; // 设置为POST请求
    
    // 通过请求头告诉服务器客户端的类型
    [request setValue:@"IOS客户端" forHTTPHeaderField:@"User-Agent"];
    
    // 采用，改进的MD5加密 --- 对加密过的MD5码再进行一次特殊算法加密
    
    // 设置请求体
    request.HTTPBody = [strURLBody dataUsingEncoding:NSUTF8StringEncoding];
    
    // 2.3.发送请求
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {  // 当请求结束的时候调用 (拿到了服务器的数据, 请求失败)
        // 隐藏HUD (刷新UI界面, 一定要放在主线程, 不能放在子线程
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            
            // 隐藏进度框
            [MBProgressHUD hideHUD];
            
            if ([strStatus intValue] == 200) { // 获取正确的数据
                [MBProgressHUD hideHUD];
                [MBProgressHUD showMessage:@"注册成功"];
                //切换到下一个界面  --- push
                GetMoneyViewController *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"GetMoney"];
                viewControl.listDict = dictRegisteData;
                viewControl.ReceDict = [listData objectForKey:message];
                [self.navigationController pushViewController:viewControl animated:YES];
            } else { // 数据有问题
                self.lbInfo.hidden = NO;
                self.lbInfo.text = [listData objectForKey:message];
            }
        } else { // 请求失败
            self.lbInfo.hidden = NO;
            self.lbInfo.text = ConnectException;
            
            // 隐藏进度框
            [MBProgressHUD hideHUD];
        }
    }];
}

#pragma RegisteCardTypeRequest 会员卡的类型数据请求
- (void)RegisteCardTypeRequest {
    NSString *strURLCardType = [NSString stringWithFormat:@"%@%@groupid=%@&shopid=%@&keyword=discount", WEBBASEURL, WEBFindCardAction, [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"shopid"]];
    NSString *strURLCardNum = [NSString stringWithFormat:@"%@%@shopid=%@", WEBBASEURL, WEBNewCardNumAction, [dictLogin objectForKey:@"shopid"]];
    
    _MuarrayCardType = [[NSMutableArray alloc] init];
    
    NSOperationQueue *operQueue = [[NSOperationQueue alloc] init];
    [operQueue addOperationWithBlock:^{ // 产生子线程
        // 请求 shopid对应的卡号
        id listCardNumData = [HttpRequest HttpAFNetworkingRequestWithURL_Two:strURLCardNum parameters:nil];
        
        // 请求卡类型数据
        id ListData = [HttpRequest HttpAFNetworkingRequestWithURL_Two:strURLCardType parameters:nil];
        NSLog(@"currentThread1 -- %@", [NSThread currentThread]);
        
        // 切换到主线程中设置数据
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 回到主线程中
            _arrayCardTypeData = [NSArray arrayWithObject:[ListData objectForKey:message]];
            _arrayCardTypeData = _arrayCardTypeData[0];
            for (int i = 0; i < _arrayCardTypeData.count; i++) {
                NSDictionary *dictTemp = _arrayCardTypeData[i];
                NSString *strcardType = [NSString stringWithFormat:@"%@ | %@ | 价格：%@ | 次数：%@ ", [dictTemp objectForKey:@"typename"], [dictTemp objectForKey:@"cdname"], [dictTemp objectForKey:@"cdmoney"], [dictTemp objectForKey:@"cdcount"]];
                [_MuarrayCardType addObject:strcardType];
            }
            self.tfcardID.text = [listCardNumData objectForKey:message];
            [self.pickerViewCardType reloadAllComponents];
        }];
    }];
}

@end
