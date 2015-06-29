//
//  MemberListViewController.m
//  OrderManage
//
//  Created by mac on 15/6/9.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "MemberListViewController.h"
#import "viewOtherDeal.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"
#import "MebManageViewController.h"
#import "QRCodeViewController.h"

#define CELL_HEIGHT 50

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface MemberListViewController () <PullTableViewDelegate, UISearchBarDelegate, QRCodeViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSInteger _memberTotalCount;  // 会员的总数量
    int _pages;     // 页数
    
    NSMutableArray *_muArrayData; // 存储显示在界面上的数据
    NSArray *_arrayGetWebData;   // 获取网络数据
}

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    _muArrayData = [[NSMutableArray alloc]init];
    _arrayGetWebData = [NSArray array];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    // 设置代理
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    
    // 设置搜索栏
    self.Searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, MenuAddNotificationHeight, _mainScreenWidth, 50)];
    self.Searchbar.placeholder = @"会员名称/卡号/手机号";
    self.Searchbar.delegate = self;
    [self.view addSubview:self.Searchbar];
    
    // 设置pullTableview
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor groupTableViewBackgroundColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
    
    // 设置tableview 第一个cell距离导航栏的高度
    self.pullTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 65 + CELL_HEIGHT)];
    self.pullTableView.tableHeaderView.alpha = 0.0;
}


#pragma mark 扫一扫
- (IBAction)btnQRcode:(UIBarButtonItem *)sender {
    
    //切换到下一个界面  --- push
    QRCodeViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeview"];
    viewControl.delegate = self;
    [self.navigationController pushViewController:viewControl animated:YES];
}


// 获取网络数据
- (void)GetWebResponseDataWithpage:(int)PageCount {
    [MBProgressHUD showMessage:@""];
    // 网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCustomerListAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&shopid=%@&keyword=%@&pageNum=%@", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"shopid"], self.Searchbar.text, [NSString stringWithFormat:@"%i", PageCount]];
    
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
                if(![self.Searchbar.text isEqual:@""]) [_muArrayData removeAllObjects];
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
    
//    // 获取网络数据
    //[_muArrayData removeAllObjects];  // 清空数据
    _pages = 1;
    [self GetWebResponseDataWithpage:_pages];
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
        [self GetWebResponseDataWithpage:_pages];
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
    
    // 设置cell中的内容
    cell.textLabel.text = [dictTempData objectForKey:@"cuname"];  // 姓名
    cell.detailTextLabel.text = [dictTempData objectForKey:@"cumb"];         // 电话
    cell.imageView.image = [viewOtherDeal scaleToSize:[UIImage imageNamed:@"mebInitImg2.png"] size:CGSizeMake(35, 45)];   // 控制图片大小          // 图片
    
    // 设置背景色
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:204/255.0 green:255/255.0 blue:230/255.0 alpha:1.0];
    }
    // 设置label
    UILabel *lbShowcardID = [[UILabel alloc] initWithFrame:CGRectMake(200, 23, 150, 25)];
    lbShowcardID.text = [dictTempData objectForKey:@"cucardid"];         // 卡号
    lbShowcardID.font = [UIFont systemFontOfSize:12];
    [cell addSubview:lbShowcardID];
    
    // 设置cell右边的样式
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    // 跳转到会员管理
    //     返回到主界面 -- 回退根控制器界面
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    //切换到下一个界面  --- push
    MebManageViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewCell_0_2"];
    viewControl.ReceDict = _muArrayData[indexPath.section][indexPath.row];  // 传入数据
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
    [self GetWebResponseDataWithpage:1];
}

#pragma mark 当点击取消按钮时调用
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

}


#pragma mark QRCodeviewdelegate
- (void)QRCodeViewBackString:(NSString *)QRCodeSanString {
    self.Searchbar.text = QRCodeSanString;
    [self searchBarSearchButtonClicked:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
