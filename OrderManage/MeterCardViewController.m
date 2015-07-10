//
//  MeterCardViewController.m
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "MeterCardViewController.h"
#import "viewOtherDeal.h"
#import "MBProgressHUD+MJ.h"
#import "viewOtherDeal.h"
#import "HttpRequest.h"
#import "PayBillViewController.h"
#import "QRCodeViewController.h"

#define CELL_HEIGHT 40

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface MeterCardViewController () <PullTableViewDelegate, CustomIOS7AlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, QRCodeViewDelegate, UISearchBarDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSInteger _memberTotalCount;  // 会员的总数量
    int _pages;     // 页数
    
    NSMutableArray *_MuarrayType; // 要显示到pcikerview中卡类型字符串
    
    NSMutableArray *_muArrayData; // 存储显示在界面上的数据
    NSArray *_arrayGetWebData;   // 获取网络数据
}

@end

@implementation MeterCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + TOP_MENU_HEIGHT;
    
    // 初始化信息
    self.dictSearchMebInfo = [NSDictionary dictionary];
    _MuarrayType = [NSMutableArray array];
    self.itemSearch.image = [viewOtherDeal scaleToSize:[UIImage imageNamed:@"credits_search2.png"] size:ITEM_IMAGE_CGSZE];
    
    // 设置代理
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    // 设置pullTableview
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor groupTableViewBackgroundColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
    
    // 设置tableview 第一个cell距离导航栏的高度
    self.pullTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 65 + CELL_HEIGHT)];
    self.pullTableView.tableHeaderView.alpha = 0.0;
    
    // 设置alertView
    self.alertShow = [[CustomIOS7AlertView alloc] init];
    [self.alertShow setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
    self.alertShow.useMotionEffects = YES;
    // 设置代理
    self.alertShow.delegate = self;
    
    // 设置毛玻璃的背景
    UIVisualEffectView *visEffView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.visualEffectView = visEffView;
    self.visualEffectView.frame = CGRectMake(0, 0, _mainScreenWidth, INPUTVIEW_HEIGHT);
    self.visualEffectView.alpha = 1.0;
    
    // 设置pickerView
    UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, _mainScreenWidth, INPUTVIEW_HEIGHT)];
    self.pickerViewData = picker;
    self.pickerViewData.delegate = self;
    self.pickerViewData.dataSource = self;
    [self.visualEffectView addSubview:self.pickerViewData];
}



#pragma mark 搜索
- (IBAction)itemBtnSearchClick:(UIBarButtonItem *)sender {
    // 设置界面
    // 从xib中获取views
    NSArray *viewsMemberMg = [[NSBundle mainBundle] loadNibNamed:@"MeterCardSearchView" owner:nil options:nil];
    
    // 寻找view -- 获取对应的view
    if(viewsMemberMg.count > 0)
        self.viewSearch = viewsMemberMg[0];
    
    // 获取viewSearch的控件
    NSArray *viewsInviewSearch = [self.viewSearch subviews];
    for (id viewTemp in viewsInviewSearch) {
        if(((UIButton *)viewTemp).tag == BTN_SAOYISAO_TAG) self.btnSaoyiSao = viewTemp;
        if(((UISearchBar *)viewTemp).tag == BARSEARCH_TEXTFIELD_TAG) self.seaBarInput = viewTemp;
        if(((UIButton *)viewTemp).tag == BTN_SEARCH_TAG) self.btnAlertSearch = viewTemp;
        if(((UILabel *)viewTemp).tag == LB_METERCARDID_TAG) self.lbMeterCardID = viewTemp;
        if(((UILabel *)viewTemp).tag == LB_REMIANCOUNT_TAG) self.lbRemainCount = viewTemp;
        if(((UILabel *)viewTemp).tag == LB_CREDITS_TAG) self.lbCredits = viewTemp;
        if(((UILabel *)viewTemp).tag == LB_NAME_TAG) self.lbName = viewTemp;
        if(((UILabel *)viewTemp).tag == LB_PHONE_TAG) self.lbPhoneNum = viewTemp;
        if(((UILabel *)viewTemp).tag == LB_BIRTHDAY_TAG) self.lbBirthday = viewTemp;
        if(((UILabel *)viewTemp).tag == LB_REGISTEADDRESS_TAG) self.lbRegisteAddr = viewTemp;
        if(((UITextField *)viewTemp).tag == TF_METERCARDID_SELECTS_TAG) self.tfMeterCardIDSelects = viewTemp;
    }
    
    // 设置代理
    self.tfMeterCardIDSelects.delegate = self;
    
    // 设置键盘类型
    self.tfMeterCardIDSelects.inputView = self.visualEffectView;
    
    // 设置响应方法
    [self.btnSaoyiSao addTarget:self action:@selector(btnQRCodeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAlertSearch addTarget:self action:@selector(btnSearchAlertInClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置view的手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleBackgroundTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.alertShow addGestureRecognizer:tapGesture];
    
    // 将view显示在alertview中
    [self.alertShow setContainerView:self.viewSearch];
    [self.alertShow show];
}

#pragma mark 结算按钮
- (IBAction)btnPayBillClick:(UIButton *)sender {
    //切换到下一个界面  --- push
    PayBillViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"PayBillView"];
    //viewControl.dictData = _muArrayData[indexPath.section][indexPath.row];  // 传入数据
    [self.navigationController pushViewController:viewControl animated:YES];
}


#pragma mark -  CustomIOS7AlertViewDelegate 的代理方法实现
/**
 *  customIOS7dialogButtonTouchUpInside 方法
 */
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 获取那个按钮点击
    if(buttonIndex == 0) {
        [self.alertShow close] ;
        return;
    } // 点击取消返回
    
    // 确认按钮点击处理
    
}


#pragma mark - pulltableview 的相关方法
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    if(!self.pullTableView.pullTableIsRefreshing) {
        self.pullTableView.pullTableIsRefreshing = YES;
        [self performSelector:@selector(refreshTable) withObject:nil afterDelay:1.0f];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark 刷新数据方法
- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
    
    //_pages = 1;
    //[self GetWebResponseDataWithpage:_pages];
}

#pragma mark 加载更多数据方法
- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    self.pullTableView.pullTableIsLoadingMore = NO;
    
    NSInteger LastPage;   // 计算最后一页
    if(_memberTotalCount % 50 == 0) LastPage = _memberTotalCount / 50;
    else LastPage = _memberTotalCount / 50 + 1;
    
    // 到最后一页提示
//    if(_pages >= LastPage){
//        [MBProgressHUD show:@"没有了" icon:nil view:nil];
//    } else {
//        _pages++;
//        [self GetWebResponseDataWithpage:_pages];
//    }
}

#pragma mark - pulltableview 的代理方法实现
#pragma mark  设置有几个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _pages;
}

#pragma mark 设置每个section中有几个cell
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 数据为空时
    if([_muArrayData count] == 0) return 0;
    NSArray *arraytemp = _muArrayData[section];
    
    return arraytemp.count;
}

#pragma mark 设置每个cell的内容
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    NSDictionary *dictTempData = dictTempData = _muArrayData[indexPath.section][indexPath.row];
    
    // 设置背景色
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = ColorTableCell;
    }
    
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

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:1.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:1.0f];
}


// 获取网络数据
- (void)GetWebResponseDataWithpage:(int)PageCount {
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerListAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&shopid=%@&pageNum=%@", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"shopid"], [NSString stringWithFormat:@"%i", PageCount]];
    
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
                NSDictionary *dictDataTemp = [listData objectForKey:MESSAGE];
                // 获取总个数
                NSString *strTotal = [dictDataTemp objectForKey:@"total"];
                _memberTotalCount = [strTotal integerValue];
                // 获取会员列表
                _arrayGetWebData = [dictDataTemp objectForKey:@"list"];
                // 简化显示内容
                NSMutableArray *arrayTemp = [NSMutableArray array];
                for (NSDictionary *dictTemp  in _arrayGetWebData) {
                    NSDictionary *dictTemp2 =  @{@"cuname" : [dictTemp objectForKey:@"cuname"],
                                                 @"cumb" : [dictTemp objectForKey:@"cumb"],
                                                 @"cucardid" : [dictTemp objectForKey:@"cucardid"]
                                                 };
                    [arrayTemp addObject:dictTemp2];
                }
                _muArrayData[PageCount - 1] = arrayTemp;
                
                [self.pullTableView reloadData];  // 刷新整个表
                // 刷新一个section的数据
                //                NSIndexSet *indexset = [[NSIndexSet alloc] initWithIndex:PageCount - 1];
                //                [self.pullTableView reloadSections:indexset withRowAnimation:UITableViewRowAnimationAutomatic];
                // 刷新一个cell的数据
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}

#pragma mark 扫一扫响应的方法
- (void)btnQRCodeClick:(UIButton *)sender {
    //切换到下一个界面  --- push
    QRCodeViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeview"];
    viewControl.delegate = self;
    [self.navigationController pushViewController:viewControl animated:YES];
    
    // 关闭alertview
    [self.alertShow close];
    
}

#pragma mark 在alertview中的查询响应的方法
- (void)btnSearchAlertInClick:(UIButton *)sender {
    [self searchBarSearchButtonClicked:nil];
}

#pragma mark 点击view背景退出键盘
-(void)HandleBackgroundTap:(UITapGestureRecognizer *)sender {
    [self.alertShow endEditing:YES];
}

#pragma mark - UISearchBarDelegate 的代理方法的实现
#pragma mark - 当点击键盘上的搜索按钮时调用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 判断输入不能为空
    if ([self.seaBarInput.text isEqual:@""]) {
        [MBProgressHUD show:@"请输入查询内容" icon:nil view:nil];
        return;
    }
    [MBProgressHUD showMessage:@""];
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerGetAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&keyword=%@", [dictLogin objectForKey:@"groupid"], self.seaBarInput.text];
    
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
                NSDictionary *dictTempData = [listData objectForKey: MESSAGE];
                // copy 查询到的会员信息
                self.dictSearchMebInfo = dictTempData;
                dictTempData = [dictTempData objectForKey:@"cus"];
                
                // 表示该该卡已被退卡
                if([[dictTempData objectForKey:@"cucardid"] isEqual:@"无"]) {
                    [MBProgressHUD show:@"该手机号未绑定会员卡" icon:nil view:nil];
                    // 清空显示信息
                    self.lbMeterCardID.text = @"";
                    self.lbRemainCount.text = @"";
                    self.lbCredits.text = @"";
                    self.lbName.text = @"";
                    self.lbPhoneNum.text = @"";
                    self.lbBirthday.text = @"";
                    self.lbRegisteAddr.text = @"";
                    return;
                }
                // 设置显示信息
                NSArray *arrayTemp = [[listData objectForKey: MESSAGE] objectForKey:@"listcount"];
                self.lbMeterCardID.text = [NSString stringWithFormat:@"%@ | %@", [arrayTemp[0] objectForKey:@"cardnum"], [arrayTemp[0] objectForKey:@"cdname"]];
                self.lbRemainCount.text = [arrayTemp[0] objectForKey:@"cardcount"];
                self.lbCredits.text = [dictTempData objectForKey:@"cuinter"];
                self.lbName.text = [dictTempData objectForKey:@"cuname"];
                self.lbPhoneNum.text = [dictTempData objectForKey:@"cumb"];
                self.lbBirthday.text = [dictTempData objectForKey:@"cubdate_str"];
                self.lbRegisteAddr.text = [dictTempData objectForKey:@"shopname"];
                
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
    
    
}


#pragma mark QRCodeviewdelegate
- (void)QRCodeViewBackString:(NSString *)QRCodeSanString {
    // 显示alertShowView
    [self.alertShow show];
    self.seaBarInput.text = QRCodeSanString;
    [self btnSearchAlertInClick:nil];
    
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
    return [NSString stringWithFormat:@"%@ | %@", [_MuarrayType[row] objectForKey:@"cardnum"], [_MuarrayType[row] objectForKey:@"cdname"]];
}

#pragma mark 当选中picker中的row时调用该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_MuarrayType.count > 0) {
        NSDictionary *dicTemp = _MuarrayType[row];
        // 重新设置属性
        self.lbMeterCardID.text = [NSString stringWithFormat:@"%@ | %@", [_MuarrayType[row] objectForKey:@"cardnum"], [_MuarrayType[row] objectForKey:@"cdname"]];
        self.lbRemainCount.text = [dicTemp objectForKey:@"cardcount"];
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
    // 判断点击储值卡时，为空
    if (textField.tag == TF_METERCARDID_SELECTS_TAG) {
        if ([self.lbMeterCardID.text isEqual:@""]) {
            [MBProgressHUD show:@"请查询会员信息" icon:nil view:nil];
            return NO;
        }
            
        if ([self.seaBarInput.text isEqual:@""]) {
            [MBProgressHUD show:@"请查询会员信息" icon:nil view:nil];
            return NO;
        }
        
        self.pickerViewData.tag = TF_METERCARDID_SELECTS_TAG; // 设置tag标识
        // 获取数据
        //[_MuarrayType removeAllObjects];
        _MuarrayType = [self.dictSearchMebInfo objectForKey:@"listcount"];
        [self.pickerViewData reloadComponent:0]; // 重新加载数据
    }
    
    return YES;
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
