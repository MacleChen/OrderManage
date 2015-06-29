//
//  QRCodeViewController.m
//  OrderManage
//
//  Created by mac on 15/6/27.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "QRCodeViewController.h"
#import "viewOtherDeal.h"
#import "MBProgressHUD+MJ.h"


@interface QRCodeViewController () {
    float _mainScreenWidth;
    float _mainScreenHeight;
}

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    // 设置闪光灯按钮
    QCheckBox *ckLightTemp = [[QCheckBox alloc] initWithDelegate:self];
    ckLightTemp.frame = CGRectMake((_mainScreenWidth - 50)/2, (MenuBottomToolHeight - 20)/2, 50, 20);
    //QCheckBox *ckLightTemp = [[QCheckBox alloc] initWithFrame:CGRectMake((_mainScreenWidth - 50)/2, (MenuBottomToolHeight - 20)/2, 50, 20)];
    [ckLightTemp setTitle:@"开灯" forState:UIControlStateNormal];
    [ckLightTemp setTitle:@"关灯" forState:UIControlStateSelected];
    [ckLightTemp setTitleColor:ColorMainSystem forState:UIControlStateNormal];
    [ckLightTemp setTitleColor:ColorMainSystem forState:UIControlStateSelected];
    [ckLightTemp.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [ckLightTemp setImage:[UIImage imageNamed:@"uncheck_icon.png"] forState:UIControlStateNormal];
    [ckLightTemp setImage:[UIImage imageNamed:@"check_icon.png"] forState:UIControlStateSelected];
    self.ckLight = ckLightTemp;
    [self.toolbar addSubview:ckLightTemp];
    
    [self startReading];
}


- (BOOL)startReading {
    NSError *error;
    
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [self.videoPreviewLayer setFrame:self.viewPreview.layer.bounds]; //self.viewPreview.layer.bounds
    
    //9.将图层添加到预览view的图层上
    [self.viewPreview.layer addSublayer:_videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);  // (0.2f, 0.2f, 0.8f, 0.8f)
    
    //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(_mainScreenWidth * (2 - 1) / 2 / 2, _mainScreenHeight * (4 - 1) / 4 / 2, _mainScreenWidth / 2, _mainScreenHeight / 4)];
    //CGRectMake(self.view.bounds.size.width * 0.2f, self.view.bounds.size.height * 0.2f, self.view.bounds.size.width - self.view.bounds.size.width * 0.4f, self.view.bounds.size.height - self.view.bounds.size.height * 0.4f)
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    
    [self.view addSubview:_boxView];
    
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    [timer fire];
    
    //10.开始扫描
    [_captureSession startRunning];
    
    
    return YES;
}

- (void)startStopReading:(id)sender {
    if (!_isReading) {
        if ([self startReading]) {
            //[_startBtn setTitle:@"Stop" forState:UIControlStateNormal];
            //[_lblStatus setText:@"Scanning for QR Code"];
        }
    }
    else{
        [self stopReading];
        //[_startBtn setTitle:@"Start!" forState:UIControlStateNormal];
    }
    
    _isReading = !_isReading;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            //[self.tfSearch performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
            NSLog(@"%@", [metadataObj stringValue]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                // 设置代理传值
                [self.delegate QRCodeViewBackString:[metadataObj stringValue]];
            });
        }
    }
}

- (void)moveScanLayer:(NSTimer *)timer
{
    CGRect frame = _scanLayer.frame;
    if (_boxView.frame.size.height < _scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
    }else{
        
        frame.origin.y += 5;
        
        [UIView animateWithDuration:0.1 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}


#pragma mark - QCheckBoxDelegate
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {
        [MBProgressHUD show:@"手电筒异常" icon:nil view:nil];
    }else{
        [device lockForConfiguration:nil];
        if (self.ckLight.checked) {
            [device setTorchMode: AVCaptureTorchModeOn];
        }
        else
        {
            [device setTorchMode: AVCaptureTorchModeOff];
        }
        
        [device unlockForConfiguration];
    }
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

/**
 *  退出扫描界面
 */
- (IBAction)itemBtnCancelClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
    _isReading = NO;
    
}



@end
