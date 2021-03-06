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

#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"

#define CELL_HEIGHT 90   // tableviewcell的高度
#define VIEW_IN_CELL_INIT_TAG 10  // cell中的Labelview最小的tag值
//#define Stepper_VIEW_IN_CELL_INIT_TAG 20  // cell中的Labelview最小的tag值

extern NSDictionary *dictLogin;   // 引用全局登录数据

@interface MeterCardViewController () <PullTableViewDelegate, CustomIOS7AlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, QRCodeViewDelegate, UISearchBarDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSInteger _memberTotalCount;  // 会员的总数量
    int _pages;     // 页数
    
    NSMutableArray *_MuarrayType; // 要显示到pcikerview中卡类型字符串
    
    NSMutableArray *_muArrayData; // 存储显示在界面上的数据
    NSArray *_arrayGetWebData;   // 获取网络数据
    
    NSString *_strSelectCard;  // 选中的计次卡的id
    NSDictionary *_dictSelectMeterCard; // 选中的计次卡信息
    
    
    BOOL _edtedFlag; // 是否编辑输入过
}

@property (strong, nonatomic) UIImageView *imgviewDownload;   // 下载的网络图片

@end

@implementation MeterCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + TOP_MENU_HEIGHT;
    
    // 初始化信息
    _edtedFlag = NO;
    self.dictSearchMebInfo = [NSDictionary dictionary];
    _strSelectCard = [NSString string];
    _dictSelectMeterCard = [NSDictionary dictionary];
    self.imgviewDownload = [[UIImageView alloc] init];
    
    // 设置代理
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    // 设置pullTableview
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor groupTableViewBackgroundColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
    
    // 设置tableview 第一个cell距离导航栏的高度
    self.pullTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 65)];
    self.pullTableView.tableHeaderView.alpha = 0.0;
    self.pullTableView.tableFooterView = [[UIView alloc] init];
    
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
    for (UIView *viewTemp in viewsMemberMg) {
        if (viewTemp.tag == VIEW_SEARCH_TAG) {
            self.viewSearch = viewTemp;
        }
    }
    
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
    
    // 设置背景图片
    [self.btnSaoyiSao setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"saoyisao6.png"] size:CGSizeMake(30, 25)] forState:UIControlStateNormal];
    [self.btnAlertSearch setBackgroundImage:[viewOtherDeal scaleToSize:[UIImage imageNamed:@"searchBtnImg2.png"] size:CGSizeMake(45, 30)] forState:UIControlStateNormal];
    
    // 设置响应方法
    [self.btnSaoyiSao addTarget:self action:@selector(btnQRCodeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAlertSearch addTarget:self action:@selector(btnSearchAlertInClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置view的手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleBackgroundTap:)];
    tapGesture.cancelsTouchesInView = YES;
    [self.alertShow addGestureRecognizer:tapGesture];
    
    // 将view显示在alertview中
    [self.alertShow setContainerView:self.viewSearch];
    [self.alertShow show];
}

#pragma mark 结算按钮
- (IBAction)btnPayBillClick:(UIButton *)sender {
    // 判断是否有商品
    if (_MuarrayType.count <= 0) {
        [MBProgressHUD show:@"请查询您计次卡对应的商品" icon:nil view:nil];
        return;
    }
    
    // 判断是否选择了商品的个数
    if ([self.lbSelectedCount.text integerValue] <= 0) {
        [MBProgressHUD show:@"请选择商品个数" icon:nil view:nil];
        return;
    }
    
    //切换到下一个界面  --- push
    PayBillViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"PayBillView"];
    // 打包数据
    NSMutableArray *arrayTemp = [NSMutableArray array];
    for (NSDictionary *dictData in _MuarrayType) {
        if ([(NSString *)[dictData objectForKey:@"SelectedCount"] intValue] > 0) {
            [arrayTemp addObject:dictData];
        }
    }
    
    viewControl.arrayRecData = [NSArray arrayWithArray:arrayTemp];
    viewControl.dictSelectMeterCard = _dictSelectMeterCard;
    viewControl.dictSearchMebInfo = self.dictSearchMebInfo;
    [self.navigationController pushViewController:viewControl animated:YES];
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
    
    // 判断，是否有查询内容
    if ([self.seaBarInput.text isEqual:@""] || [self.lbMeterCardID.text isEqual:@""]) {
        [MBProgressHUD show:@"请输入查询内容" icon:nil view:nil];
        return;
    }
    
    // 获取计次卡的信息
    [self GetMeterCardInfo];
    // 获取计次卡对应消费的商品列表
    [self GetMeterCdProductsList];
    
    [self.alertShow close];
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
    return 1;
}

#pragma mark 设置每个section中有几个cell
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _MuarrayType.count;
}

#pragma mark 设置每个cell的内容
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; // 设置不可点击
    NSDictionary *dictTempData =  _MuarrayType[indexPath.row];

    int gapX = 10, imgWith = 90, imgHeight = 75, lbWith = 100, lbHeith = 30;
    UIImageView *imageIconView = [[UIImageView alloc] initWithFrame:CGRectMake(gapX, (CELL_HEIGHT - imgHeight)/2, imgWith, imgHeight)];
    // 获取网络图片
    NSURL *URLPath = [NSURL URLWithString:[dictTempData objectForKey:@"pic1"]];
    //图片缓存的基本代码，就是这么简单
    // 加载动态图
    NSString  *name = @"reload001";
    [self.imgviewDownload sd_setImageWithURL:URLPath placeholderImage:[UIImage sd_animatedGIFNamed:name] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imageIconView.image = image;
    }];
    
    imageIconView.image = self.imgviewDownload.image;
    [cell addSubview:imageIconView];
    
    // 设置名称和价格
    UILabel *lbProductName = [[UILabel alloc] initWithFrame:CGRectMake(gapX*2 + imgWith, (CELL_HEIGHT - 2*lbHeith)/2, lbWith, lbHeith)];
    lbProductName.font = [UIFont systemFontOfSize:18.0];
    lbProductName.textColor = [UIColor grayColor];
    lbProductName.text = [dictTempData objectForKey:@"prodname"];
    [cell addSubview:lbProductName];
    
    UILabel *lbPrice = [[UILabel alloc] initWithFrame:CGRectMake(gapX*2 + imgWith, (CELL_HEIGHT - 2*lbHeith)/2 + lbHeith, lbWith, lbHeith)];
    lbPrice.font = [UIFont systemFontOfSize:13.0];
    lbPrice.textColor = [UIColor redColor];
    lbPrice.text = [NSString stringWithFormat:@"%@ / %@", [dictTempData objectForKey:@"prodmoney"], [dictTempData objectForKey:@"produnit"]];
    [cell addSubview:lbPrice];
    
    // 设置cell中的商品个数加减
    UILabel *lbshowProductTitle;
    if (lbshowProductTitle == nil) {
        lbshowProductTitle = [[UILabel alloc] initWithFrame:CGRectMake(_mainScreenWidth*2/3 - 20, cell.center.y, 75, 30)];
    }
    lbshowProductTitle.text = @"数量:";
    lbshowProductTitle.font = [UIFont systemFontOfSize:14.0];
    lbshowProductTitle.textAlignment = NSTextAlignmentCenter;
    lbshowProductTitle.textColor = [UIColor lightGrayColor];
    UITextField *tfShowProductCount;
    if (tfShowProductCount == nil) {
        tfShowProductCount = [[UITextField alloc] initWithFrame:CGRectMake(lbshowProductTitle.frame.origin.x + lbshowProductTitle.frame.size.width, cell.center.y, 40, 29)];
    }
    tfShowProductCount.text = [_MuarrayType[indexPath.row] objectForKey:@"SelectedCount"];
    tfShowProductCount.delegate = self;
    tfShowProductCount.keyboardType = UIKeyboardTypeNumberPad;
    tfShowProductCount.borderStyle = UITextBorderStyleNone;
    tfShowProductCount.font = [UIFont systemFontOfSize:14.0];
    tfShowProductCount.textColor = [UIColor orangeColor];
    tfShowProductCount.tag = indexPath.row + VIEW_IN_CELL_INIT_TAG;
    
    UIStepper *stepper;
    if (stepper == nil) {
        stepper = [[UIStepper alloc] initWithFrame:CGRectMake(_mainScreenWidth*2/3, cell.center.y +tfShowProductCount.frame.size.height, 80, 30)];
    }
    stepper.maximumValue = 1000.0;
    stepper.tag = indexPath.row + VIEW_IN_CELL_INIT_TAG;
    
    [stepper addTarget:self action:@selector(stepperClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell addSubview:lbshowProductTitle];
    [cell addSubview:tfShowProductCount];
    [cell addSubview:stepper];
    
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
    
    MyPrint(@"选中了：%li", (long)indexPath.row);
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
                [MBProgressHUD show:@"网络不佳，请重试" icon:nil view:nil];
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
                [MBProgressHUD show:@"手机号或会员卡号不存在" icon:nil view:nil];
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
                _strSelectCard = [arrayTemp[0] objectForKey:@"cucardid"];  // 设置选中的计次卡的id
                _dictSelectMeterCard = arrayTemp[0];
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
        _strSelectCard = [_MuarrayType[row] objectForKey:@"cucardid"];  // 设置选中的计次卡的id
        _dictSelectMeterCard = _MuarrayType[row];
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
    if (textField.tag == BARSEARCH_TEXTFIELD_TAG || textField.tag == TF_METERCARDID_SELECTS_TAG) return;
    
    _edtedFlag = YES;
    NSInteger integerRow = textField.tag - VIEW_IN_CELL_INIT_TAG;  // 获取对应的cell行号
    
    NSMutableDictionary *muDictTemp = [NSMutableDictionary dictionaryWithDictionary:_MuarrayType[integerRow]];
    //[muDictTemp setObject:[NSString stringWithFormat:@"%.0f", sender.value] forKey:@"SelectedCount"];
    [muDictTemp setValue:textField.text forKey:@"SelectedCount"];
    
    NSMutableArray *muArrayTemp = [NSMutableArray arrayWithArray:_MuarrayType];
    
    [muArrayTemp setObject:muDictTemp atIndexedSubscript:integerRow];
    _MuarrayType = muArrayTemp;
    
    // 设置已选商品和消费次数
    // 1. 获取所有的cell
    NSMutableArray *muArrayCells = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.pullTableView numberOfRowsInSection:0]; i++) {
        NSIndexPath *indexTemp = [NSIndexPath indexPathForRow:i inSection:0];
        [muArrayCells addObject:[self.pullTableView cellForRowAtIndexPath:indexTemp]];
    };
    // 2. 获取所有cell中已选的商品个数总和
    NSInteger AllSelectCount = 0;
    double AllSelectMoney = 0.0;
    for (UITableViewCell *cellTemp in muArrayCells) {
        NSArray *arraySubviews =  [cellTemp subviews];
        for (UITextField *tfSlectedCount in arraySubviews) {
            if (tfSlectedCount.tag == textField.tag) {
                AllSelectCount += [tfSlectedCount.text integerValue];
                AllSelectMoney += [cellTemp.detailTextLabel.text floatValue] * [tfSlectedCount.text integerValue];
                break;
            }
        }
    }
    
    self.lbSelectedCount.text = [NSString stringWithFormat:@"%li件", (long)AllSelectCount];
    self.lbCustemCount.text = [NSString stringWithFormat:@"%0.2lf", AllSelectMoney];
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


/**
 *  获取计次卡的信息
 */
- (void)GetMeterCardInfo {
    NSDictionary *dictSelectCard = [[NSDictionary alloc] init];
    // 根据计次卡的id获取对应的数据
    NSArray *arrayMeterCards =  [self.dictSearchMebInfo objectForKey:@"listcount"];
    for (dictSelectCard in arrayMeterCards) {
        if ([_strSelectCard isEqual:[dictSelectCard objectForKey:@"cucardid"]]) break;
    }
    
    // 获取计次卡的头标
    NSString *strImgPath = [dictSelectCard objectForKey:@"cdpic"];
    strImgPath = [NSString stringWithFormat:@"%@%@", WEBBASEURL, [strImgPath substringFromIndex:3]];
    //[NSString stringWithFormat:@"%@%@", WEBBASEURL, [dictSelectCard objectForKey:@"cdpic"]];
    [self.imgViewCardIcon sd_setImageWithURL:[NSURL URLWithString:strImgPath] placeholderImage:[UIImage imageNamed:@"initCardimg.gif"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        MyPrint(@"图片加载完成");
    }];
    
    // 获取计次卡所属姓名
    self.lbCardUserName.text = self.lbName.text;
    
    // 获取计次卡的剩余次数
    self.lbSelectedRemainCount.text = [NSString stringWithFormat:@"剩余次数: %@",[dictSelectCard objectForKey:@"cardcount"]];
}

/**
 *  获取计次卡对应消费的商品列表
 */
- (void)GetMeterCdProductsList {
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@", WEBBASEURL, WEBCountSalePrdListAction];
    
    NSString *strHttpBody = [NSString stringWithFormat:@"keyword=%@", _strSelectCard];
    
    //NSString *strHttpBody = [NSString stringWithFormat:@"keyword=%@&shopid=%@", _strSelectCard, [dictLogin objectForKey:@"shopid"]];
    
    [MBProgressHUD show:@"" icon:nil view:nil];
    [HttpRequest HttpAFNetworkingRequestBlockWithURL:strURL strHttpBody:strHttpBody Retype:HttpPOST willDone:^(NSURLResponse *response, NSData *data, NSError *error) {
        [MBProgressHUD hideHUD];
        if (data) { // 请求成功
            NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *strStatus = [listData objectForKey:statusCdoe];
            // 数据异常
            if(strStatus == nil){
                [MBProgressHUD show:@"网络不佳，请稍后重试" icon:nil view:nil];
                return;
            }
            if ([strStatus intValue] == 200) { // 获取正确的数据
                _MuarrayType = [NSMutableArray arrayWithArray:[listData objectForKey:MESSAGE]];
                
                // 添加新的关键字
                for(int i = 0; i < _MuarrayType.count; i++) {
                    NSMutableDictionary *mudictData = [NSMutableDictionary dictionaryWithDictionary:[_MuarrayType objectAtIndex:i]];
                    [mudictData setValue:@"0" forKey:@"SelectedCount"];
                    [_MuarrayType replaceObjectAtIndex:i withObject:mudictData];
                }
                
                [self.pullTableView reloadData];  // 刷新整个表
            } else { // 数据有问题
                [MBProgressHUD show:[listData objectForKey:MESSAGE] icon:nil view:nil];
            }
        } else { // 请求失败
            [MBProgressHUD show:ConnectException icon:nil view:nil];
        }
        
    }];
}


#pragma mark cell中的stepper点击响应方法
- (void)stepperClick:(UIStepper *)sender {
    NSInteger integerRow = sender.tag - VIEW_IN_CELL_INIT_TAG;  // 获取对应的cell行号
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:integerRow inSection:0];
    UITableViewCell *cellDeal =  [self.pullTableView cellForRowAtIndexPath:indexPath];
    
    // 修改数量
    NSMutableDictionary *muDictTemp = [_MuarrayType objectAtIndex:integerRow];
    [muDictTemp setValue:[NSString stringWithFormat:@"%.0f", sender.value] forKey:@"SelectedCount"];
    [_MuarrayType replaceObjectAtIndex:integerRow withObject:muDictTemp];
    
    // 获取当前cell的子view
    NSArray *arraySubviews =  [cellDeal subviews];
    for (int i = 0; i < arraySubviews.count ; i++) {
        UITextField *tfSlectedCount =  arraySubviews[i];
        if (tfSlectedCount.tag == sender.tag) {
            if(_edtedFlag) { // 是否编辑输入过
                sender.value = [tfSlectedCount.text floatValue];
                _edtedFlag = NO;
            }
            tfSlectedCount.text = [NSString stringWithFormat:@"%.0f", sender.value];
            break;
        }
    }
    
    // 设置已选商品和消费次数 -- 总钱数
    NSInteger AllSelectCount = 0;
    double AllSelectMoney = 0;
    for (NSDictionary *dictData in _MuarrayType) {
        int selectCount = [(NSString *)[dictData objectForKey:@"SelectedCount"] intValue];
        AllSelectCount += selectCount;
        AllSelectMoney += selectCount * [(NSString *)[dictData objectForKey:@"prodmoney"] floatValue];
    }
    
    self.lbSelectedCount.text = [NSString stringWithFormat:@"%li件", (long)AllSelectCount];
    self.lbCustemCount.text = [NSString stringWithFormat:@"%.2lf", AllSelectMoney];
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
