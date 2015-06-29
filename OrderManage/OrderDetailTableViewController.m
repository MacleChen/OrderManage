//
//  OrderDetailTableViewController.m
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "OrderDetailTableViewController.h"
#import "viewOtherDeal.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"



@interface OrderDetailTableViewController () {
    NSArray *_arrayHeaderTitle; // 菜单头部标题
    NSArray *_arrayShowData;   // 显示所有消费明细
    
    float _mainScreenWidth;
    float _mainScreenHeight;
}

@end

@implementation OrderDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    // 初始化
    _arrayHeaderTitle = @[@"会员信息", @"订单信息", @"消费明细"];
    self.viewcuInfo = [[UIView alloc] init];
    self.viewMenuDetail = [[UIView alloc] init];
    
    // 获取section的view
    [self GetCellViewFromXib];
    
    // 获取网络数据，并填充数据
    [self GetWebResponseData];
}

#pragma mark - pulltableview 的代理方法实现
#pragma mark  设置有几个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrayHeaderTitle.count;
}

#pragma mark 设置每个section中有几个cell
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == 1) return 1;
    return _arrayShowData.count + 1;
}

#pragma mark 设置每个cell的内容
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    // 设置cell右边的样式
    if (indexPath.section == 0) {   // 会员信息
        [cell addSubview:self.viewcuInfo];
    } else if (indexPath.section == 1) {   // 订单信息
        [cell addSubview:self.viewMenuDetail];
    } else {    // 消费明细
        if(indexPath.row == 0)
            [cell addSubview:[self GetViewCustomPropertys]];
        else {
            UIView *viewIncell = [[UIView alloc] init];
            viewIncell = [self GetViewCustomProValuesWithSeqNum:indexPath.row];
            [cell addSubview: viewIncell];
        }
    }
    
    return cell;
}

#pragma mark 设置section头的标题
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _arrayHeaderTitle[section];
}

#pragma mark 设置section的脚的标题
- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
    
}

#pragma mark 当开始拖拽时调用的方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

#pragma mark 设置每个row的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)  return 94;//return self.viewcuInfo.frame.size.height;
    if(indexPath.section == 1) return 240;//return self.viewMenuDetail.frame.size.height;
    
    return CELL_HEIGHT;
}

#pragma mark 设置Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}


/**
 *  根据xib文件获取view  并获取内部控件
 */
- (void)GetCellViewFromXib {
    // 从xib中获取views
    NSArray *cellsView = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailShowCellView" owner:nil options:nil];
    
    // 寻找view -- 获取对应的view
    for (UIView *viewTemp in cellsView) {
        if(viewTemp.tag == SECTION_ONE_VIEW) self.viewcuInfo = viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW) self.viewMenuDetail = viewTemp;
    }
    
    // 获取ViewCell 中的内容控件
    for (UILabel *viewTemp in [self.viewcuInfo subviews]) {
        if(viewTemp.tag == SECTION_ONE_VIEW_LBcuName) self.lbcuName = viewTemp;
        if(viewTemp.tag == SECTION_ONE_VIEW_LBcuPhone) self.lbcuPhone = viewTemp;
        if(viewTemp.tag == SECTION_ONE_VIEW_LBcuAddress) self.lbcuPhone = viewTemp;
    }
    
    for (UIView *viewTemp in [self.viewMenuDetail subviews]) {
        if(viewTemp.tag == SECTION_TWO_VIEW_LBTime) self.lbTime = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBMenuType) self.lbMenuType = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBStatus) self.lbStatus = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBNumber) self.lbNumber = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBOriginMoney) self.lbOriginMoney = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBPayMoney) self.lbPayMoney = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBAlreadyPay) self.lbAlreadyPay = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBDebtMoney) self.lbDebtMoney = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBPayType) self.lbPayType = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBBussSaler) self.lbBussSaler = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_LBUnionMenuId) self.lbUnionMenuId = (UILabel *)viewTemp;
        
        if(viewTemp.tag == SECTION_TWO_VIEW_BTNModify) self.btnModify = (UIButton *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_BTNPintNote) self.btnPintNote = (UIButton *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_BTNSecondPay) self.btnSecondPay = (UIButton *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_VIEW_BTNMenuCancel) self.btnMenuCancel = (UIButton *)viewTemp;
    }
    
    // 设置UIButton 的响应方法
    [self.btnModify addTarget:self action:@selector(btnModifyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPintNote addTarget:self action:@selector(btnPintNoteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSecondPay addTarget:self action:@selector(btnSecondPayClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMenuCancel addTarget:self action:@selector(btnMenuCancelClick:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  获取网络数据后进行初始化
 */
- (void)GetWebResponseData {
    //网络请求   --   获取查询数据
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBRecordDetailAction];
    NSString *strHttpBody = [NSString stringWithFormat:@"keyword=%@", [self.dictData objectForKey:@"rcid"]];
    
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
                [self InitResponseDataWithData:[listData objectForKey:MESSAGE]];
                
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];

    
}

/**
 *  初始化整个界面上的数据
 */
- (void)InitResponseDataWithData:(NSDictionary *)listData {
    NSDictionary *dictTemp = [listData objectForKey:@"cus"];            // 获取会员信息
    
    // 获取会员信息
    if((NSNull *)dictTemp != [NSNull null]) {
        self.lbcuName.text = [dictTemp objectForKey:@"cuname"];             // 会员姓名
        self.lbcuPhone.text = [dictTemp objectForKey:@"cumb"];              // 会员手机
        self.lbcuAddress.text = [dictTemp objectForKey:@"cuaddress"];       // 会员地址
    }
    
    //  订单信息
    dictTemp = [listData objectForKey:@"record"];                       // 获取订单信息
    if((NSNull *)dictTemp != [NSNull null]) {
        self.lbTime.text = [dictTemp objectForKey:@"rcdate"];               // 日期
        self.lbMenuType.text = [dictTemp objectForKey:@"typename"];         // 类型
        self.lbStatus.text = [dictTemp objectForKey:@"stname"];             // 状态
        //self.lbNumber.text = [dictTemp objectForKey:@"pnum"];             // 数量
        //self.lbOriginMoney.text = [dictTemp objectForKey:@""];            // 原价
        self.lbPayMoney.text = [dictTemp objectForKey:@"endtotal"];         // 应付
        self.lbAlreadyPay.text = [dictTemp objectForKey:@"rctotal"];        // 已付
        self.lbDebtMoney.text = [dictTemp objectForKey:@"lostmoney"];       // 欠款
        self.lbUnionMenuId.text = [self.dictData objectForKey:@"unionpayno"];   // 银联订单号
    }
    
    NSArray *arrayTemp = [listData objectForKey:@"list_money"];         // 消费列表
    if (arrayTemp.count > 0) {
        dictTemp = arrayTemp[0];
        self.lbPayType.text = [dictTemp objectForKey:@"typename"];      // 支付方式
    }
    arrayTemp = [listData objectForKey:@"list_re"];
    if (arrayTemp.count > 0) {
        dictTemp = arrayTemp[0];
        self.lbBussSaler.text = [dictTemp objectForKey:@"empname"];     // 业务员
    }
    
    //  消费明细
    arrayTemp = [listData objectForKey:@"list_dt"];     // 获取消费明细
    if(arrayTemp.count > 0) {
        NSMutableArray *MuarrayTemp = [NSMutableArray array];
        for (NSDictionary *dict in arrayTemp) {
            NSDictionary *DictTemp2  = @{@"prodname" : [dict objectForKey:@"prodname"],
                                         @"prodnum" : [dict objectForKey:@"prodnum"],
                                         @"produnit" : [dict objectForKey:@"produnit"],
                                         @"count" : [dict objectForKey:@"count"],
                                         @"price" : [dict objectForKey:@"price"],
                                         @"realprice" : [dict objectForKey:@"realprice"],
                                         @"point" : [dict objectForKey:@"point"]};
            [MuarrayTemp addObject:DictTemp2];
        }
        // MutableArray 转变成 Array
        _arrayShowData = [MuarrayTemp copy];
        // 刷新一个section的数据
        NSIndexSet *indexset = [[NSIndexSet alloc] initWithIndex:2];
        [self.tableView reloadSections:indexset withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/**
 *  设置消费明细的 属性字段view
 */
- (UIView *)GetViewCustomPropertys {
    UIView *viewPropertysCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainScreenWidth, CELL_HEIGHT)];
    
    int propertyCount = 8;
    int initY = 5, labelWith = 35, labelHeight = viewPropertysCell.frame.size.height, gap = (_mainScreenWidth - (propertyCount*labelWith))/(propertyCount+1);
    
    UILabel *lbProSeqNumber = [[UILabel alloc] initWithFrame:CGRectMake(gap*1 + labelWith*0, initY, labelWith, labelHeight)];
    lbProSeqNumber.text = @"序号";
    lbProSeqNumber.font = [UIFont boldSystemFontOfSize:13];
    lbProSeqNumber.textColor = ColorMainSystem;
    lbProSeqNumber.numberOfLines = 2;
    lbProSeqNumber.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProSeqNumber];
    
    UILabel *lbProCustomName = [[UILabel alloc] initWithFrame:CGRectMake(gap*2 + labelWith*1, initY, labelWith, labelHeight)];
    lbProCustomName.text = @"名称";
    lbProCustomName.font = [UIFont boldSystemFontOfSize:13];
    lbProCustomName.textColor = ColorMainSystem;
    lbProCustomName.numberOfLines = 2;
    lbProCustomName.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProCustomName];
    
    UILabel *lbProSerialID = [[UILabel alloc] initWithFrame:CGRectMake(gap*3 + labelWith*2, initY, labelWith, labelHeight)];
    lbProSerialID.text = @"编号";
    lbProSerialID.font = [UIFont boldSystemFontOfSize:13];
    lbProSerialID.textColor = ColorMainSystem;
    lbProSerialID.numberOfLines = 2;
    lbProSerialID.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProSerialID];
    
    UILabel *lbProUnit = [[UILabel alloc] initWithFrame:CGRectMake(gap*4 + labelWith*3, initY, labelWith, labelHeight)];
    lbProUnit.text = @"单位";
    lbProUnit.font = [UIFont boldSystemFontOfSize:13];
    lbProUnit.textColor = ColorMainSystem;
    lbProUnit.numberOfLines = 2;
    lbProUnit.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProUnit];
    
    UILabel *lbProCustomCount = [[UILabel alloc] initWithFrame:CGRectMake(gap*5 + labelWith*4, initY, labelWith, labelHeight)];
    lbProCustomCount.text = @"数量";
    lbProCustomCount.font = [UIFont boldSystemFontOfSize:13];
    lbProCustomCount.textColor = ColorMainSystem;
    lbProCustomCount.numberOfLines = 2;
    lbProCustomCount.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProCustomCount];
    
    UILabel *lbProProDiscount = [[UILabel alloc] initWithFrame:CGRectMake(gap*6 + labelWith*5, initY, labelWith, labelHeight)];
    lbProProDiscount.text = @"折前单价";
    lbProProDiscount.font = [UIFont boldSystemFontOfSize:13];
    lbProProDiscount.textColor = ColorMainSystem;
    lbProProDiscount.numberOfLines = 2;
    lbProProDiscount.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProProDiscount];
    
    UILabel *lbProNexDiscount = [[UILabel alloc] initWithFrame:CGRectMake(gap*7 + labelWith*6, initY, labelWith, labelHeight)];
    lbProNexDiscount.text = @"折后单价";
    lbProNexDiscount.font = [UIFont boldSystemFontOfSize:13];
    lbProNexDiscount.textColor = ColorMainSystem;
    lbProNexDiscount.numberOfLines = 2;
    lbProNexDiscount.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProNexDiscount];
    
    UILabel *lbProDeductCount = [[UILabel alloc] initWithFrame:CGRectMake(gap*8 + labelWith*7, initY, labelWith, labelHeight)];
    lbProDeductCount.text = @"扣次";
    lbProDeductCount.font = [UIFont boldSystemFontOfSize:13];
    lbProDeductCount.textColor = ColorMainSystem;
    lbProDeductCount.numberOfLines = 2;
    lbProDeductCount.textAlignment = NSTextAlignmentCenter;
    [viewPropertysCell addSubview:lbProDeductCount];
    
    return viewPropertysCell;
}

/**
 *  设置消费明细的 属性值view 并设置值
 */
- (UIView *)GetViewCustomProValuesWithSeqNum:(NSInteger)seqNum {
    UIView *viewValuesCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainScreenWidth, CELL_HEIGHT)];
    NSDictionary *showdata = _arrayShowData[seqNum - 1];
    
    // 设置label
    int propertyCount = 8;
    int initY = 5, labelWith = 35, labelHeight = viewValuesCell.frame.size.height, gap = (_mainScreenWidth - (propertyCount*labelWith))/(propertyCount+1);
    
    UILabel *lbSeqNumber = [[UILabel alloc] initWithFrame:CGRectMake(gap*1 + labelWith*0, initY, labelWith, labelHeight)];
    lbSeqNumber.font = [UIFont systemFontOfSize:12];
    lbSeqNumber.numberOfLines = 2;
    lbSeqNumber.textAlignment = NSTextAlignmentCenter;
    lbSeqNumber.text = [NSString stringWithFormat:@"%ld", (long)seqNum];      // 序号
    [viewValuesCell addSubview:lbSeqNumber];
    
    UILabel *lbCustomName = [[UILabel alloc] initWithFrame:CGRectMake(gap*2 + labelWith*1, initY, labelWith, labelHeight)];
    lbCustomName.text = [showdata objectForKey:@"prodname"];         // 名称
    lbCustomName.font = [UIFont systemFontOfSize:12];
    lbCustomName.numberOfLines = 2;
    lbCustomName.textAlignment = NSTextAlignmentCenter;
    [viewValuesCell addSubview:lbCustomName];
    
    UILabel *lbSerialID = [[UILabel alloc] initWithFrame:CGRectMake(gap*3 + labelWith*2, initY, labelWith, labelHeight)];
    lbSerialID.text = [showdata objectForKey:@"prodnum"];         // 编号
    lbSerialID.font = [UIFont systemFontOfSize:12];
    lbSerialID.numberOfLines = 2;
    lbSerialID.textAlignment = NSTextAlignmentCenter;
    [viewValuesCell addSubview:lbSerialID];
    
    UILabel *lbUnit = [[UILabel alloc] initWithFrame:CGRectMake(gap*4 + labelWith*3, initY, labelWith, labelHeight)];
    lbUnit.text = [showdata objectForKey:@"produnit"];         // 单位
    lbUnit.font = [UIFont systemFontOfSize:12];
    lbUnit.numberOfLines = 2;
    lbUnit.textAlignment = NSTextAlignmentCenter;
    [viewValuesCell addSubview:lbUnit];
    
    UILabel *lbCustomCount = [[UILabel alloc] initWithFrame:CGRectMake(gap*5 + labelWith*4, initY, labelWith, labelHeight)];
    lbCustomCount.text = [showdata objectForKey:@"count"];         // 数量
    lbCustomCount.font = [UIFont systemFontOfSize:12];
    lbCustomCount.numberOfLines = 2;
    lbCustomCount.textAlignment = NSTextAlignmentCenter;
    [viewValuesCell addSubview:lbCustomCount];
    
    UILabel *lbProDiscount = [[UILabel alloc] initWithFrame:CGRectMake(gap*6 + labelWith*5, initY, labelWith, labelHeight)];
    lbProDiscount.text = [showdata objectForKey:@"price"];         // 折前单价
    lbProDiscount.font = [UIFont systemFontOfSize:12];
    lbProDiscount.numberOfLines = 2;
    lbProDiscount.textAlignment = NSTextAlignmentCenter;
    [viewValuesCell addSubview:lbProDiscount];
    
    UILabel *lbNexDiscount = [[UILabel alloc] initWithFrame:CGRectMake(gap*7 + labelWith*6, initY, labelWith, labelHeight)];
    lbNexDiscount.text = [showdata objectForKey:@"realprice"];         // 折后单价
    lbNexDiscount.font = [UIFont systemFontOfSize:12];
    lbNexDiscount.numberOfLines = 2;
    lbNexDiscount.textAlignment = NSTextAlignmentCenter;
    [viewValuesCell addSubview:lbNexDiscount];
    
    UILabel *lbDeductCount = [[UILabel alloc] initWithFrame:CGRectMake(gap*8 + labelWith*7, initY, labelWith, labelHeight)];
    lbDeductCount.text = [showdata objectForKey:@"point"];         // 扣次
    lbDeductCount.font = [UIFont systemFontOfSize:12];
    lbDeductCount.numberOfLines = 2;
    lbDeductCount.textAlignment = NSTextAlignmentCenter;
    [viewValuesCell addSubview:lbDeductCount];

    
    return viewValuesCell;
}

#pragma  mark - 订单信息上按钮的响应方法
#pragma mark 修改
-(void)btnModifyClick:(UIButton *)sender {
    NSLog(@"修改");
}
#pragma mark 补打小票
-(void)btnPintNoteClick:(UIButton *)sender {
    NSLog(@"补打小票");
}
#pragma mark 补缴款
-(void)btnSecondPayClick:(UIButton *)sender {
    NSLog(@"补缴款");
}
#pragma mark 作废
-(void)btnMenuCancelClick:(UIButton *)sender {
    NSLog(@"作废");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
