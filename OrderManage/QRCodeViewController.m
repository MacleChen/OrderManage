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
    
    SystemSoundID _QRCodeSuccess;   // 扫描成功的声音
}

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + TOP_MENU_HEIGHT;
    self.viewPreview.frame = CGRectMake(0, 0, _mainScreenWidth, _mainScreenHeight - MenuBottomToolHeight);
    
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
    
    // 设置readLineView
    self.readLineView = [[UIImageView alloc] init];
    
    // 加载音效文件
    _QRCodeSuccess = [self loadSound:@"QRCodeSuccess.aif"];
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
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(40 , _mainScreenHeight * (3 - 1) / 3 / 2, _mainScreenWidth - 40*2, _mainScreenHeight / 3)];
//    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
//    _boxView.layer.borderWidth = 1.5f;

    [self.view addSubview:_boxView];
    
    // 设置蒙版图片
    UIImageView *imgBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QRCodeBgImg.png"]];
    imgBackground.frame = CGRectMake(0, 0, _mainScreenWidth, _mainScreenHeight);
    [self.view addSubview:imgBackground];
    
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, -10, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
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
                // 播放声音
                AudioServicesPlaySystemSound(1109);
                
                // 震动
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
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
        
        [UIView animateWithDuration:0.05f animations:^{
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
 *  调用系统相册界面
 */
- (IBAction)itemBtnToAlbumClick:(UIBarButtonItem *)sender {
    [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
    _isReading = NO;
    
//    // 跳转到主页面
//    //    [self performSegueWithIdentifier:@"Main" sender:nil];
//    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AlbumQRCode"];  // 根据storyboardID获取视图
//    [viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];    // 由下向上
//    [self presentViewController: viewController animated:YES completion:nil];
    
    // 检测IOS设备支持那种获取图片方式
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSLog(@"支持相机");
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        NSLog(@"支持图库");
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        NSLog(@"支持相片库");
    }
    
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.view.backgroundColor = [UIColor orangeColor];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.sourceType = sourcheType;
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    
    [self.picker setModalTransitionStyle:UIModalTransitionStyleCoverVertical]; // 设置视图出现效果
    [self presentViewController:self.picker animated:YES completion:nil]; // 跳转界面
}

#pragma mark - UIImagePickerController 的代理方法的实现
#pragma mark 当选取完成后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // 获取要扫描的图片
    self.imgReadForSaoQR = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    // 设置readlineview 的frame
    self.readLineView.frame = self.boxView.frame;
    
    self.readLineView.image = self.imgReadForSaoQR;
    [self.view addSubview:self.readLineView];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 当取消选取时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 加载音效文件
- (SystemSoundID)loadSound:(NSString *)soundName {
//    NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
//    
//    // 创建声音
//    SystemSoundID soundId;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundId);
    
    
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: soundName withExtension: nil];
    // Store the URL as a CFURLRef instance
    CFURLRef soundFileURLRef = (__bridge CFURLRef)tapSound;
    SystemSoundID    soundFileObject;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
    
    return soundFileObject;
}

@end
