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
#import "GetMoneyViewController.h"
#import "GetAllDataModels.h"

extern NSDictionary *dictLogin;   // 引用全局登录数据
extern NSDictionary *dictSendLogin;

@interface OrderDetailTableViewController ()<UIAlertViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray *_arrayHeaderTitle; // 菜单头部标题
    NSArray *_arrayShowData;   // 显示所有消费明细
    
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSMutableArray *_MuarrayType; // 要显示到pcikerview中卡类型字符串
    NSArray *_arrayTypeData;   // 接收到的所有类型数据
    
    NSString *_strMid;
    
    // 订单信息
    NSDictionary *_dictOrder;
    // 会员信息
    NSDictionary *_dictMember;
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
    _MuarrayType = [[NSMutableArray alloc] init];
    _arrayTypeData = [[NSArray alloc] init];
    _dictOrder = [NSDictionary dictionary];
    self.dictSaveOrderInfo = [[NSDictionary alloc] init];
    _strMid = [NSString string];
    
    // 设置毛玻璃的背景
    self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.visualEffectView.frame = CGRectMake(0, 0, _mainScreenWidth, 220);
    self.visualEffectView.alpha = 1.0;
    
    // 设置pickerView
    UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, _mainScreenWidth, 220)];
    self.pickerViewData = picker;
    self.pickerViewData.delegate = self;
    self.pickerViewData.dataSource = self;
    [self.visualEffectView addSubview:self.pickerViewData];
    
    // 获取section的view
    [self GetCellViewFromXib];
    
    // 获取网络数据，并填充数据
    [self GetWebResponseData];
    
    // 设置alertview
    self.alertShow = [[CustomIOS7AlertView alloc] init];
    [self.alertShow setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
    self.alertShow.useMotionEffects = YES;
    // 设置代理
    self.alertShow.delegate = self;
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
        if(viewTemp.tag == SECTION_TWO_ModifyView_Tag) self.ModifyView = viewTemp;
        if(viewTemp.tag == SECTION_TWO_CheckNamePwdView_tag) self.CheckNamePwdView = viewTemp;
    }
    
    // 获取ViewCell 中的内容控件
    for (UILabel *viewTemp in [self.viewcuInfo subviews]) {
        if(viewTemp.tag == SECTION_ONE_VIEW_LBcuName) self.lbcuName = viewTemp;
        if(viewTemp.tag == SECTION_ONE_VIEW_LBcuPhone) self.lbcuPhone = viewTemp;
        if(viewTemp.tag == SECTION_ONE_VIEW_LBcuAddress) self.lbcuAddress = viewTemp;
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
    
    // 第二个section中修改弹出的view
    for (UIView *viewTemp in [self.ModifyView subviews]) {
        if(viewTemp.tag == SECTION_TWO_ModifyView_BussineMan1_Tag) self.tfMdViewBussMan1 = (UITextField *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_ModifyView_BussMan1_Money_Tag) self.tfMdViewBussMan1Money = (UITextField *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_ModifyView_BussineMan2_Tag) self.tfMdViewBussMan2 = (UITextField *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_ModifyView_bussMan2_Money_Tag) self.tfMdViewBussMan2Money = (UITextField *)viewTemp;
    }
    
    // 第二个section中验证用户名，密码弹出的view
    for (UIView *viewTemp in [self.CheckNamePwdView subviews]) {
        if(viewTemp.tag == SECTION_TWO_CheckNamePwdView_Title_Tag) self.lbCKViewTitle = (UILabel *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_CheckNamePwdView_TFName_Tag) self.tfCKViewName = (UITextField *)viewTemp;
        if(viewTemp.tag == SECTION_TWO_CheckNamePwdView_TFPwd_Tag) self.tfCKViewPassword = (UITextField *)viewTemp;
    }
    
    // 设置UIButton 的响应方法
    [self.btnModify addTarget:self action:@selector(btnModifyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPintNote addTarget:self action:@selector(btnPintNoteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSecondPay addTarget:self action:@selector(btnSecondPayClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMenuCancel addTarget:self action:@selector(btnMenuCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置代理
    self.tfMdViewBussMan1.delegate = self;
    self.tfMdViewBussMan2.delegate = self;
    
    // 设置键盘类型
    self.tfMdViewBussMan1.inputView = self.visualEffectView;
    self.tfMdViewBussMan2.inputView = self.visualEffectView;
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
                self.dictSaveOrderInfo = [listData objectForKey:MESSAGE];
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
    _dictMember = dictTemp;
    
    // 获取会员信息
    if((NSNull *)dictTemp != [NSNull null]) {
        self.lbcuName.text = [dictTemp objectForKey:@"cuname"];             // 会员姓名
        self.lbcuPhone.text = [dictTemp objectForKey:@"cumb"];              // 会员手机
        self.lbcuAddress.text = [dictTemp objectForKey:@"cuaddress"];       // 会员地址
    }
    
    //  订单信息
    dictTemp = [listData objectForKey:@"record"];                       // 获取订单信息
    _dictOrder = dictTemp;
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
        NSMutableString *muStrSalerTemp = [NSMutableString string];
        for (dictTemp in arrayTemp) {
            [muStrSalerTemp appendFormat:@"%@(￥%@) |", [dictTemp objectForKey:@"empname"], [dictTemp objectForKey:@"money"]];
        }
        self.lbBussSaler.text = [muStrSalerTemp substringToIndex:muStrSalerTemp.length - 1]; // 去掉最后一个字符, 给业务员
        _strMid = [dictTemp objectForKey:@"mid"];
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
    self.alertShow.tag = SECTION_TWO_ModifyView_Tag;
    
    self.ModifyView.frame = CGRectMake(0, 0, 300, 133);
    [self.alertShow setContainerView:self.ModifyView];
    
    [self.alertShow show];
}

/**
 *  获取业务员列表
 */
- (void)GetBussMansList {
    // 获取业务员的列表
    // 获取网络数据
    // 网络请求
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

#pragma mark 补打小票
-(void)btnPintNoteClick:(UIButton *)sender {
    self.lbCKViewTitle.text = @"补打小票";
    self.alertShow.tag = SECTION_TWO_CheckNamePwdView_tag;
    self.CheckNamePwdView.frame = CGRectMake(0, 0, 300, 123);
    [self.alertShow setContainerView:self.CheckNamePwdView];
    
    [self.alertShow show];
}
#pragma mark 补缴款
-(void)btnSecondPayClick:(UIButton *)sender {
    // 判断订单是否有欠款
    if ([self.lbDebtMoney.text intValue] <= 0) {
        [MBProgressHUD show:@"该订单为没有欠款" icon:nil view:nil];
        return;
    }
    
    // 切换到付款页面
    //切换到下一个界面  --- push
    GetMoneyViewController *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"GetMoney"];
    
    // 打包传递的数据
    GetMoneyReceDataModel *getmoney = [[GetMoneyReceDataModel alloc] initWithDictionaryPackBag:self.dictSaveOrderInfo];
    // 获取卡类型
    NSDictionary *dictCardTypeTemp = [self GETCardTypeWithCardTypeID:getmoney.strCardTypeID];
    
    // 拼接卡的类型/折扣
    NSString *strcdType = [NSString stringWithFormat:@"%@/%@", [dictCardTypeTemp objectForKey:@"cdname"], [dictCardTypeTemp objectForKey:@"cdpec"]];
    
    getmoney.strCardid = [dictCardTypeTemp objectForKey:@"cdid"];
    getmoney.strSelcardMoney = [dictCardTypeTemp objectForKey:@"cdmoney"];
    getmoney.strSelcardType = strcdType;
    NSDictionary *dictRegisteData = [getmoney getDictionaryPackBag];
    MyPrint(@"%@", dictRegisteData);
    
    viewControl.listDict = dictRegisteData;
    
    [self.navigationController pushViewController:viewControl animated:YES];

}
#pragma mark 作废
-(void)btnMenuCancelClick:(UIButton *)sender {
    self.lbCKViewTitle.text = @"单据作废";
    self.alertShow.tag = SECTION_TWO_CancelCheckNamePwdView;
    
    self.CheckNamePwdView.frame = CGRectMake(0, 0, 300, 123);
    [self.alertShow setContainerView:self.CheckNamePwdView];
    [self.alertShow show];
}

#pragma mark 判断登录的用户名，密码是否匹配
- (BOOL)ChectUserNameAndPwd:(NSString *)userName password:(NSString *)userPwd {
    if ([userName isEqual:[dictSendLogin objectForKey:@"userName"]] && [userPwd isEqual:[dictSendLogin objectForKey:@"userPwd"]]) {
        return YES;
    }
    
    return NO;
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
    
    if(self.alertShow.tag == SECTION_TWO_ModifyView_Tag) { // 修改确认
        MyPrint(@"修改");
        [MBProgressHUD showMessage:@""];
        // 网络请求
        NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBUpRecord];
        
        NSString *strHttpBody = [NSString stringWithFormat:@"keyword=%@&rcid=%@&empids1=%@&empids2=%@&empmoneys1=%@&empmoneys2=%@", _strMid, [_dictOrder objectForKey:@"rcid"], self.tfMdViewBussMan1.accessibilityValue, self.tfMdViewBussMan2.accessibilityValue, self.tfMdViewBussMan1Money.text, self.tfMdViewBussMan2Money.text];
        
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
                    // 刷新数据
                    [self GetWebResponseData];
                } else { // 数据有问题
                    [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
                }
            } else { // 请求失败
                [MBProgressHUD show:ConnectException icon:nil view:nil];
            }
            
        }];
        
        // 退出pickerview
        [self.alertShow close];
        return;
    }
    
    // 判断是否为空
    if ([self.tfCKViewName.text isEqual:@""] || [self.tfCKViewPassword.text isEqual:@""]) {
        [MBProgressHUD show:@"输入不能为空" icon:nil view:nil];
        return;
    }
    
    if (![self ChectUserNameAndPwd:self.tfCKViewName.text password:self.tfCKViewPassword.text]) {
        [MBProgressHUD show:@"名称或密码不正确" icon:nil view:nil];
        return;
    }
    if(self.alertShow.tag == SECTION_TWO_CheckNamePwdView_tag) { // 补打小票确认
        MyPrint(@"补打小票");
        
        
        
        // 退出pickerview
        [self.alertShow close];
        return;
    }
    if(self.alertShow.tag == SECTION_TWO_CancelCheckNamePwdView) { // 作废确认
        MyPrint(@"作废");
        
        // 退出pickerview
        [self.alertShow close];
        return;
    }
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
    self.pickerViewData.tag = textField.tag;
    
    if (textField.tag == SECTION_TWO_ModifyView_BussineMan1_Tag || textField.tag == SECTION_TWO_ModifyView_BussineMan2_Tag) {
        [self GetBussMansList];
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
    
    return [_MuarrayType[row] objectForKey:@"empnickname"];
}

#pragma mark 当选中picker中的row时调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_MuarrayType.count > 0) {
        if (pickerView.tag == SECTION_TWO_ModifyView_BussineMan1_Tag) {
            if(row == 0) self.tfMdViewBussMan1.text = _MuarrayType[row];
            else{
                self.tfMdViewBussMan1.text = [_MuarrayType[row] objectForKey:@"empnickname"];
                self.tfMdViewBussMan1.accessibilityValue = [_MuarrayType[row] objectForKey:@"empid"];
            }
        }
        
        if (pickerView.tag == SECTION_TWO_ModifyView_BussineMan2_Tag) {
            if(row == 0) self.tfMdViewBussMan2.text = _MuarrayType[row];
            else {
                self.tfMdViewBussMan2.accessibilityValue = [_MuarrayType[row] objectForKey:@"empid"];
                self.tfMdViewBussMan2.text = [_MuarrayType[row] objectForKey:@"empnickname"];
            }
        }
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

/**
 *  根据卡的类型id获取卡的对应卡的信息
 */
- (NSDictionary *)GETCardTypeWithCardTypeID:(NSString *)cardTypeId {
    // 网络请求
    // 1. 设置网络url
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBFindCardAction];
    // 2. 设置请求参数体
    NSString *strHttpBody = [NSString stringWithFormat:@"groupid=%@&shopid=%@&keyword=discount", [dictLogin objectForKey:@"groupid"], [dictLogin objectForKey:@"shopid"]];
    // 3. 请求网络数据
    NSDictionary *dictCardTypes = [HttpRequest HttpAFNetworkingRequestWithURL_Two:strURL parameters:strHttpBody];
    // 4. 判读网路数据的正确性
    if ([(NSString *)[dictCardTypes objectForKey:statusCdoe] intValue] == WebDataIsRight) {
        NSArray *arrayCardTypes = [dictCardTypes objectForKey:MESSAGE];
        
        for (NSDictionary *dict  in arrayCardTypes) {
            if ([cardTypeId isEqual:[dict objectForKey:@"cdid"]]) return dict;
        }
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
