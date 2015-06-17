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

#define CELL_HEIGHT 50

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface ComDetailTableViewController () <PullTableViewDelegate> {
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
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    // 设置代理
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    
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
    self.pullTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 65 + CELL_HEIGHT)];
    self.pullTableView.tableHeaderView.alpha = 0.0;
}


// 获取网络数据
- (void)GetWebResponseDataWithpage:(int)PageCount BeginDate:(NSString *)BeDate EndDate:(NSString *)EnDate searchKeyword:(NSString *)strKeywd CheckBox:(NSString *)CkBox {
     //网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBRecordListAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&emp.empid=%@&shopid=%@&keyword=%@&keyword1=%@&keyword2=%@&keyword3=%@&pageNum=%@", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"empid"], [dictLogin objectForKey:@"shopid"], BeDate, EnDate, strKeywd, CkBox, [NSString stringWithFormat:@"%i", PageCount]];
    
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
                                                 @"stname" : [dictTemp objectForKey:@"stname"]
                                                 };
                    [arrayTemp addObject:dictTemp2];
                }
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
        cell.backgroundColor = [UIColor colorWithRed:204/255.0 green:255/255.0 blue:230/255.0 alpha:1.0];
    }
    
    // 设置label
    int initX = 10, initY = 5, lbWidth = 47, lbHeight = CELL_HEIGHT - 2 * initY, gaplb = CELL_HEIGHT - lbWidth;
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
    return CELL_HEIGHT;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
