//
//  MainViewController.m
//  OrderManage
//
//  Created by mac on 15/6/1.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate> {
    UIView *_positView;
    BOOL _menuFlg; // 判断菜单的显示与否
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _menuFlg = NO;
    _positView = [[UIView alloc] init];
    CGRect positFrame = [UIScreen mainScreen].applicationFrame;
    positFrame.size.width /= 2;
    positFrame.origin.y += self.navigationController.navigationBar.frame.size.height; // 获取navigationbar的高度
    
    positFrame.origin.x = -positFrame.size.width;
    [_positView setFrame:positFrame];
    _positView.backgroundColor = [UIColor colorWithRed:3/255.0 green:235/255.0 blue:127/255.0 alpha:1.0];
    [self.view addSubview:_positView];
    
    // tableView设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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

- (IBAction)BarBtnClick:(UIBarButtonItem *)sender {
    CGRect positFrame = _positView.frame;
    // 设置动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (_menuFlg) {
        positFrame.origin.x = -positFrame.size.width;
    } else {
        positFrame.origin.x = 0;
    }
    _menuFlg = !_menuFlg;
    _positView.frame = positFrame;
    
    [UIView commitAnimations];
}


#pragma mark - tableView 代理方法的实现
#pragma mark 设置tableview的组的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; //有一个组
}

#pragma mark 设置每个组中又多少个cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 20;
    }
    return 2;
}

#pragma mark 设置每个cell中又什么内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    // 设置具体cell信息
    cell.backgroundColor = [UIColor yellowColor];
    
    
    cell.imageView.image = [viewOtherDeal scaleToSize:[UIImage imageNamed:@"产品入库.png"] size:CGSizeMake(63, 63)]; //[;
    
    cell.textLabel.text = @"3号桌";
    cell.detailTextLabel.text = @"33个菜未上";
    cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 添加label
    UILabel *lbEatSate = [[UILabel alloc] initWithFrame:CGRectMake(200, 20, 100, 25)];
    lbEatSate.font = [UIFont boldSystemFontOfSize:13.0];
    lbEatSate.textColor = [UIColor greenColor];
    lbEatSate.text = @"就餐中...";
    
    [cell addSubview:lbEatSate];
    
    return cell;
}

#pragma mark 设置每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}


#pragma mark 这只点击cell中的图片调用响应的方法
- (void)cellImageClick:(UIButton *)sender {
    NSLog(@"sender = %ld", sender.tag);
}

#pragma mark 当tableview开始滚动是调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGRect positFrame = _positView.frame;
    // 设置动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (_menuFlg) {
        positFrame.origin.x = -positFrame.size.width;
        _menuFlg = !_menuFlg;
        _positView.frame = positFrame;
    }
    
    [UIView commitAnimations];
}


#pragma mark 当选择tableviewcell是调用
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"tip" message:[NSString stringWithFormat:@"touch the cell %ld", indexPath.row] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    
    [alertView show];
}

@end
