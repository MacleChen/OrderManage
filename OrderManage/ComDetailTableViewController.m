//
//  ComDetailTableViewController.m
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "ComDetailTableViewController.h"

#import "viewOtherDeal.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"
#import "MebManageViewController.h"
#import "OrderDetailTableViewController.h"

#define CELL_HEIGHT2 50

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface ComDetailTableViewController () <PullTableViewDelegate, UITextFieldDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSInteger _memberTotalCount;  // 会员的总数量
    int _pages;     // 页数
    
    NSMutableArray *_muArrayData; // 存储显示在界面上的数据
}

@end

@implementation ComDetailTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    _muArrayData = [[NSMutableArray alloc]init];
    self.itemSearch.image = [viewOtherDeal scaleToSize:[UIImage imageNamed:@"credits_search2.png"] size:ITEM_IMAGE_CGSZE];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    // 设置代理
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    self.viewSearch = [[UIView alloc] init];
    self.alertShow = [[CustomIOS7AlertView alloc] init];
    [self.alertShow setButtonTitles:[NSArray arrayWithObjects:@"取消", @"查询", nil]];
    self.alertShow.useMotionEffects = YES;
    self.alertShow.delegate = self;
    
    // 设置搜索栏
    UIView *viewProperty = [[UIView alloc] initWithFrame:CGRectMake(0, MenuAddNotificationHeight, _mainScreenWidth, 50)];

    int initX = 10 , initY = 10, labelWith = 50, labelHeight = 30;
    UILabel *lbProMenuid = [[UILabel alloc] initWithFrame:CGRectMake(initX + labelWith * 0, initY, labelWith, labelHeight)];
    lbProMenuid.text = @"单号";
    lbProMenuid.font = [UIFont boldSystemFontOfSize:13];
    lbProMenuid.textColor = ColorMainSystem;
    lbProMenuid.textAlignment = NSTextAlignmentCenter;
    UILabel *lbProMebName = [[UILabel alloc] initWithFrame:CGRectMake(initX + labelWith * 1, initY, labelWith, labelHeight)];
    lbProMebName.text = @"会员";
    lbProMebName.font = [UIFont boldSystemFontOfSize:13];
    lbProMebName.textColor = ColorMainSystem;
    lbProMebName.textAlignment = NSTextAlignmentCenter;
    UILabel *lbProType = [[UILabel alloc] initWithFrame:CGRectMake(initX + labelWith * 2, initY, labelWith, labelHeight)];
    lbProType.text = @"类型";
    lbProType.font = [UIFont boldSystemFontOfSize:13];
    lbProType.textColor = ColorMainSystem;
    lbProType.textAlignment = NSTextAlignmentCenter;
    UILabel *lbProCustom = [[UILabel alloc] initWithFrame:CGRectMake(initX + labelWith * 3, initY, labelWith, labelHeight)];
    lbProCustom.text = @"消费";
    lbProCustom.font = [UIFont boldSystemFontOfSize:13];
    lbProCustom.textColor = ColorMainSystem;
    lbProCustom.textAlignment = NSTextAlignmentCenter;
    UILabel *lbProMeter = [[UILabel alloc] initWithFrame:CGRectMake(initX + labelWith * 4, initY, labelWith, labelHeight)];
    lbProMeter.text = @"计次";
    lbProMeter.font = [UIFont boldSystemFontOfSize:13];
    lbProMeter.textColor = ColorMainSystem;
    lbProMeter.textAlignment = NSTextAlignmentCenter;
    UILabel *lbProStatus = [[UILabel alloc] initWithFrame:CGRectMake(initX + labelWith * 5, initY, labelWith, labelHeight)];
    lbProStatus.text = @"状态";
    lbProStatus.font = [UIFont boldSystemFontOfSize:13];
    lbProStatus.textColor = ColorMainSystem;
    lbProStatus.textAlignment = NSTextAlignmentCenter;
    
    [viewProperty addSubview:lbProMenuid];
    [viewProperty addSubview:lbProMebName];
    [viewProperty addSubview:lbProType];
    [viewProperty addSubview:lbProCustom];
    [viewProperty addSubview:lbProMeter];
    [viewProperty addSubview:lbProStatus];
    [self.view addSubview:viewProperty];
    
    // 设置pullTableview
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor groupTableViewBackgroundColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
    
    // 设置tableview 第一个cell距离导航栏的高度
    self.pullTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 65 + CELL_HEIGHT2)];
    self.pullTableView.tableHeaderView.alpha = 0.0;
    
    
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
    self.visualEffectView.frame = CGRectMake(0, 0, _mainScreenWidth, 220);
    self.visualEffectView.alpha = 1.0;
    //    self.visualEffectView.layer.borderColor = [[UIColor grayColor] CGColor];
    //    self.visualEffectView.layer.borderWidth = 0.5; // 设置border
    [self.visualEffectView addSubview:_datePicker];
}


// 获取网络数据
- (void)GetWebResponseDataWithpage:(int)PageCount BeginDate:(NSString *)BeDate EndDate:(NSString *)EnDate searchKeyword:(NSString *)strKeywd CheckBox:(NSString *)CkBox {
    [MBProgressHUD showMessage:@""];
     //网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBRecordListAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&emp.empid=%@&shopid=%@&keyword=%@&keyword1=%@&keyword2=%@&keyword3=%@&pageNum=%@", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"empid"], [dictLogin objectForKey:@"shopid"], BeDate, EnDate, CkBox, strKeywd, [NSString stringWithFormat:@"%i", PageCount]];
    
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
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
                if(_memberTotalCount == 0){
                    [MBProgressHUD show:@"没有查询到" icon:nil view:nil];
                    return;
                }
                // 获取list数据
                NSArray *arrayList = [dictDataTemp objectForKey:@"list"];
                // 简化显示内容
                NSMutableArray *arrayTemp = [NSMutableArray array];
                for (NSDictionary *dictTemp  in arrayList) {
                    NSDictionary *dictTemp2 =  @{@"rccode" : [dictTemp objectForKey:@"rccode"],
                                                 @"cuname" : [dictTemp objectForKey:@"cuname"],
                                                 @"typename" : [dictTemp objectForKey:@"typename"],
                                                 @"endtotal" : [dictTemp objectForKey:@"endtotal"],
                                                 @"cardcount" : [dictTemp objectForKey:@"cardcount"],
                                                 @"stname" : [dictTemp objectForKey:@"stname"],
                                                 @"unionpayno" : [dictTemp objectForKey:@"unionpayno"],
                                                 @"rcid" : [dictTemp objectForKey:@"rcid"]
                                                 };
                    [arrayTemp addObject:dictTemp2];
                }
                // 获取成功推出键盘 alertview
                [self customIOS7dialogButtonTouchUpInside:self.alertShow clickedButtonAtIndex:0];
                
                _muArrayData[PageCount - 1] = arrayTemp;
                [self.pullTableView reloadData];  // 刷新整个表
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
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
    
    _pages = 1;
    [self GetWebResponseDataWithpage:_pages BeginDate:@"" EndDate:@"" searchKeyword:@"" CheckBox:@""];
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
    if(_pages >= LastPage){
        [MBProgressHUD show:@"没有了" icon:nil view:nil];
    } else {
        _pages++;
        [self GetWebResponseDataWithpage:_pages BeginDate:@"" EndDate:@"" searchKeyword:@"" CheckBox:@""];
    }
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
    
    // 设置label
    int initX = 10, initY = 5, lbWidth = 47, lbHeight = CELL_HEIGHT2 - 2 * initY, gaplb = CELL_HEIGHT2 - lbWidth;
    UILabel *lbMenuID = [[UILabel alloc] initWithFrame:CGRectMake(initX + (lbWidth+gaplb) * 0, initY, lbWidth, lbHeight)];
    lbMenuID.text = [dictTempData objectForKey:@"rccode"];         // 单号
    lbMenuID.font = [UIFont systemFontOfSize:12];
    lbMenuID.numberOfLines = 2;
    lbMenuID.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:lbMenuID];
    
    UILabel *lbMebName = [[UILabel alloc] initWithFrame:CGRectMake(initX + (lbWidth+gaplb) * 1, initY, lbWidth, lbHeight)];
    lbMebName.text = [dictTempData objectForKey:@"cuname"];         // 会员名称
    lbMebName.font = [UIFont systemFontOfSize:12];
    lbMebName.numberOfLines = 2;
    lbMebName.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:lbMebName];
    
    UILabel *lbType = [[UILabel alloc] initWithFrame:CGRectMake(initX + (lbWidth+gaplb) * 2, initY, lbWidth, lbHeight)];
    lbType.text = [dictTempData objectForKey:@"typename"];         // 类型
    lbType.font = [UIFont systemFontOfSize:12];
    lbType.numberOfLines = 2;
    lbType.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:lbType];
    
    UILabel *lbCustom = [[UILabel alloc] initWithFrame:CGRectMake(initX + (lbWidth+gaplb) * 3, initY, lbWidth, lbHeight)];
    lbCustom.text = [dictTempData objectForKey:@"endtotal"];         // 消费
    lbCustom.font = [UIFont systemFontOfSize:12];
    lbCustom.numberOfLines = 2;
    lbCustom.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:lbCustom];
    
    UILabel *lbCalTimes = [[UILabel alloc] initWithFrame:CGRectMake(initX + (lbWidth+gaplb) * 4, initY, lbWidth, lbHeight)];
    lbCalTimes.text = [dictTempData objectForKey:@"cardcount"];         // 计次
    lbCalTimes.font = [UIFont systemFontOfSize:12];
    lbCalTimes.numberOfLines = 2;
    lbCalTimes.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:lbCalTimes];
    
    UILabel *lbStatus = [[UILabel alloc] initWithFrame:CGRectMake(initX + (lbWidth+gaplb) * 5, initY, lbWidth, lbHeight)];
    lbStatus.text = [dictTempData objectForKey:@"stname"];         // 状态
    lbStatus.font = [UIFont systemFontOfSize:12];
    lbStatus.numberOfLines = 2;
    lbStatus.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:lbStatus];
    
    
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
    return CELL_HEIGHT2;
}

#pragma mark  选中cell时响应方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //切换到下一个界面  --- push
    OrderDetailTableViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetail"];
    viewControl.dictData = _muArrayData[indexPath.section][indexPath.row];  // 传入数据
    [self.navigationController pushViewController:viewControl animated:YES];
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

#pragma mark - UISearchBarDelegate 的代理方法的实现
#pragma mark - 当点击键盘上的搜索按钮时调用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self GetWebResponseDataWithpage:1 BeginDate:nil EndDate:nil searchKeyword:nil CheckBox:nil];
}

#pragma mark 当点击取消按钮时调用
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

/**
 *  详细搜索
 */
- (IBAction)BarBtnDetailSearch:(UIBarButtonItem *)sender {
    // 设置界面
    self.viewSearch = [self ViewShowSearch];
    
    // 将view显示在alertview中
    [self.alertShow setContainerView:self.viewSearch];
    [self.alertShow show];
}

/**
 * 设置详细搜索页面
 */
- (UIView *)ViewShowSearch {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainScreenWidth - 20, 200)];
    
    // 设置开始时间
    int initX = 10, initY = 10, lbWidth = 60, lbHeight = 30, gaplb = 10, tfWidth = 200, tfHeight = 30;
    UILabel *lbBeginDate = [[UILabel alloc] initWithFrame:CGRectMake(initX, initY, lbWidth, lbHeight)];
    lbBeginDate.text = @"开始时间";
    lbBeginDate.font = [UIFont systemFontOfSize:13];
    [view addSubview:lbBeginDate];
    UITextField *tfBeginDate = [[UITextField alloc] initWithFrame:CGRectMake(initX + lbWidth, initY, tfWidth, tfHeight)];
    tfBeginDate.borderStyle = UITextBorderStyleRoundedRect;
    self.TF_BeginDate = tfBeginDate;
    self.TF_BeginDate.tag = TFBEGIN_TAG;
    self.TF_BeginDate.font = [UIFont systemFontOfSize:13];
    self.TF_BeginDate.delegate = self;
    [self.TF_BeginDate setInputView:self.visualEffectView];
    [view addSubview:tfBeginDate];
    
    // 设置结束时间
    UILabel *lbEndDate = [[UILabel alloc] initWithFrame:CGRectMake(initX, initY + gaplb*1 + lbHeight, lbWidth, lbHeight)];
    lbEndDate.text = @"结束时间";
    lbEndDate.font = [UIFont systemFontOfSize:13];
    [view addSubview:lbEndDate];
    UITextField *tfEndDate = [[UITextField alloc] initWithFrame:CGRectMake(initX  + lbWidth, initY + gaplb*1 + lbHeight, tfWidth, tfHeight)];
    tfEndDate.borderStyle = UITextBorderStyleRoundedRect;
    self.TF_EndDate = tfEndDate;
    self.TF_EndDate.font = [UIFont systemFontOfSize:13];
    self.TF_EndDate.tag = TFEND_TAG;
    self.TF_EndDate.delegate = self;
    [self.TF_EndDate setInputView:self.visualEffectView];
    [view addSubview:tfEndDate];
    
    // 设置搜索关键词
    UITextField *tfSearchKeywd = [[UITextField alloc] initWithFrame:CGRectMake(initX, initY + gaplb*3 + lbHeight*2, view.frame.size.width - 2*initY, tfHeight)];
    tfSearchKeywd.borderStyle = UITextBorderStyleRoundedRect;
    tfSearchKeywd.placeholder = @"单据编号/商品名称/会员电话";
    tfSearchKeywd.font = [UIFont systemFontOfSize:13];
    [tfSearchKeywd setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    self.TF_SearchKeywd = tfSearchKeywd;
    self.TF_SearchKeywd.delegate = self;
    [view addSubview:tfSearchKeywd];
    
    // 设置 checkbox 选择框
    QCheckBox *_checkDoCard = [[QCheckBox alloc] initWithDelegate:self];    // 办卡
    _checkDoCard.frame = CGRectMake(initX, initY + gaplb*2*2 + lbHeight*3, lbWidth, lbHeight);
    [_checkDoCard setTitle:@"办卡" forState:UIControlStateNormal];
    [_checkDoCard setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkDoCard.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.CK_DoCard = _checkDoCard;
    [view addSubview:_checkDoCard];
    
    QCheckBox *_checkRechange = [[QCheckBox alloc] initWithDelegate:self];     // 充值
    _checkRechange.frame = CGRectMake(initX + (lbWidth+gaplb)*1 , initY + gaplb*2*2 + lbHeight*3, lbWidth, lbHeight);
    [_checkRechange setTitle:@"充值" forState:UIControlStateNormal];
    [_checkRechange setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkRechange.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.CK_Rechange = _checkRechange;
    [view addSubview:_checkRechange];
    
    QCheckBox *_checkPetcd = [[QCheckBox alloc] initWithDelegate:self];     // 储值卡会员消费
    _checkPetcd.frame = CGRectMake(initX + (lbWidth+gaplb)*2, initY + gaplb*2*2 + lbHeight*3, lbWidth*2, lbHeight);
    [_checkPetcd setTitle:@"储值卡会员消费" forState:UIControlStateNormal];
    [_checkPetcd setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkPetcd.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.CK_Petcd = _checkPetcd;
    [view addSubview:_checkPetcd];
    
    QCheckBox *_checkTimeCd = [[QCheckBox alloc] initWithDelegate:self];     // 计次卡会员消费
    _checkTimeCd.frame = CGRectMake(initX, initY + gaplb*4 + lbHeight*4, lbWidth*2, lbHeight);
    [_checkTimeCd setTitle:@"计次卡会员消费" forState:UIControlStateNormal];
    [_checkTimeCd setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkTimeCd.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.CK_TimeCd = _checkTimeCd;
    [view addSubview:_checkTimeCd];
    
    QCheckBox *_checkQuickCom = [[QCheckBox alloc] initWithDelegate:self];     // 快速消费
    _checkQuickCom.frame = CGRectMake(initX + lbWidth*2 + gaplb*1, initY + gaplb*4 + lbHeight*4, lbWidth+40, lbHeight);
    [_checkQuickCom setTitle:@"快速消费" forState:UIControlStateNormal];
    [_checkQuickCom setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_checkQuickCom.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    self.CK_QuickCom = _checkQuickCom;
    [view addSubview:_checkQuickCom];    
    
    return view;
}


#pragma mark - QCheckBoxDelegate
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {

}

#pragma mark 点击弹出窗口上的按钮调用的方法
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 获取那个按钮点击
    if(buttonIndex == 0) {   // 点击取消返回
        [self.alertShow close];
        [self textFieldShouldBeginEditing:nil]; // 退出picker
        return;
    }
    
    if([self.TF_BeginDate.text isEqual:@""] && [self.TF_EndDate.text isEqual:@""] && [self.TF_SearchKeywd.text isEqual:@""] && !self.CK_DoCard.checked && !self.CK_Rechange.checked && !self.CK_Petcd.checked && !self.CK_TimeCd.checked && !self.CK_QuickCom.checked) {
        
        [MBProgressHUD show:@"请输入查询条件" icon:nil view:nil];
        return;
    }
    
    [self GetWebResponseDataWithpage:1 BeginDate:self.TF_BeginDate.text EndDate:self.TF_EndDate.text searchKeyword:self.TF_SearchKeywd.text CheckBox:[self GetStringCheckBoxs]];
    
}

#pragma mark 获取checkboxs 的string值
- (NSString *)GetStringCheckBoxs {
    NSMutableString *strCheckboxs = [[NSMutableString alloc] init];
    
    if(self.CK_DoCard.checked) [strCheckboxs appendString:@"11,"];
    if(self.CK_Rechange.checked) [strCheckboxs appendString:@"12,"];
    if(self.CK_Petcd.checked) [strCheckboxs appendString:@"13,"];
    if(self.CK_TimeCd.checked) [strCheckboxs appendString:@"15,"];
    if(self.CK_QuickCom.checked) [strCheckboxs appendString:@"14,"];
    
    if(![strCheckboxs isEqual:@""])
        return [strCheckboxs substringToIndex:strCheckboxs.length - 1];
    
    return @"";
}



#pragma mark 滚动datePicker调用的方法
- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;     // 获取datePicker的时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyyMMdd";  // 设置时间格式
    
    if([self.TF_BeginDate isFirstResponder])
        self.TF_BeginDate.text = [dateFormat stringFromDate:selectedDate]; // 将时间转化为NSString
    if([self.TF_EndDate isFirstResponder])
        self.TF_EndDate.text = [dateFormat stringFromDate:selectedDate];
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
//    CGRect datepicFrame = self.visualEffectView.frame;
//    
//    // 添加动画
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
//    if (textField.tag == TFBEGIN_TAG || textField.tag == TFEND_TAG) {  // 调出datePicker
//        [self.view endEditing:YES];
//        // 显示placeholder
//        if(textField.tag == TFBEGIN_TAG) self.TF_BeginDate.text = @"";
//        if(textField.tag == TFEND_TAG)  self.TF_EndDate.text = @"";
//        
//        datepicFrame.origin.y = _mainScreenHeight - datepicFrame.size.height;
//        
//    } else {
//        datepicFrame.origin.y = _mainScreenHeight;
//    }
//    
//    self.visualEffectView.frame = datepicFrame;
//    [UIView commitAnimations];
    
    return YES;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
