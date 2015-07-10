//
//  BlueDeviceViewController.m
//  OrderManage
//
//  Created by mac on 15/6/17.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "BlueDeviceViewController.h"
#import "MBProgressHUD+MJ.h"

@interface BlueDeviceViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    NSMutableArray *_MuarrayScanBluethDevices;  // 扫描到的设备
    
    NSDictionary *_dictOption;
    NSString *_message; // 信息提示
    
    int _sectionCount;   // section 的个数
}

@end

@implementation BlueDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    // 初始化
    self.cbCenterMg = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.peripheralArray = [NSMutableArray array];
    _sectionCount = 2;   // 默认为 1;
    
    // 设置代理
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    // 扫描外部设备
    //NSArray *uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1800"],[CBUUID UUIDWithString:@"180A"], [CBUUID UUIDWithString:@"1CB2D155-33A0-EC21-6011-CD4B50710777"],[CBUUID UUIDWithString:@"6765D311-DD4C-9C14-74E1-A431BBFD0652"],nil];
    [self.cbCenterMg scanForPeripheralsWithServices:nil options:_dictOption];
    
    // 初始化加载标志
    self.atiview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.atiview.frame = CGRectMake(_mainScreenWidth*4/5, 0, 50, self.tableview.sectionHeaderHeight);
    
    // 设置定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(tableviewReloadData) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantFuture]];  // 不开启定时器
}

#pragma mark - tableview 的代理方法实现
#pragma mark  设置有几个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionCount;
}

#pragma mark 设置每个section中有几个cell
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1;
    
    return _MuarrayScanBluethDevices.count;
}

#pragma mark 设置每个cell的内容
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    
    // 设置checkbox
    if (indexPath.section == 0) {
        // 设置为不可点击
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"蓝牙";
        
        // 设置开关键
        UISwitch *swBtnBluethStateTemp = [[UISwitch alloc] init];
        self.swbtnBluethState = swBtnBluethStateTemp;
        [self.swbtnBluethState addTarget:self action:@selector(swbtnBluethStateClick:) forControlEvents:UIControlEventValueChanged];
        
        [cell setAccessoryView:self.swbtnBluethState];
    }
    
    // 设置section == 1 部分
    if (indexPath.section == 1 && _MuarrayScanBluethDevices.count > 0) {
        CBPeripheral *peripheral = _MuarrayScanBluethDevices[indexPath.row];
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = peripheral.state == CBPeripheralStateConnected ? @"已连接" : @"未连接";
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
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
    // 获取本机的设备名称
    NSString *strMyphoneName = [[UIDevice currentDevice] name];
    
    if(section == 0) return [NSString stringWithFormat:@"本机名称：%@", strMyphoneName];
    return @"";
    
}

#pragma mark 当开始拖拽时调用的方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

#pragma mark 设置每个row的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark  选中cell时响应方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        // 点击选中要连接的设备
         [self.cbCenterMg connectPeripheral:_MuarrayScanBluethDevices[indexPath.row]  options:nil];
    }
    
}

#pragma mark 设置Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

#pragma mark 返回 headerview
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerview = [[UIView alloc] init];
    if(section == 1) {
        [headerview addSubview:self.atiview];
        //[self.atiview startAnimating];
        
        UILabel *lbSectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(_mainScreenWidth/20, 0, 150, tableView.sectionHeaderHeight)];
        lbSectionTitle.text = @"发现设备";
        lbSectionTitle.textColor = [UIColor grayColor];
        lbSectionTitle.font = [UIFont systemFontOfSize:13.0];
        [headerview addSubview:lbSectionTitle];
        return headerview;
    }
    
    return nil;
}

#pragma mark -  CBCentralManager 代理方法的实现
#pragma mark  
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateResetting:
            _message = @"初始化中";
            break;
        case CBCentralManagerStateUnsupported:
            _message = @"设备不支持状态";
            break;
        case CBCentralManagerStateUnauthorized:
            _message = @"设备未授权状态";
            break;
        case CBCentralManagerStateUnknown:
            _message = @"未知设备";
            break;
        case CBCentralManagerStatePoweredOff:
            self.swbtnBluethState.on = NO;
            [self.atiview stopAnimating];
            _message = @"尚未打开蓝牙";
            break;
        case CBCentralManagerStatePoweredOn:
            self.swbtnBluethState.on = YES;
            [self.atiview startAnimating];
            _message = @"蓝牙已经成功开启";
            [self.cbCenterMg scanForPeripheralsWithServices:nil options:nil];  // 扫描蓝牙设备
            [self.timer setFireDate:[NSDate distantPast]];          // 开启定时器
            break;
        default:
            break;
    }

    
    [MBProgressHUD show:_message icon:nil view:nil];
}

#pragma mark 发现蓝牙设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    MyPrint(@"发现蓝牙设备");
    NSString *str = [NSString stringWithFormat:@"Did discover peripheral. peripheral: %@ rssi: %@, advertisementData: %@ ", peripheral, RSSI, advertisementData];
    MyPrint(@"%@",str);
    [_MuarrayScanBluethDevices addObject:peripheral];
}

#pragma mark 连接上蓝牙设备成功时
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    MyPrint(@"Did connect to peripheral: %@", peripheral);
    peripheral.delegate = self;
    [central stopScan];
    [peripheral discoverServices:nil];
}

#pragma mark 发现外围设备的服务通知时
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error)
    {
        MyPrint(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services)
    {
        MyPrint(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

#pragma mark 方法是找到FEE0服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error)
    {
        MyPrint(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        MyPrint(@"%@", characteristic);
        if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
        {
            self.cbperi = peripheral;
            self.cbChtic = characteristic;
            
            //read
            //[testPeripheral readValueForCharacteristic:characteristic];
            MyPrint(@"Found a Device Manufacturer Name Characteristic - Read manufacturer name");
        }
    }
}

#pragma mark 蓝牙开关变化
- (void)swbtnBluethStateClick:(UISwitch *)sender {
    MyPrint(@"%li", (long)self.cbCenterMg.state);
    
    if (self.cbCenterMg.state == CBCentralManagerStatePoweredOff) {
        [MBProgressHUD show:@"请在：设置>蓝牙 中打开它" icon:nil view:nil];
        self.swbtnBluethState.on = NO;
    }
    
    if (self.swbtnBluethState.on) {  // 开
        MyPrint(@"开");
        [self.atiview startAnimating];
        
        // 扫描蓝牙设备
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        
        [self.cbCenterMg scanForPeripheralsWithServices:nil options:dic];
        
        // 开启定时器
        [self.timer setFireDate:[NSDate distantPast]];
    } else {                        // 关
        MyPrint(@"关");
        [self.atiview stopAnimating];
        
        // 关闭定时器
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}


#pragma mark 定时调用此方法，用于刷新tableview
- (void)tableviewReloadData {
    MyPrint(@"定时器刷新");
    // 刷新第二个section
    NSIndexSet *indexset = [[NSIndexSet alloc] initWithIndex:1];
    [self.tableview reloadSections:indexset withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark 页面将要进入前台，开启定时器
- (void)viewWillAppear:(BOOL)animated {
    // 延迟处理
    [NSThread sleepForTimeInterval:1.0];
    
    if(self.swbtnBluethState.on) {
        //开启定时器
        [self.timer setFireDate:[NSDate distantPast]];   // distantpast 获取遥远的过去的一个时间
    }
}

#pragma mark 页面消失，进入后台不显示该页面，关闭定时器
- (void)viewWillDisappear:(BOOL)animated {
    [self.timer setFireDate:[NSDate distantFuture]];   // distantFuture 获取遥远未来的一个时间
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
