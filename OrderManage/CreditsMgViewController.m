//
//  CreditsMgViewController.m
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "CreditsMgViewController.h"

#import "viewOtherDeal.h"
#import "QRCodeViewController.h"

#define TF_SELECT_CREDITS_TAG 30  // 选择积分的类型

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface CreditsMgViewController () <AVCaptureMetadataOutputObjectsDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, QRCodeViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSMutableArray *_MuarrayType; // 要显示到pcikerview中卡类型字符串
    NSArray *_arrayTypeData;   // 接收到的所有类型数据
}

@end

@implementation CreditsMgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    self.dictSearchMebInfo = [[NSDictionary alloc] init];
    _MuarrayType = [[NSMutableArray alloc] init];
    _arrayTypeData = [[NSArray alloc] init];
    
    // 设置背景图片
    [self.btnSaoyisao setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"saoyisao6.png"] size:CGSizeMake(30, 25)] forState:UIControlStateNormal];
    [self.btnSearch setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"searchBtnImg2.png"] size:CGSizeMake(45, 30)] forState:UIControlStateNormal];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + TOP_MENU_HEIGHT;
    
    // 设置代理
    self.tfSearch.delegate = self;
    self.tfSelectCredits.delegate = self;
    self.tfInputCredits.delegate = self;
    
    // 设置毛玻璃的背景
    UIVisualEffectView *visEffView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.visualEffectView = visEffView;
    self.visualEffectView.frame = CGRectMake(0, _mainScreenHeight, _mainScreenWidth, INPUTVIEW_HEIGHT);
    self.visualEffectView.alpha = 1.0;
    
    // 设置pickerView
    UIPickerView *pickerCardType = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, _mainScreenWidth, INPUTVIEW_HEIGHT)];
    self.pickerViewCardType = pickerCardType;
    self.pickerViewCardType.delegate = self;
    self.pickerViewCardType.dataSource = self;
    [self.visualEffectView addSubview:self.pickerViewCardType];
    
    // 设置键盘类型
    self.tfSelectCredits.inputView = self.visualEffectView;
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

#pragma mark 增加积分
- (IBAction)btnAddCreidtsClick:(UIButton *)sender {
    if ([self.tfSearch.text isEqual:@""]) {
        [MBProgressHUD show:@"请先查询会员信息" icon:nil view:nil];
        return;
    }
    // 判断输入积分不能小于等于0
    if ([self.tfInputCredits.text intValue] <= 0) {
        [MBProgressHUD show:@"请输入积分" icon:nil view:nil];
        return;
    }
    
    // 处理增加积分
    [MBProgressHUD showMessage:@""];
    // 网络请求
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerAddCredits];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&keyword=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], self.tfInputCredits.text];
    
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
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
                [self btnSearchInfo:nil]; // 重新刷新数据
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
    
}

#pragma mark 扣除积分
- (IBAction)btnDeductClick:(UIButton *)sender {
    if ([self.tfSearch.text isEqual:@""]) {
        [MBProgressHUD show:@"请先查询会员信息" icon:nil view:nil];
        return;
    }
    // 处理扣除积分
    // 判断输入积分不能小于等于0
    if ([self.tfInputCredits.text intValue] <= 0) {
        [MBProgressHUD show:@"请输入积分" icon:nil view:nil];
        return;
    }
    
    [MBProgressHUD showMessage:@""];
    // 网络请求
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerSubCredits];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"cus.cuid=%@&keyword=%@", [self.dictSearchMebInfo objectForKey:@"cuid"], self.tfInputCredits.text];
    
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
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
                [self btnSearchInfo:nil]; // 重新刷新数据
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];

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
                [MBProgressHUD show:@"手机号或会员卡号不存在" icon:nil view:nil];
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
                    return;
                }
                // 设置显示信息
                self.lbCardID.text = [dictTempData objectForKey:@"cucardid"];
                self.lbRemain_Times.text = [dictTempData objectForKey:@"cumoney"];
                self.lbCredits.text = [dictTempData objectForKey:@"cuinter"];
                self.lbCard_discount.text = [NSString stringWithFormat:@"%@/%@", [dictTempData objectForKey:@"cardname"], [dictTempData objectForKey:@"cdpec"]];
                self.lbName.text = [dictTempData objectForKey:@"cuname"];
                self.lbphoneNUM.text = [dictTempData objectForKey:@"cumb"];
                self.lbBirday.text = [dictTempData objectForKey:@"cubdate_str"];
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
    
    
}


#pragma mark - textField的代理方法的实现
#pragma mark 正在编辑时，实时调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

#pragma mark 当完成编辑时调用该方法
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark 当textfield开始编辑时调用
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // 获取网络数据 -- 选择积分类型
    if (textField.tag == TF_SELECT_CREDITS_TAG) {
        [self getWebDataCreditsType];
    }
    
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
    if (row == 0) {
        return _MuarrayType[row];
    }
    
    NSDictionary *dictTemp = _MuarrayType[row];
    return [NSString stringWithFormat:@"%@(%@)", [dictTemp objectForKey:@"gname"], [dictTemp objectForKey:@"integral"]];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_MuarrayType.count > 0) {
        if (row == 0) {
            self.tfSelectCredits.text = _MuarrayType[row];
            self.tfInputCredits.text = @"";
            return;
        }
        NSDictionary *dicTemp = _MuarrayType[row];
        self.tfSelectCredits.text = [dicTemp objectForKey:@"gname"];
        self.tfInputCredits.text = [dicTemp objectForKey:@"integral"];
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

#pragma mark 获取网络数据 -- 积分类型
- (void)getWebDataCreditsType {
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerGetGifList];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"shopid=%@", [dictLogin objectForKey:@"shopid"]];
    
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
                [_MuarrayType removeAllObjects]; // 清空
                
                // 设置默认数据
                [_MuarrayType addObject:@"不兑换礼品"];
                NSArray *arrayDataTemp = [dictTempData objectForKey:@"giftList"];
                for (NSDictionary *dict in arrayDataTemp) {
                    [_MuarrayType addObject:dict];
                }
                
                // 刷新pickerview的数据
                [self.pickerViewCardType reloadAllComponents];
                
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


#pragma mark QRCodeviewdelegate
- (void)QRCodeViewBackString:(NSString *)QRCodeSanString {
    self.tfSearch.text = QRCodeSanString;
    [self btnSearchInfo:nil];
    //[self searchBarSearchButtonClicked:nil];
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
