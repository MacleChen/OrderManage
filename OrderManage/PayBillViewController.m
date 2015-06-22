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

#define CELL_HEIGHT 40

@interface PayBillViewController () <UITableViewDataSource, UITableViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSInteger _memberTotalCount;  // 会员的总数量
    int _pages;     // 页数
    
    NSMutableArray *_muArrayData; // 存储显示在界面上的数据
}

@end

@implementation PayBillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置代理
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
}


#pragma mark 清空按钮响应方法
- (IBAction)itemBtnClearClick:(UIBarButtonItem *)sender {
    
}

#pragma mark 结算确认响应方法
- (IBAction)btnSurePayBillClick:(UIButton *)sender {
    
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
