//
//  PayBillViewController.m
//  OrderManage
//
//  Created by mac on 15/6/21.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "PayBillViewController.h"
#import "viewOtherDeal.h"
#import "MBProgressHUD+MJ.h"
#import "HttpRequest.h"
#import "Global.h"
#import "GetAllDataModels.h"
#import "PrintDeviceSet.h"

#define VIEW_PayCalculate_TAG 305                       // 结算扣次界面
#define VIEW_PayCalculate_TFPASSWORD_TAG 3051           // 交易密码
#define VIEW_PayCalculate_TFPIVILEGECount_TAG 3052      // 优惠次数
#define VIEW_PayCalculate_TFBUSSMAN_TAG 3053            // 业务员

#define VIEW_PrintAlertView_TAG  307   // 打印单据提示小窗口

#define CELL_HEIGHT 50

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface PayBillViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSInteger _memberTotalCount;  // 会员的总数量
    int _pages;     // 页数
    
    NSMutableArray *_muArrayData; // 存储显示在界面上的数据
    
    NSMutableArray *_MuarrayType;   // 显示在pickerview中的数据
    
    NSInteger _allProductsSelectedCount;   // 获得所有商品的个数
    NSString  *_selectBussManid; // 所选的业务员id
    
    NSDictionary *_dictSavePaySuccessedData; // 储存支付成功后的data
    NSString *_stringPrintInfo;   // 需要打印的信息
}

@end

@implementation PayBillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    _muArrayData = [NSMutableArray arrayWithArray:self.arrayRecData];
    _MuarrayType = [NSMutableArray array];
    _selectBussManid = @"";
    _dictSavePaySuccessedData = [NSDictionary dictionary];
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + TOP_MENU_HEIGHT;
    
    // 设置代理
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    // 设置tableview 第一个cell距离导航栏的高度
    self.tableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 65)];
    
    // 获取所有商品个数
    _allProductsSelectedCount = 0;
    for (NSDictionary *dict in _muArrayData) {
        NSString *selectedCount = [dict objectForKey:@"SelectedCount"];
        _allProductsSelectedCount += [selectedCount integerValue];
    }
    self.lbCustomCount.text = [NSString stringWithFormat:@"共：%li次", (long)_allProductsSelectedCount];
    
    // 设置alertView
    self.alertShow = [[CustomIOS7AlertView alloc] init];
    [self.alertShow setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
    self.alertShow.useMotionEffects = YES;
    // 设置代理
    self.alertShow.delegate = self;
    
    // 设置毛玻璃的背景
    UIVisualEffectView *visEffView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.visualEffectView = visEffView;
    self.visualEffectView.frame = CGRectMake(0, _mainScreenHeight, _mainScreenWidth, INPUTVIEW_HEIGHT);
    self.visualEffectView.alpha = 1.0;
    
    // 设置pickerView
    UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, _mainScreenWidth, INPUTVIEW_HEIGHT)];
    self.pickerViewData = picker;
    self.pickerViewData.delegate = self;
    self.pickerViewData.dataSource = self;
    [self.visualEffectView addSubview:self.pickerViewData];
    
    // 获取xib的视图
    [self GetXibViewForAlertview];
}


#pragma mark 清空按钮响应方法
- (IBAction)itemBtnClearClick:(UIBarButtonItem *)sender {
    [_muArrayData removeAllObjects];
    [self.tableview reloadData];
    
    [MBProgressHUD show:@"已清空" icon:nil view:nil];
}

#pragma mark 结算确认响应方法
- (IBAction)btnSurePayBillClick:(UIButton *)sender {
    self.viewPayCalculate.frame = CGRectMake(0, 0, 300, 170);
    
    [self.alertShow show];
}

#pragma mark - tableview 的代理方法实现
#pragma mark  设置有几个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark 设置每个section中有几个cell
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _muArrayData.count;
}

#pragma mark 设置每个cell的内容
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;   // 取消点击色
    NSDictionary *dictTempData =  _muArrayData[indexPath.row];
    
    // 设置背景色
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = ColorTableCell;
    }
    
    // 设置内容
    cell.textLabel.text = [dictTempData objectForKey:@"prodname"];
    NSString *strSinglePrice = [NSString stringWithFormat:@"%@ / %@", [dictTempData objectForKey:@"prodmoney"], [dictTempData objectForKey:@"produnit"]];
    float ProductAllMoney = [(NSString *)[dictTempData objectForKey:@"prodmoney"] floatValue] * [(NSString *)[dictTempData objectForKey:@"SelectedCount"] floatValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"已选：%@件  单价：%@  总价：%.2f", [dictTempData objectForKey:@"SelectedCount"], strSinglePrice, ProductAllMoney];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    
    return cell;
}

#pragma mark 设置section头的标题
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark 设置section的脚的标题
- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
    
}

#pragma mark 当开始拖拽时调用的方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark 设置每个row的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark  选中cell时响应方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //切换到下一个界面  --- push
//    OrderDetailTableViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetail"];
//    viewControl.dictData = _muArrayData[indexPath.section][indexPath.row];  // 传入数据
//    [self.navigationController pushViewController:viewControl animated:YES];
}


- (void)GetXibViewForAlertview {
    // 设置界面
    // 从xib中获取views
    NSArray *viewsMemberMg = [[NSBundle mainBundle] loadNibNamed:@"MeterCardSearchView" owner:nil options:nil];
    
    // 寻找view -- 获取对应的view
    for (UIView *viewTemp in viewsMemberMg) {
        if (viewTemp.tag == VIEW_PayCalculate_TAG) {
            self.viewPayCalculate = viewTemp;
        }
    }

    // 获取viewSearch的控件
    NSArray *viewsInviewPayCal = [self.viewPayCalculate subviews];
    for (UITextField *tfTemp in viewsInviewPayCal) {
        if(tfTemp.tag == VIEW_PayCalculate_TFPASSWORD_TAG) self.tfPayCalPwd = tfTemp;
        if(tfTemp.tag == VIEW_PayCalculate_TFPIVILEGECount_TAG) self.tfPayCalPrivilegeCount = tfTemp;
        if(tfTemp.tag == VIEW_PayCalculate_TFBUSSMAN_TAG) self.tfPayCalBussMan = tfTemp;
    }
    
    // 设置代理
    self.tfPayCalPwd.delegate = self;
    self.tfPayCalPrivilegeCount.delegate = self;
    self.tfPayCalBussMan.delegate = self;
    
    // 设置键盘类型
    self.tfPayCalPwd.secureTextEntry = YES;
    self.tfPayCalPwd.keyboardType = UIKeyboardTypeNamePhonePad;
    self.tfPayCalPrivilegeCount.keyboardType = UIKeyboardTypeNumberPad;
    self.tfPayCalBussMan.inputView = self.visualEffectView;

    // 设置初始化
    self.tfPayCalBussMan.text = @"无";
    
    // 将view显示在alertview中
    [self.alertShow setContainerView:self.viewPayCalculate];
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
    return [dictTemp objectForKey:@"empnickname"];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_MuarrayType.count > 0) {
        if (row == 0) {
            self.tfPayCalBussMan.text = _MuarrayType[row];
            return;
        }
        NSDictionary *dicTemp = _MuarrayType[row];
        _selectBussManid = [dicTemp objectForKey:@"empid"];
        self.tfPayCalBussMan.text = [dicTemp objectForKey:@"empnickname"];
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
    if (textField.tag == VIEW_PayCalculate_TFBUSSMAN_TAG) {
        // 获取业务员的数据
        [self GetBussMansList];
    }
    
    return YES;
}


#pragma mark -  CustomIOS7AlertViewDelegate 的代理方法实现
/**
 *  customIOS7dialogButtonTouchUpInside 方法
 */
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 获取那个按钮点击
    if(buttonIndex == 0) {
        [self.alertShow close];
        return;
    } // 点击取消返回
    
    // 判断是否是打印单据的小窗口
    if (self.alertShow.tag == VIEW_PrintAlertView_TAG) {
        [self PrintMeterCardPaySuccessInfo];
        return;
    }
    
    // 判断输入不能为空
    if([self.tfPayCalPwd.text isEqual:@""]) {
        [MBProgressHUD show:@"密码不能为空" icon:nil view:nil];
        return;
    }
    
    // 提交数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCountSalePayMentAction];
    
    NSMutableArray *muArrayTemp = [[NSMutableArray alloc] init];
    NSDictionary *dictMebInfoTemp = [self.dictSearchMebInfo objectForKey:@"cus"];
    for (NSDictionary *dict in _muArrayData) {
        GetPayBillViewModel *getPayBill = [[GetPayBillViewModel alloc] init];
        getPayBill.prodid = [(NSString *)[dict objectForKey:@"prodid"] intValue];
        getPayBill.prodname = [dict objectForKey:@"prodname"];
        getPayBill.prodprice = [(NSString *)[dict objectForKey:@"poor"] floatValue];
        getPayBill.prodmoney = [(NSString *)[dict objectForKey:@"prodmoney"] floatValue];
        getPayBill.point = [(NSString *)[dict objectForKey:@"point"] intValue];
        getPayBill.prodcount = [(NSString *)[dict objectForKey:@"SelectedCount"] intValue];
        getPayBill.prodpec = [(NSString *)[dictMebInfoTemp objectForKey:@"cdpec"] intValue];
        
        NSDictionary *dictTemp = [viewOtherDeal getObjectData:getPayBill];
        [muArrayTemp addObject:dictTemp];
    }
    NSString *strJson = @"";
    NSArray *arrayTemp = [NSArray arrayWithArray:muArrayTemp];  // 数组转换
    NSData *dataTemp = [viewOtherDeal toJSONData:arrayTemp];
    if (dataTemp != nil) {
        strJson = [[NSString alloc] initWithData:dataTemp encoding:NSUTF8StringEncoding];
    }

    NSString *strHttpBody = [NSString stringWithFormat:@"emp.empid=%@&cupwd=%@&freecount=%@&cuid=%@&cucardid=%@&keyword=%@&empids1=%@", [dictLogin objectForKey:@"empid"], self.tfPayCalPwd.text, [NSString stringWithFormat:@"%ld", -(long)_allProductsSelectedCount], [self.dictSelectMeterCard objectForKey:@"cuid"], [self.dictSelectMeterCard objectForKey:@"cucardid"], strJson, _selectBussManid];
    
    [self.alertShow close];
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
                _dictSavePaySuccessedData = [listData objectForKey:MESSAGE];
                
                self.paySuccessViewInAlert = [self GetPaySuccessAlertView];
                [self.alertShow setContainerView:self.paySuccessViewInAlert];
                self.alertShow.tag = VIEW_PrintAlertView_TAG;
                [self.alertShow show];
                
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
    }];
}


/**
 *  获取业务员列表
 */
- (void)GetBussMansList {
    // 获取业务员的列表
    // 获取网络数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBFindEmp];
    
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
                // 解析数据
                [_MuarrayType removeAllObjects];
                [_MuarrayType addObject:@"无"];
                [_MuarrayType addObjectsFromArray:[listData objectForKey:MESSAGE]];
                
                // 重新刷新数据
                [self.pickerViewData reloadAllComponents];
                
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 获取现金，优惠券支付的成功后的小窗口
- (UIView *)GetPaySuccessAlertView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width - 100)/2, 5, 100, 30)];
    lbTitle.text = @"支付成功";
    lbTitle.font = [UIFont boldSystemFontOfSize:16.0];
    lbTitle.textColor = [UIColor blackColor];
    lbTitle.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lbTitle];
    
    QCheckBox *_checkPrint = [[QCheckBox alloc] initWithDelegate:self];     // 储值卡会员消费
    _checkPrint.frame = CGRectMake((view.frame.size.width - 100)/2, 55, 100, 30);
    _checkPrint.center = CGPointMake(view.frame.size.width/2, 55);
    [_checkPrint setTitle:@"打印单据" forState:UIControlStateNormal];
    [_checkPrint setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkPrint.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.ckPrintList = _checkPrint;
    self.ckPrintList.checked = YES;
    [view addSubview:_checkPrint];
    
    // 设置tag值
    view.tag = VIEW_PrintAlertView_TAG;
    
    return view;
}

#pragma mark 打印单据
- (void)PrintMeterCardPaySuccessInfo {
    // 判断是否打印单据
    NSDictionary *dictRecord = [_dictSavePaySuccessedData objectForKey:@"record"];
    NSDictionary *dictMeterCard = [_dictSavePaySuccessedData objectForKey:@"card"];
    if (self.ckPrintList.checked) {
        // 设置打印数据
            // 设置需要打印的数据
            _stringPrintInfo = [NSString stringWithFormat:@"\
                   计次卡支付\n\
    --------------------------------------\n\n\
    用户名:                %@\n\
    订单号:                %@\n\
    订单类型:              %@\n\
    支付次数:              %@\n\
    剩余次数:              %@\n\
    支付金额:              %@\n\
    生成日期:              %@\n\
    支付状态:              已支付\n", [dictRecord objectForKey:@"cuname"], [dictRecord objectForKey:@"rccode"], [dictRecord objectForKey:@"typename"], self.lbCustomCount.text, [dictMeterCard objectForKey:@"cardcount"], [dictRecord objectForKey:@"lostmoney"], [dictRecord objectForKey:@"rcdate"]];
            
                // 打印单据
        [self PrintInfoWithString:_stringPrintInfo];
        [MBProgressHUD show:@"打印成功" icon:nil view:nil];
    } else {
        [MBProgressHUD show:@"未打印单据" icon:nil view:nil];
    }
    
    [self.alertShow close];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/**
 *  打印机打印数据
 */
- (void)PrintInfoWithString:(NSString *)stringInfo {
    NSError *error;
    // 连接对应的IP和端口
    if (![self.asyncSocket connectToHost:WEBPRINT_IP onPort:WEBPRINT_PORT error:&error]) {
        MyPrint(@"error:%@", error);
    }
}


#pragma mark - GCDAsyncSocketDelegate 代理方法的实现
#pragma mark 已连接上网络设备之后调用的方法
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    MyPrint(@"已连接： host:%@, port:%i", host, port);
    
    // 打印机初始化
    [PrintDeviceSet PrintDeviceInitWithSocket:self.asyncSocket];
    
    // 写数据  -- 中文编码 GBK
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *writeData = [_stringPrintInfo dataUsingEncoding:encoding];
    
    [self.asyncSocket writeData:writeData withTimeout:5 tag:TAG_FIXED_LENGTH_HEADER];
    
    // 打印机结束处理
    [PrintDeviceSet PrintDeviceEndDealWithSocket:self.asyncSocket];
    
    [self.asyncSocket disconnect]; // 断开连接
}

#pragma mark 发送TCP/IP数据包
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    MyPrint(@"thread(%@),onSocket:%p didWriteDataWithTag:%ld",[[NSThread currentThread] name], self.asyncSocket, tag);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    MyPrint(@"连接失败：%@", err);
    [self.asyncSocket disconnect]; // 断开连接
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
